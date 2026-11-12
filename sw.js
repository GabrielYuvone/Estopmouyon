// ESTOPMOUYON - Service Worker
// Cache strategy:
//  - Precache: HTML, manifest, icons (same origin) + librerías CDN (gif.js, mp4-muxer)
//  - Runtime: stale-while-revalidate para todo lo demas GET
//  - Sin cache: blob:, data:, requests POST/PUT

const CACHE_VERSION = 'estopmouyon-v1';
const CACHE_NAME = CACHE_VERSION;

// Recursos a pre-cachear durante install (primeira visita)
const PRECACHE_URLS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './icon-maskable-512.png',
  './apple-touch-icon.png',
  './favicon-32.png',
  // CDN: librerías JS para que la app funcione offline
  'https://cdn.jsdelivr.net/npm/gif.js@0.2.0/dist/gif.js',
  'https://cdn.jsdelivr.net/npm/mp4-muxer@5.1.4/build/mp4-muxer.min.js'
];

// Install: pre-cachea todo (usa Promise.allSettled para que un fallo no rompa todo)
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[SW] Pre-cacheando recursos...');
      return Promise.allSettled(
        PRECACHE_URLS.map((url) =>
          cache.add(new Request(url, { mode: 'cors' })).catch((err) => {
            console.warn('[SW] No se pudo cachear:', url, err.message);
          })
        )
      );
    }).then(() => {
      console.log('[SW] Pre-cache completo. skipWaiting.');
      return self.skipWaiting();
    })
  );
});

// Activate: limpia caches viejos y toma control
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((k) => k !== CACHE_NAME).map((k) => {
          console.log('[SW] Borrando cache viejo:', k);
          return caches.delete(k);
        })
      )
    ).then(() => {
      console.log('[SW] Activado. clients.claim.');
      return self.clients.claim();
    })
  );
});

// Fetch: stale-while-revalidate para GET, ignora el resto
self.addEventListener('fetch', (event) => {
  const req = event.request;

  // Solo cachear GET
  if (req.method !== 'GET') return;

  const url = new URL(req.url);

  // Ignorar esquemas no http(s) (blob:, data:, etc.)
  if (url.protocol !== 'http:' && url.protocol !== 'https:') return;

  // Stale-while-revalidate
  event.respondWith(
    caches.match(req).then((cached) => {
      const fetchPromise = fetch(req)
        .then((response) => {
          // Solo cachear respuestas 200 y de tipo http(s)
          if (response && response.status === 200 && (response.type === 'basic' || response.type === 'cors')) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(req, clone).catch(() => {});
            });
          }
          return response;
        })
        .catch(() => {
          // Si falla el fetch y tenemos cache, devolver cache (incluso si es viejo)
          if (cached) return cached;
          // Si no hay cache y falla el fetch, devolver una respuesta mínima
          return new Response('Offline y sin cachear.', {
            status: 503,
            statusText: 'Service Unavailable',
            headers: { 'Content-Type': 'text/plain; charset=utf-8' }
          });
        });
      // Devolver cache inmediatamente si existe, si no esperar al fetch
      return cached || fetchPromise;
    })
  );
});

// Permitir que el SW tome control inmediatamente en la primer visita
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
