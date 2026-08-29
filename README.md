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

## CobroQR / Banco Económico

El repositorio unifica el sitio, la interfaz `/CobroQR/`, las migraciones y Edge
Functions de Supabase, y el Worker publicado en `api.arpalsoft.com`.

La integración Mentes Modernas es exclusivamente servidor a servidor:

- `POST https://api.arpalsoft.com/v1/mentes-modernas/qrs` genera el QR.
- `GET https://api.arpalsoft.com/v1/mentes-modernas/qrs/{transactionId}/status?sessionId={sessionId}`
  consulta el estado y, con un intervalo mínimo de 45 segundos, concilia contra
  el reporte `paidQR` del Banco Económico.
- Ambos endpoints requieren `X-Client-Token`. El token está guardado como
  secreto en Cloudflare y en el proyecto Supabase de Mentes Modernas; nunca debe
  enviarse al navegador.

El navegador de Mentes Modernas crea un identificador opaco de sesión. Su backend
lo envía al API y conserva la respuesta. Arpalsoft guarda únicamente el hash
SHA-256 del identificador y genera un `transactionId` numérico aleatorio de ocho
dígitos. La tabla `qr_external_requests` relaciona esa sesión con `qr_codes` y
`qr_payments`.

Ejemplo de solicitud desde el backend:

```http
POST /v1/mentes-modernas/qrs
X-Client-Token: <secreto-del-servidor>
Content-Type: application/json

{
  "sessionId": "uuid-o-identificador-opaco-de-la-sesion",
  "amount": 250.00,
  "currency": "BOB",
  "description": "Compra Mentes Modernas",
  "dueDate": "2026-08-29",
  "singleUse": true,
  "modifyAmount": false
}
```

La respuesta contiene `transactionId`, `qrId`, `qrImage`, `status` y
`dueDate`. El frontend debe consultar su propio backend hasta obtener
`paid: true`; recién entonces continúa el flujo de compra.

## Próxima evolución natural
- casos de éxito
- blog/insights
- multiidioma
- Storage para imágenes
- SEO dinámico
- Analytics
- Edge Function para email al recibir un contacto
