create table if not exists public.qr_callback_tests(
  id bigint generated always as identity primary key,
  integration_id uuid not null references public.qr_integrations(id) on delete cascade,
  payload jsonb not null,
  valid boolean not null,
  error text,
  created_at timestamptz not null default now()
);
create index if not exists qr_callback_tests_environment_date on public.qr_callback_tests(integration_id,created_at desc);
alter table public.qr_callback_tests enable row level security;
