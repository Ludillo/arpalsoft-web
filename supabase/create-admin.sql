-- 1) Crear usuario en Supabase > Authentication > Users > Add user
-- 2) Reemplazar UUID:
-- insert into public.admin_users(user_id) values('00000000-0000-0000-0000-000000000000');

select u.id,u.email,(a.user_id is not null) as is_admin
from auth.users u left join public.admin_users a on a.user_id=u.id
order by u.created_at desc;
