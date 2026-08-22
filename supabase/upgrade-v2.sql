-- Migración incremental V2 para una base ARPAL SOFT existente.
create table if not exists public.clients(
  id uuid primary key default gen_random_uuid(),
  name text not null check(char_length(name) between 2 and 160),
  logo_url text not null check(char_length(logo_url) > 0),
  website_url text,
  sort_order integer not null default 0,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_clients_updated_at on public.clients;
create trigger trg_clients_updated_at before update on public.clients
for each row execute function public.touch_updated_at();

alter table public.clients enable row level security;

drop policy if exists "read published clients" on public.clients;
create policy "read published clients" on public.clients
for select to anon,authenticated using(is_published=true or public.is_admin());

drop policy if exists "admin insert clients" on public.clients;
create policy "admin insert clients" on public.clients
for insert to authenticated with check(public.is_admin());

drop policy if exists "admin update clients" on public.clients;
create policy "admin update clients" on public.clients
for update to authenticated using(public.is_admin()) with check(public.is_admin());

drop policy if exists "admin delete clients" on public.clients;
create policy "admin delete clients" on public.clients
for delete to authenticated using(public.is_admin());

grant select on public.clients to anon,authenticated;
grant insert,update,delete on public.clients to authenticated;
