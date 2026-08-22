-- V2 no crea clientes ficticios. El bloque de logos permanece oculto hasta
-- que se publique desde /admin/clientes un registro con logo válido.
insert into public.site_sections(page_key,section_key,title,subtitle,content,sort_order,is_published)
values ('home','clients','Empresas que confían en ARPAL SOFT','CLIENTES','{}'::jsonb,2,true)
on conflict(page_key,section_key) do nothing;
