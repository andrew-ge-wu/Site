// CircuitWall Site Service Worker
// Network-first for HTML so visitors always get the freshest fingerprinted CSS/JS.
// Cache-first only for fingerprinted/static assets (images, fonts, hashed bundles).

const VERSION = 'v3.0.0-2026-05-07';
const HTML_CACHE = `cw-html-${VERSION}`;
const ASSET_CACHE = `cw-asset-${VERSION}`;
const OFFLINE_URL = '/offline.html';

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(HTML_CACHE)
      .then((cache) => cache.add(new Request(OFFLINE_URL, { cache: 'reload' })))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((names) => Promise.all(
        names
          .filter((n) => n !== HTML_CACHE && n !== ASSET_CACHE)
          .map((n) => caches.delete(n))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') self.skipWaiting();
});

const isHTMLRequest = (request) => {
  if (request.mode === 'navigate') return true;
  const accept = request.headers.get('accept') || '';
  return accept.includes('text/html');
};

const isHashedAsset = (url) =>
  /\.[0-9a-f]{16,}\.(css|js|woff2?|ttf|eot|otf|svg|png|jpg|jpeg|webp|avif)$/i.test(url.pathname);

const isStaticAsset = (url) =>
  /\.(css|js|woff2?|ttf|eot|otf|svg|png|jpg|jpeg|webp|avif|ico)$/i.test(url.pathname);

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  // HTML: network-first, fall back to cache, then offline page.
  if (isHTMLRequest(request)) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(HTML_CACHE).then((cache) => cache.put(request, copy));
          return response;
        })
        .catch(() => caches.match(request).then((r) => r || caches.match(OFFLINE_URL)))
    );
    return;
  }

  // Hashed assets: cache-first forever (filename invalidates on change).
  // Other static assets: stale-while-revalidate.
  if (isStaticAsset(url)) {
    const cacheFirst = isHashedAsset(url);
    event.respondWith(
      caches.match(request).then((cached) => {
        const network = fetch(request)
          .then((response) => {
            if (response && response.status === 200 && response.type === 'basic') {
              const copy = response.clone();
              caches.open(ASSET_CACHE).then((cache) => cache.put(request, copy));
            }
            return response;
          })
          .catch(() => cached);
        return cacheFirst && cached ? cached : (cached || network);
      })
    );
    return;
  }

  // Everything else: just go to network.
});
