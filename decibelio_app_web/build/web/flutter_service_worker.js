"use strict";
const MANIFEST = "flutter-app-manifest";
const TEMP = "flutter-temp-cache";
const CACHE_NAME = "flutter-app-cache";

const RESOURCES = {
  "favicon.png": "3c0404079db0c570f6092a0209017140",
  "icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
  "icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
  "icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
  "icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
  "assets/NOTICES": "f8cc32705ff873274d1242c8bf5cd868",
  "assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
  "assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
  "assets/fonts/MaterialIcons-Regular.otf": "88bb9469475828ec1f6de36a4732ab90",
  "assets/assets/icons/excel_file.svg": "dc91b258ecf87f5731fb2ab9ae15a3ec",
  "assets/assets/icons/google_drive.svg": "9a3005a58d47a11bfeffc11ddd3567c1",
  "assets/assets/icons/map-marker-svgrepo-com.svg":
    "a23b0eef2d78dda859c807c46f3c9d2b",
  "assets/assets/icons/menu_dashboard.svg": "b2cdf62e9ce9ca35f3fc72f1c1fcc7d4",
  "assets/assets/icons/google_color_svgrepo_com.svg":
    "48d6785e717859f8bb0b49d5927748de",
  "assets/assets/icons/sound_file.svg": "fe212d5edfddd0786319edf50601ec73",
  "assets/assets/icons/folder.svg": "40a82e74e930ac73aa6ccb85d8c5a29c",
  "assets/assets/icons/Documents.svg": "51896b51d35e28711cf4bd218bde185d",
  "assets/assets/icons/pdf_file.svg": "ca854643eeee7bedba7a1d550e2ba94f",
  "assets/assets/icons/menu_notification.svg":
    "460268d6e4bdeab56538d7020cc4b326",
  "assets/assets/icons/menu_profile.svg": "fe56f998a7c1b307809ea3653a1b62f9",
  "assets/assets/icons/menu_tran.svg": "6c95fa7ae6679737dc57efd2ccbb0e57",
  "assets/assets/icons/menu_setting.svg": "d0e24d5d0956729e0e2ab09cb4327e32",
  "assets/assets/icons/Figma_file.svg": "0ae328b79325e7615054aed3147c81f9",
  "assets/assets/icons/xd_file.svg": "38913b108e39bcd55988050d2d80194c",
  "assets/assets/icons/menu_task.svg": "1a02d1c14f49a765da34487d23a3093b",
  "assets/assets/icons/one_drive.svg": "aa908c0a29eb795606799385cdfc8592",
  "assets/assets/icons/menu_store.svg": "2fd4ae47fd0fca084e50a600dda008cd",
  "assets/assets/icons/doc_file.svg": "552a02a5a3dbaee682de14573f0ca9f3",
  "assets/assets/icons/drop_box.svg": "3295157e194179743d6093de9f1ff254",
  "assets/assets/icons/logo.svg": "b3af0c077a73709c992d7e075b76ce33",
  "assets/assets/icons/menu_doc.svg": "09673c2879de2db9646345011dbaa7bb",
  "assets/assets/icons/media.svg": "059dfe46bd2d92e30bf361c2f7055c3b",
  "assets/assets/icons/media_file.svg": "2ac15c968f8a8cea571a0f3e9f238a66",
  "assets/assets/icons/Search.svg": "396d519c18918ed763d741f4ba90243a",
  "assets/assets/icons/unknown.svg": "b2f3cdc507252d75dea079282f14614f",
  "assets/assets/logos/favicon.png": "3c0404079db0c570f6092a0209017140",
  "assets/assets/images/sun-svgrepo-com.png":
    "b92e4e539e9af7c6923a9e722f3bcc64",
  "assets/assets/images/logo.png": "5315be9d0a7602fb12a0ad4c2e3006e9",
  "assets/assets/images/moon-stars-svgrepo-com.png":
    "51419f5659f51f3d025cf48aaebd8e93",
  "assets/AssetManifest.json": "9a6dbd06103f50e15f6e350267b0d691",
  "assets/AssetManifest.bin.json": "f5f6981c187ab74fad227cddf5549788",
  "assets/AssetManifest.bin": "76ad54b13540efae0cb1aa2f229525a2",
  "assets/packages/cupertino_icons/assets/CupertinoIcons.ttf":
    "e986ebe42ef785b27164c36a9abc7818",
  "assets/packages/flutter_map/lib/assets/flutter_map_logo.png":
    "208d63cc917af9713fc9572bd5c09362",
  "assets/packages/flutter_dropzone_web/assets/flutter_dropzone.js":
    "dddc5c70148f56609c3fb6b29929388e",
  "manifest.json": "2f9b2fc37c3c70664b1237606fd374ab",
  "canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
  "canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
  "canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
  "canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
  "canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
  "canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
  "canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
  "canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
  "canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
  "canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
  "main.dart.js": "c0c62aa2b2634a93d38535b5aba29019",
  "index.html": "9b20a4500d2c162cc00dc68883f7f237",
  "/": "9b20a4500d2c162cc00dc68883f7f237",
  "version.json": "82cf3c412ed646eb6828076507a64a0c",
  "flutter_bootstrap.js": "fe2905833bc6a87e3bcb1cc086d871af",
  "flutter.js": "f393d3c16b631f36852323de8e583132",
};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
  "index.html",
  "flutter_bootstrap.js",
  "assets/AssetManifest.bin.json",
  "assets/FontManifest.json",
];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, { cache: "reload" }))
      );
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function (event) {
  return event.waitUntil(
    (async function () {
      try {
        var contentCache = await caches.open(CACHE_NAME);
        var tempCache = await caches.open(TEMP);
        var manifestCache = await caches.open(MANIFEST);
        var manifest = await manifestCache.match("manifest");
        // When there is no prior manifest, clear the entire cache.
        if (!manifest) {
          await caches.delete(CACHE_NAME);
          contentCache = await caches.open(CACHE_NAME);
          for (var request of await tempCache.keys()) {
            var response = await tempCache.match(request);
            await contentCache.put(request, response);
          }
          await caches.delete(TEMP);
          // Save the manifest to make future upgrades efficient.
          await manifestCache.put(
            "manifest",
            new Response(JSON.stringify(RESOURCES))
          );
          // Claim client to enable caching on first launch
          self.clients.claim();
          return;
        }
        var oldManifest = await manifest.json();
        var origin = self.location.origin;
        for (var request of await contentCache.keys()) {
          var key = request.url.substring(origin.length + 1);
          if (key == "") {
            key = "/";
          }
          // If a resource from the old manifest is not in the new cache, or if
          // the MD5 sum has changed, delete it. Otherwise the resource is left
          // in the cache and can be reused by the new service worker.
          if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
            await contentCache.delete(request);
          }
        }
        // Populate the cache with the app shell TEMP files, potentially overwriting
        // cache files preserved above.
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put(
          "manifest",
          new Response(JSON.stringify(RESOURCES))
        );
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      } catch (err) {
        // On an unhandled exception the state of the cache cannot be guaranteed.
        console.error("Failed to upgrade service worker: " + err);
        await caches.delete(CACHE_NAME);
        await caches.delete(TEMP);
        await caches.delete(MANIFEST);
      }
    })()
  );
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf("?v=") != -1) {
    key = key.split("?v=")[0];
  }
  if (
    event.request.url == origin ||
    event.request.url.startsWith(origin + "/#") ||
    key == ""
  ) {
    key = "/";
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == "/") {
    return onlineFirst(event);
  }
  event.respondWith(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return (
          response ||
          fetch(event.request).then((response) => {
            if (response && Boolean(response.ok)) {
              cache.put(event.request, response.clone());
            }
            return response;
          })
        );
      });
    })
  );
});

self.addEventListener("message", (event) => {
  // Verificar el origen del mensaje
  if (event.origin !== self.location.origin) {
    console.warn("Mensaje recibido de un origen no confiable:", event.origin);
    return;
  }
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === "skipWaiting") {
    self.skipWaiting();
    return;
  }
  if (event.data === "downloadOffline") {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request)
      .then((response) => {
        return caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
      .catch((error) => {
        return caches.open(CACHE_NAME).then((cache) => {
          return cache.match(event.request).then((response) => {
            if (response != null) {
              return response;
            }
            throw error;
          });
        });
      })
  );
}
