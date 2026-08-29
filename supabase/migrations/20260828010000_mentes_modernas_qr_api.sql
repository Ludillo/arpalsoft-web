create table if not exists public.qr_external_requests (
  id uuid primary key default gen_random_uuid(),
  client_code text not null,
  session_hash text not null,
  integration_id uuid not null references public.qr_integrations(id),
  qr_code_id uuid references public.qr_codes(id),
  transaction_id varchar(8) not null,
  environment public.qr_environment not null,
  currency varchar(3) not null check (currency in ('BOB', 'USD')),
  amount numeric(18,2) not null check (amount > 0),
  description varchar(100),
  status public.qr_status not null default 'pending',
  last_bank_check_at timestamptz,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (integration_id, transaction_id),
  unique (client_code, session_hash, transaction_id)
);

create index if not exists qr_external_requests_lookup_idx
  on public.qr_external_requests (client_code, session_hash, transaction_id);
create index if not exists qr_external_requests_pending_idx
  on public.qr_external_requests (integration_id, status, created_at desc);

drop trigger if exists qr_external_requests_touch on public.qr_external_requests;
create trigger qr_external_requests_touch before update on public.qr_external_requests
for each row execute function public.touch_updated_at();

alter table public.qr_external_requests enable row level security;
revoke all on public.qr_external_requests from anon, authenticated;

comment on table public.qr_external_requests is
  'Relaciona una sesion externa anonimizada con el QR de Banco Economico. Solo la service role puede acceder.';
