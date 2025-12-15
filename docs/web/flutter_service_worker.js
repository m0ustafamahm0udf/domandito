'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "3ec829096507d8a8c3fa5ee05b595ff2",
"version.json": "8721656392400567c036b38cb297f715",
"splash/img/light-2x.png": "35d5db5b06e23e93aac53a45cb17c0f3",
"splash/img/dark-4x.png": "b16ba354a9fce1b9f6f0fc3acc812d23",
"splash/img/light-3x.png": "7bf590ec46dd0a18a3199a4627f7c320",
"splash/img/dark-3x.png": "7bf590ec46dd0a18a3199a4627f7c320",
"splash/img/light-4x.png": "b16ba354a9fce1b9f6f0fc3acc812d23",
"splash/img/dark-2x.png": "35d5db5b06e23e93aac53a45cb17c0f3",
"splash/img/dark-1x.png": "41e68ba0cff98347b6f0f8a82bc3bbff",
"splash/img/light-1x.png": "41e68ba0cff98347b6f0f8a82bc3bbff",
"favicon.ico": "056bc06f94553a175b39f031166da80a",
"index.html": "8277b89ccc6975ee9f3795c1fb683164",
"/": "8277b89ccc6975ee9f3795c1fb683164",
"main.dart.js": "9813af33a5dd1fa3c3203a5982fc54a0",
".well-known/apple-app-site-association": "faa53fd65cfcbd726567f42927425bd0",
".well-known/assetlinks.json": "1ab6e1f17e6eaf55d18a611360c0c2b8",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"well-known/apple-app-site-association": "faa53fd65cfcbd726567f42927425bd0",
"well-known/assetlinks.json": "1ab6e1f17e6eaf55d18a611360c0c2b8",
"icons/apple-touch-icon.png": "81136ea36bfbd6b01622cb031b929500",
"icons/icon-192.png": "0cc42bed2e1b2afa7620eba7740a7657",
"icons/Icon-maskable-192.png": "e338e49cae9c6bfdef123a008d661dca",
"icons/Icon-maskable-512.png": "767afb1a72dd2901f66687c70ca05c9f",
"icons/icon-512.png": "03768177f7e908a3a87b954fae9ba86d",
"manifest.json": "593237d3f362d9ad5a0352992995b31b",
"assets/AssetManifest.json": "420b89dc774be099e8670aa67117633a",
"assets/NOTICES": "2644f84e18cec8b5c99d5ede536076d2",
"assets/FontManifest.json": "097f82ad939eab539290fd74cf9486f7",
"assets/AssetManifest.bin.json": "dbf6f97c725ee1197532ebf9be17342e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/iconsax_flutter/fonts/FlutterIconsax.ttf": "6ebc7bc5b74956596611c6774d8beb5b",
"assets/packages/glass/images/noise.png": "326f70bd3633c4bb951eac0da073485d",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "a6bb3c0578ba63c4743b9deefe8db09f",
"assets/fonts/MaterialIcons-Regular.otf": "a4f0910364bc6b4731a9e6d7013fe518",
"assets/assets/images/summer.json": "a33a31b8af822a8eaf095553c7839cac",
"assets/assets/images/loading.json": "0e62236b1a196f9f98a3d4e116e87a52",
"assets/assets/images/delviery.json": "4750013f93b2f594243e41573f014b82",
"assets/assets/images/featchures.png": "cb98f66e5ea4e39a43f5ca4c18cb0fac",
"assets/assets/images/appbar.png": "42cd836abe39d70ae9d6b62171ea6fb9",
"assets/assets/images/splash.png": "f4fcc93a9c8c40f4a0edce5716f83e2a",
"assets/assets/images/logo.png": "767afb1a72dd2901f66687c70ca05c9f",
"assets/assets/images/predict.json": "ae5d408c790e3f98f17878b480d3b35a",
"assets/assets/images/ios.png": "ab3e16c1f1d748925de8c6809f6d2660",
"assets/assets/images/face_loading.json": "4847a8a974abb11703af4831d0c8feb4",
"assets/assets/images/texture.svg": "51b3572f810f3cda4871c8dcd75db7cc",
"assets/assets/images/loading_map.json": "b177ed0550b3aba1638a1a6cf4c44453",
"assets/assets/images/google.png": "807df6ab1bc02d9f60dce077e0300e9d",
"assets/assets/languages/gov.json": "b2b879e9f37020b00bcd4559e614da6b",
"assets/assets/languages/en.json": "3cba1b400a6784f81e4a597a16f756a5",
"assets/assets/languages/ar.json": "45422d2f0f4f2f1a7cb09df61825824e",
"assets/assets/languages/cities.json": "357b4495e988476189e43a9b52c03b7c",
"assets/assets/icons/hand.svg": "cf534f96b63f212927e5ce3b5cfb151e",
"assets/assets/icons/search.svg": "665a91b70f21345eb7ff002252fcc354",
"assets/assets/icons/bed.svg": "88c935c8953c720440018340edd5b3e4",
"assets/assets/icons/bathroom.svg": "3cfb8cca42982cf2173480aa707c338d",
"assets/assets/icons/search_icon.svg": "959b747dd5dbd0a6a4ceba8720c57d48",
"assets/assets/icons/chef-hat-svgrepo-com.svg": "f64e3a48d85337256cf19688f238d879",
"assets/assets/icons/questions.svg": "baafc2f41aff6609db5999886d003b65",
"assets/assets/icons/home.svg": "a6db8299aa801d02eff6c4d4eeae6432",
"assets/assets/icons/logout.svg": "6e6da517ba9c6960190acf969d1fef01",
"assets/assets/icons/verified.svg": "036e85f61bcb7a21414000f90cbf11bb",
"assets/assets/icons/areaa.svg": "f51b747010b4a287de9b8058a5c5c029",
"assets/assets/icons/city.svg": "20e2540ae90ac644bd89120714680dfb",
"assets/assets/icons/terms.svg": "18250dbd7e8a3e5dd346c08d5b8654cc",
"assets/assets/icons/instagram.svg": "375857dc9f0744b9e62945f2179d8b46",
"assets/assets/icons/cart.svg": "6d71a1b1be42bda809fdc56d58a8e70c",
"assets/assets/icons/requested_by.svg": "bdc50e12c40890a238c21ce542007525",
"assets/assets/icons/time.svg": "6b1c89456434d9a8095cb68e90b0c9de",
"assets/assets/icons/pin.svg": "26ea60379afeec0e81034b04f14f84ba",
"assets/assets/icons/air.svg": "9ca36cac46d2fd2d4570f98d4c2c023a",
"assets/assets/icons/direction.svg": "72557ae24bf426c8d4e986825a2994d7",
"assets/assets/icons/check.svg": "61aafcfebe9d834fec674729aa4cd37e",
"assets/assets/icons/warning.svg": "e30cc90f64f1047c9eb3c29d565b5319",
"assets/assets/icons/add_image.svg": "c57005b13bbbe7771ed0a14170453653",
"assets/assets/icons/bed.png": "2c6aaee1a0ee3b44d67d2211150310a2",
"assets/assets/icons/area.svg": "9f8a3f7dbe51f5e6bcf33c6a63e748e1",
"assets/assets/icons/info.svg": "81dbe714efc65d76619415a304c86da3",
"assets/assets/icons/close.svg": "7df018034f301459e66126ac23d5ca93",
"assets/assets/icons/orders.svg": "c90c24bee803ef01ab12b53ffe287a05",
"assets/assets/icons/offers.svg": "4ca93b690fa5505663dc58a79f587da3",
"assets/assets/icons/govern.svg": "0e998b88b2eca8aab2ab0a5d084ab1ad",
"assets/assets/icons/back.svg": "7cab556058315b26cb89c7f2f090dc5d",
"assets/assets/icons/crown.svg": "29ae926fb10e802c0d320eb3229a1c82",
"assets/assets/icons/facebook.svg": "59c2d7268c3c1457e08a99d4df5080e9",
"assets/assets/icons/explore.svg": "2bc6125c6a602367155b79bd8d377827",
"assets/assets/icons/logo.png": "bfe65af3f62a7af09d43976947050ce2",
"assets/assets/icons/furnished.svg": "66a194858db9b60734c77ed2c49662b7",
"assets/assets/icons/whatsapp.svg": "109a35e2ffd49f0abf100c085e682eb0",
"assets/assets/icons/google.svg": "c109830536c767e42727b15f1a3ba98e",
"assets/assets/icons/star.svg": "501be8b6003178369391926fbdce7e20",
"assets/assets/icons/edit.svg": "d8c54b50c1247044fbcdb02e1b3c14a5",
"assets/assets/icons/qr.svg": "321c8e1ff7bd2b85e28c3bf062c67cfa",
"assets/assets/icons/delete.svg": "69337bee96e148526e400b2a411e69ba",
"assets/assets/icons/phone.svg": "ffc51f1db39c65de7852878059704454",
"assets/assets/icons/floor.svg": "bd53b20892b1ed896641edda8d819c19",
"assets/assets/icons/profile.svg": "28fd0acf7e6d7c94972d8538eee018b1",
"assets/assets/icons/share.svg": "405bd734b64c7464d3e0cc04478d6af1",
"assets/assets/icons/sort.svg": "2f612bcf0b00190f0f3f08310022b09b",
"assets/assets/icons/filter.svg": "84e27935ef1150064d162d11e46d2248",
"assets/assets/icons/rate.svg": "bcbae44de7b45cf32a4d3fc9961c89c7",
"assets/assets/icons/notifications.svg": "0324294a7ee048d8aa35d6f1c1e19476",
"assets/assets/icons/anonymous.svg": "83e01db0b0e794fc5aaf563548ca1a5a",
"assets/assets/icons/property.svg": "febc65182205cb5ca43dd038b19ff847",
"assets/assets/icons/apple.svg": "e04cdcbd9c2392878d0597a60e5f4d2d",
"assets/assets/icons/document-add-svgrepo-com.svg": "2d3a1280baf78ce4df6f7fe1bf1640d0",
"assets/assets/icons/privacy.svg": "34f9f88287e9071ebab64585c76b70ed",
"assets/assets/icons/heart.svg": "b73734baa95d4df476d240856483bf51",
"assets/assets/fonts/Dancing_Script/DancingScript-Regular.ttf": "4166d03f2359652b8f239e23578b8232",
"assets/assets/fonts/Rubik/Rubik-Regular.ttf": "77e1892c02dc223f0f258e5038423318",
"assets/assets/fonts/Ruwudu/Ruwudu-Regular.ttf": "9f38e0bf3fbee5ed10706645e24475e1",
"index0.html": "0f720537764fc98f66ca48ae4c9f3c18",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
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
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
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
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
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
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
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
