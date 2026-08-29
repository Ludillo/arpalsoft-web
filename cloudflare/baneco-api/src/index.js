const SUPABASE_FUNCTION = 'https://hfmlocgnawmwonjqszso.supabase.co/functions/v1/baneco-qr';
const MAX_BODY_BYTES = 1_000_000;

function secureEqual(left, right) {
  if (!left || !right || left.length !== right.length) return false;
  let difference = 0;
  for (let index = 0; index < left.length; index += 1) {
    difference |= left.charCodeAt(index) ^ right.charCodeAt(index);
  }
  return difference === 0;
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
      'x-content-type-options': 'nosniff',
    },
  });
}

function bearerOrHeader(request, headerName) {
  const authorization = request.headers.get('authorization') || '';
  return authorization.toLowerCase().startsWith('bearer ')
    ? authorization.slice(7).trim()
    : request.headers.get(headerName) || '';
}

async function forward(request, env, target, extraHeaders = {}) {
  const contentLength = Number(request.headers.get('content-length') || 0);
  if (contentLength > MAX_BODY_BYTES) return json({ error: 'Solicitud demasiado grande' }, 413);

  const headers = new Headers(request.headers);
  headers.set('x-proxy-secret', env.PROXY_SECRET);
  headers.set('x-request-id', request.headers.get('x-request-id') || crypto.randomUUID());
  headers.set('x-forwarded-host', new URL(request.url).host);
  headers.delete('host');
  headers.delete('authorization');
  headers.delete('x-callback-token');
  headers.delete('x-client-token');
  for (const [name, value] of Object.entries(extraHeaders)) headers.set(name, value);

  const started = Date.now();
  try {
    const upstream = await fetch(new Request(target, {
      method: request.method,
      headers,
      body: request.method === 'GET' || request.method === 'HEAD' ? undefined : request.body,
    }));
    console.log(JSON.stringify({ event: 'upstream_response', path: new URL(request.url).pathname, status: upstream.status, durationMs: Date.now() - started }));
    return new Response(upstream.body, {
      status: upstream.status,
      headers: {
        'content-type': upstream.headers.get('content-type') || 'application/json',
        'cache-control': 'no-store',
        'x-content-type-options': 'nosniff',
      },
    });
  } catch (error) {
    console.error(JSON.stringify({ event: 'upstream_error', path: new URL(request.url).pathname, durationMs: Date.now() - started, error: String(error) }));
    return json({ error: 'Servicio temporalmente no disponible' }, 503);
  }
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === 'GET' && url.pathname === '/health') {
      return json({ ok: true, service: 'Arpalsoft BEC QR Connect' });
    }

    const callbackLive = url.pathname === '/api/qrsimple/notifyPaymentQR';
    const callbackTest = url.pathname === '/test/api/qrsimple/notifyPaymentQR';
    if (callbackLive || callbackTest) {
      if (request.method !== 'POST') return json({ responseCode: 405, message: 'Método no permitido' }, 405);
      if (!request.headers.get('content-type')?.toLowerCase().includes('application/json')) {
        return json({ responseCode: 415, message: 'Se requiere application/json' }, 415);
      }
      if (!secureEqual(bearerOrHeader(request, 'x-callback-token'), env.CALLBACK_TOKEN)) {
        return json({ responseCode: 401, message: 'Token de callback no válido' }, 401);
      }
      const environment = callbackTest ? 'test' : 'production';
      const route = callbackTest ? 'callback-test' : 'callback';
      return forward(request, env, `${SUPABASE_FUNCTION}/${route}?environment=${environment}`);
    }

    const createQr = url.pathname === '/v1/mentes-modernas/qrs';
    const statusMatch = url.pathname.match(/^\/v1\/mentes-modernas\/qrs\/(\d{4,8})\/status$/);
    if (createQr || statusMatch) {
      if (!secureEqual(bearerOrHeader(request, 'x-client-token'), env.MENTES_MODERNAS_API_TOKEN)) {
        return json({ error: 'Cliente no autorizado' }, 401);
      }
      if (createQr && request.method !== 'POST') return json({ error: 'Método no permitido' }, 405);
      if (statusMatch && request.method !== 'GET') return json({ error: 'Método no permitido' }, 405);
      if (createQr && !request.headers.get('content-type')?.toLowerCase().includes('application/json')) {
        return json({ error: 'Se requiere application/json' }, 415);
      }

      const target = createQr
        ? `${SUPABASE_FUNCTION}/external-generate`
        : `${SUPABASE_FUNCTION}/external-status?transactionId=${statusMatch[1]}&sessionId=${encodeURIComponent(url.searchParams.get('sessionId') || '')}`;
      return forward(request, env, target, {
        'x-client-code': 'mentes-modernas',
        'x-qr-environment': 'production',
      });
    }

    return json({ error: 'Ruta no encontrada' }, 404);
  },
};
