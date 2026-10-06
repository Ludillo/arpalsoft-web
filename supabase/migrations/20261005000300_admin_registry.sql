alter table public.admin_users add column if not exists email text;
alter table public.admin_users add column if not exists full_name text;
alter table public.admin_users add column if not exists is_active boolean not null default true;
alter table public.admin_users add column if not exists mfa_required boolean not null default true;
alter table public.admin_users add column if not exists updated_at timestamptz not null default now();

update public.admin_users a set email=lower(u.email)
from auth.users u where u.id=a.user_id and (a.email is null or a.email='');

create unique index if not exists admin_users_email_unique on public.admin_users(lower(email)) where email is not null;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public as $$
  select exists(
    select 1 from public.admin_users
    where user_id=auth.uid()
      and is_active=true
      and lower(email)=lower(coalesce(auth.jwt()->>'email',''))
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

drop policy if exists "admin update own registry" on public.admin_users;
create policy "admin update own registry" on public.admin_users
for update to authenticated using(user_id=auth.uid() and public.is_admin())
with check(user_id=auth.uid() and public.is_admin());

grant update(full_name) on public.admin_users to authenticated;
