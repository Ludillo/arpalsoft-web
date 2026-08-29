create table if not exists public.qr_api_logs(
  id bigint generated always as identity primary key,
  integration_id uuid not null references public.qr_integrations(id) on delete cascade,
  method text not null,
  endpoint text not null,
  request_payload jsonb,
  status_code integer,
  response_payload jsonb,
  success boolean not null default false,
  error text,
  duration_ms integer,
  created_at timestamptz not null default now()
);
create index if not exists qr_api_logs_environment_date on public.qr_api_logs(integration_id,created_at desc);
alter table public.qr_api_logs enable row level security;

-- Revert only the encrypted test override; the original server secret remains active.
delete from public.qr_integration_credentials
where integration_id in(select id from public.qr_integrations where environment='test');
