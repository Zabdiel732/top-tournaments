const CACHE_NAME = 'tv-v2';
const STATIC_ASSETS = [
  './index.html',
  './app.js',
  './styles.css',
  './manifest.json',
  './logo.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS))
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  event.respondWith(caches.match(event.request).then((response) => response || fetch(event.request).then((networkResponse) => {
    const copy = networkResponse.clone();
    caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
    return networkResponse;
  }).catch(() => caches.match('./index.html'))));
});

self.addEventListener('activate', (event) => event.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))))));