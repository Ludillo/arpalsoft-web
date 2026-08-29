alter table public.qr_integrations add column if not exists updated_at timestamptz not null default now();
create table if not exists public.qr_integration_credentials(
  integration_id uuid primary key references public.qr_integrations(id) on delete cascade,
  encrypted_payload text not null,
  updated_at timestamptz not null default now()
);
alter table public.qr_integration_credentials enable row level security;
