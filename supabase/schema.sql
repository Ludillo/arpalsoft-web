
create extension if not exists pgcrypto;

create table if not exists public.admin_users(
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.site_sections(
  id uuid primary key default gen_random_uuid(),
  page_key text not null,
  section_key text not null,
  title text not null,
  subtitle text,
  content jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(page_key,section_key)
);

create table if not exists public.services(
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  short_description text not null,
  description text,
  icon text,
  tags text[] not null default '{}',
  sort_order integer not null default 0,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.contact_messages(
  id uuid primary key default gen_random_uuid(),
  full_name text not null check(char_length(full_name) between 2 and 120),
  company text,
  email text not null check(char_length(email) between 5 and 254),
  phone text,
  subject text,
  message text not null check(char_length(message) between 5 and 5000),
  status text not null default 'new' check(status in('new','read','closed')),
  created_at timestamptz not null default now()
);

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at=now(); return new; end $$;

drop trigger if exists trg_site_sections_updated_at on public.site_sections;
create trigger trg_site_sections_updated_at before update on public.site_sections
for each row execute function public.touch_updated_at();

drop trigger if exists trg_services_updated_at on public.services;
create trigger trg_services_updated_at before update on public.services
for each row execute function public.touch_updated_at();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.admin_users where user_id=auth.uid());
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

alter table public.admin_users enable row level security;
alter table public.site_sections enable row level security;
alter table public.services enable row level security;
alter table public.contact_messages enable row level security;

drop policy if exists "admin membership own row" on public.admin_users;
create policy "admin membership own row" on public.admin_users
for select to authenticated using(user_id=auth.uid());

drop policy if exists "read published sections" on public.site_sections;
create policy "read published sections" on public.site_sections
for select to anon,authenticated using(is_published=true or public.is_admin());

drop policy if exists "admin insert sections" on public.site_sections;
create policy "admin insert sections" on public.site_sections
for insert to authenticated with check(public.is_admin());

drop policy if exists "admin update sections" on public.site_sections;
create policy "admin update sections" on public.site_sections
for update to authenticated using(public.is_admin()) with check(public.is_admin());

drop policy if exists "admin delete sections" on public.site_sections;
create policy "admin delete sections" on public.site_sections
for delete to authenticated using(public.is_admin());

drop policy if exists "read published services" on public.services;
create policy "read published services" on public.services
for select to anon,authenticated using(is_published=true or public.is_admin());

drop policy if exists "admin insert services" on public.services;
create policy "admin insert services" on public.services
for insert to authenticated with check(public.is_admin());

drop policy if exists "admin update services" on public.services;
create policy "admin update services" on public.services
for update to authenticated using(public.is_admin()) with check(public.is_admin());

drop policy if exists "admin delete services" on public.services;
create policy "admin delete services" on public.services
for delete to authenticated using(public.is_admin());

drop policy if exists "public contact insert" on public.contact_messages;
create policy "public contact insert" on public.contact_messages
for insert to anon,authenticated with check(
  status='new'
  and char_length(full_name) between 2 and 120
  and char_length(email) between 5 and 254
  and char_length(message) between 5 and 5000
);

drop policy if exists "admin read contacts" on public.contact_messages;
create policy "admin read contacts" on public.contact_messages
for select to authenticated using(public.is_admin());

drop policy if exists "admin update contacts" on public.contact_messages;
create policy "admin update contacts" on public.contact_messages
for update to authenticated using(public.is_admin()) with check(public.is_admin());

grant usage on schema public to anon,authenticated;
grant select on public.site_sections,public.services to anon,authenticated;
grant insert on public.contact_messages to anon,authenticated;
grant select,insert,update,delete on public.site_sections,public.services to authenticated;
grant select,update on public.contact_messages to authenticated;
grant select on public.admin_users to authenticated;
