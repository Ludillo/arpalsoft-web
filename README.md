# ARPAL SOFT Web

Proyecto corporativo responsive y administrable con React + TypeScript + Vite + Supabase.

## Qué incluye
- Home premium orientado a banca/fintech.
- Soluciones, Nosotros y Contacto.
- Formulario de contacto guardado en Supabase.
- `/admin/login` con Supabase Auth.
- CMS para editar secciones, servicios y revisar contactos.
- Row Level Security.
- Diseño responsive desktop/tablet/mobile.
- Contenido principal desacoplado del JSX.

## Instalación
1. Crear proyecto en Supabase.
2. Ejecutar `supabase/schema.sql`.
3. Ejecutar `supabase/seed.sql`.
4. Crear usuario en Authentication > Users.
5. Insertar su UUID en `admin_users` usando `supabase/create-admin.sql`.
6. Copiar `.env.example` a `.env`.
7. Completar:
   VITE_SUPABASE_URL
   VITE_SUPABASE_PUBLISHABLE_KEY
8. Ejecutar:
   npm install
   npm run dev

## Administración
Abrir `/admin/login`.

## Producción
`npm run build` genera `dist/`.

Supabase funciona como backend (Postgres/Auth/Data API). El frontend debe desplegarse en un hosting web/estático como Cloudflare Pages, Vercel, Netlify o tu infraestructura.

## Seguridad
Nunca colocar `service_role` en el frontend. El proyecto usa la publishable key y RLS.

## Próxima evolución natural
- casos de éxito
- blog/insights
- multiidioma
- Storage para imágenes
- SEO dinámico
- Analytics
- Edge Function para email al recibir un contacto
