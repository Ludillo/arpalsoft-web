create or replace function public.is_registered_admin_email(p_email text)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(
    select 1 from public.admin_users
    where lower(email)=lower(trim(p_email)) and is_active=true and mfa_required=true
  );
$$;
revoke all on function public.is_registered_admin_email(text) from public;
grant execute on function public.is_registered_admin_email(text) to anon,authenticated;
