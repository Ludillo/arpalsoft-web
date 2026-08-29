create extension if not exists pgcrypto;

create type public.qr_environment as enum ('test', 'production');
create type public.qr_status as enum ('pending', 'paid', 'cancelled', 'expired', 'error');
create type public.reconciliation_status as enum ('running', 'completed', 'failed');

create table public.qr_integrations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  environment public.qr_environment not null,
  enabled boolean not null default false,
  base_url text not null,
  username_secret_name text not null,
  password_secret_name text not null,
  aes_key_secret_name text not null,
  account_credit_secret_name text not null,
  callback_secret_name text not null,
  default_currency text not null default 'BOB' check (default_currency in ('BOB','USD')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (name, environment)
);

create table public.qr_codes (
  id uuid primary key default gen_random_uuid(),
  integration_id uuid not null references public.qr_integrations(id),
  transaction_id varchar(30) not null,
  bank_qr_id text,
  currency varchar(3) not null check (currency in ('BOB','USD')),
  amount numeric(18,2) not null check (amount > 0),
  description varchar(100),
  due_date date not null,
  single_use boolean not null default true,
  modify_amount boolean not null default false,
  branch_code varchar(5),
  status public.qr_status not null default 'pending',
  qr_image_base64 text,
  bank_response jsonb,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (integration_id, transaction_id),
  unique (integration_id, bank_qr_id)
);

create table public.qr_payments (
  id uuid primary key default gen_random_uuid(),
  qr_code_id uuid references public.qr_codes(id),
  integration_id uuid not null references public.qr_integrations(id),
  bank_qr_id text not null,
  transaction_id text,
  payment_date date not null,
  payment_time time,
  currency varchar(3) not null check (currency in ('BOB','USD')),
  amount numeric(18,2) not null,
  sender_bank_code text,
  sender_name text,
  sender_document_id text,
  sender_account_masked text,
  description text,
  branch_code varchar(5),
  source text not null check (source in ('callback','status','reconciliation','manual')),
  raw_payload jsonb not null,
  received_at timestamptz not null default now(),
  unique (integration_id, bank_qr_id, payment_date, payment_time, amount, sender_account_masked)
);

create table public.qr_callback_events (
  id uuid primary key default gen_random_uuid(),
  integration_id uuid references public.qr_integrations(id),
  event_type text not null default 'payment',
  signature_valid boolean not null default false,
  payload jsonb not null,
  processing_error text,
  processed_at timestamptz,
  received_at timestamptz not null default now()
);

create table public.qr_reconciliation_runs (
  id uuid primary key default gen_random_uuid(),
  integration_id uuid not null references public.qr_integrations(id),
  reconciliation_date date not null,
  status public.reconciliation_status not null default 'running',
  payments_found integer not null default 0,
  payments_inserted integer not null default 0,
  error_message text,
  started_at timestamptz not null default now(),
  completed_at timestamptz
);

create table public.qr_audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid references auth.users(id),
  action text not null,
  entity_type text not null,
  entity_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index qr_codes_status_idx on public.qr_codes (integration_id, status, created_at desc);
create index qr_payments_date_idx on public.qr_payments (integration_id, payment_date desc);
create index qr_callbacks_received_idx on public.qr_callback_events (received_at desc);

create or replace function public.touch_updated_at() returns trigger
language plpgsql set search_path = public as $$
begin new.updated_at = now(); return new; end $$;

create trigger qr_integrations_touch before update on public.qr_integrations
for each row execute function public.touch_updated_at();
create trigger qr_codes_touch before update on public.qr_codes
for each row execute function public.touch_updated_at();

create or replace function public.is_qr_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'qr_admin')::boolean, false)
$$;

alter table public.qr_integrations enable row level security;
alter table public.qr_codes enable row level security;
alter table public.qr_payments enable row level security;
alter table public.qr_callback_events enable row level security;
alter table public.qr_reconciliation_runs enable row level security;
alter table public.qr_audit_log enable row level security;

create policy "qr admins manage integrations" on public.qr_integrations for all to authenticated
using (public.is_qr_admin()) with check (public.is_qr_admin());
create policy "authenticated read qr codes" on public.qr_codes for select to authenticated using (true);
create policy "qr admins manage qr codes" on public.qr_codes for all to authenticated
using (public.is_qr_admin()) with check (public.is_qr_admin());
create policy "authenticated read payments" on public.qr_payments for select to authenticated using (true);
create policy "qr admins manage payments" on public.qr_payments for all to authenticated
using (public.is_qr_admin()) with check (public.is_qr_admin());
create policy "qr admins read callbacks" on public.qr_callback_events for select to authenticated using (public.is_qr_admin());
create policy "qr admins read reconciliations" on public.qr_reconciliation_runs for select to authenticated using (public.is_qr_admin());
create policy "qr admins read audit" on public.qr_audit_log for select to authenticated using (public.is_qr_admin());

revoke all on public.qr_integrations, public.qr_callback_events, public.qr_audit_log from anon;

insert into public.qr_integrations
  (name, environment, enabled, base_url, username_secret_name, password_secret_name, aes_key_secret_name, account_credit_secret_name, callback_secret_name)
values
  ('Baneco BEC QR CONNECT', 'test', true, 'https://apimktdesa.baneco.com.bo/ApiGateway', 'BANECO_TEST_USERNAME', 'BANECO_TEST_PASSWORD', 'BANECO_TEST_AES_KEY', 'BANECO_TEST_ACCOUNT_CREDIT', 'BANECO_TEST_CALLBACK_SECRET'),
  ('Baneco BEC QR CONNECT', 'production', false, 'https://replace-with-production-url.invalid', 'BANECO_PROD_USERNAME', 'BANECO_PROD_PASSWORD', 'BANECO_PROD_AES_KEY', 'BANECO_PROD_ACCOUNT_CREDIT', 'BANECO_PROD_CALLBACK_SECRET');
