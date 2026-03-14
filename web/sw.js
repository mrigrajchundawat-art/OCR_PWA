// OCR PWA - Service Worker
// Handles Web Share Target: receives shared images, stores in cache, redirects to app
const SHARE_CACHE = 'ocr-shared-image';

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(clients.claim());
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Serve shared image from cache when app requests it
  if (url.pathname.endsWith('/__shared-image__') && event.request.method === 'GET') {
    event.respondWith(
      caches.open(SHARE_CACHE).then((cache) =>
        cache.match('/__shared-image__').then((response) => {
          if (response) return response;
          return new Response(null, { status: 404 });
        })
      )
    );
    return;
  }

  // Handle share target POST
  if (url.pathname.endsWith('/share-target') && event.request.method === 'POST') {
    event.respondWith(
      event.request.formData().then((formData) => {
        const file = formData.get('sharedimages');
        if (!file || !file.type.startsWith('image/')) {
          return Response.redirect(url.origin + '/?error=no_image', 303);
        }
        return caches.open(SHARE_CACHE).then((cache) => {
          cache.delete('/__shared-image__');
          const headers = new Headers({ 'Content-Type': file.type });
          return cache.put('/__shared-image__', new Response(file, { headers }));
        }).then(() => Response.redirect(url.origin + '/?shared=1', 303));
      }).catch(() => Response.redirect(url.origin + '/?error=share_failed', 303))
    );
    return;
  }

  // Pass through all other requests
  event.respondWith(fetch(event.request));
});
