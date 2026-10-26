// Push-Mitteilungen im Web (Firebase Cloud Messaging).
//
// Stellt window.soccerparkPush bereit, das der Dart-Code aufruft
// (lib/utils/webpush_web.dart). Der Service Worker wird ausdrücklich unter
// seinem echten Pfad neben index.html angemeldet; so funktioniert das auch,
// wenn die App in einem Unterordner liegt (z. B. /app/).
(function () {
  'use strict';

  var SDK = 'https://www.gstatic.com/firebasejs/10.14.1/';

  // Öffentlicher VAPID-Schlüssel (Firebase Console → Projekteinstellungen →
  // Cloud Messaging → Web-Push-Zertifikate).
  var VAPID_KEY =
    'BCQ1VV5wp2ClF_gSKApxFf8P0J95yYf2KFpqgTejLvOpTBWOVISgtDnbcRanc092SnWCbik3PqoraJYJi1CvwLo';

  // Entspricht DefaultFirebaseOptions.web in lib/firebase_options.dart.
  var CONFIG = {
    apiKey: 'AIzaSyB6nfVIu8KSUdAXrke-GJoCtW_0Zkg7-Mc',
    appId: '1:1018336090361:web:b79051b9e59e84158eea28',
    messagingSenderId: '1018336090361',
    projectId: 'soccerpark-aa64d',
    authDomain: 'soccerpark-aa64d.firebaseapp.com',
    storageBucket: 'soccerpark-aa64d.firebasestorage.app'
  };

  // Eigener Bereich, damit sich der Worker nicht mit dem von Flutter
  // (flutter_service_worker.js) in die Quere kommt.
  var SW_PATH = 'firebase-messaging-sw.js';
  var SW_SCOPE = 'firebase-cloud-messaging-push-scope';

  var ready = null;

  function load() {
    if (!ready) {
      ready = Promise.all([
        import(SDK + 'firebase-app.js'),
        import(SDK + 'firebase-messaging.js')
      ]).then(function (mods) {
        var app = mods[0].initializeApp(CONFIG);
        var m = mods[1];
        var messaging = m.getMessaging(app);
        // Mitteilung, während die App offen ist: an Dart weitergeben.
        m.onMessage(messaging, function (payload) {
          var n = payload.notification || {};
          var d = payload.data || {};
          var cb = window.soccerparkPush.onForeground;
          if (typeof cb === 'function') cb(n.title || '', n.body || '', String(d.news || ''));
        });
        return { m: m, messaging: messaging };
      });
      ready.catch(function () { ready = null; });
    }
    return ready;
  }

  function waitActive(reg) {
    if (reg.active) return Promise.resolve(reg);
    var sw = reg.installing || reg.waiting;
    return new Promise(function (resolve) {
      if (!sw) return resolve(reg);
      sw.addEventListener('statechange', function () {
        if (sw.state === 'activated') resolve(reg);
      });
    });
  }

  function getToken() {
    return navigator.serviceWorker
      .register(SW_PATH, { scope: SW_SCOPE })
      .then(waitActive)
      .then(function (reg) {
        return load().then(function (fb) {
          return fb.m.getToken(fb.messaging, {
            vapidKey: VAPID_KEY,
            serviceWorkerRegistration: reg
          });
        });
      });
  }

  // Mitteilung angetippt, während die App offen ist: der Service Worker
  // schickt die Beitragsnummer hierher.
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.addEventListener('message', function (event) {
      var msg = event.data || {};
      var cb = window.soccerparkPush && window.soccerparkPush.onOpenNews;
      if (msg.type === 'soccerpark-news' && typeof cb === 'function') {
        cb(String(msg.id));
      }
    });
  }

  window.soccerparkPush = {
    onForeground: null,
    onOpenNews: null,

    // true, wenn dieser Browser Push kann. Auf dem iPhone erst, wenn die App
    // über „Zum Home-Bildschirm“ installiert ist.
    supported: function () {
      if (!('serviceWorker' in navigator) || !('Notification' in window) ||
          !('PushManager' in window)) {
        return Promise.resolve(false);
      }
      return import(SDK + 'firebase-messaging.js')
        .then(function (m) { return m.isSupported(); })
        .catch(function () { return false; });
    },

    // 'default' (noch nicht gefragt), 'granted', 'denied' oder 'unsupported'.
    permission: function () {
      return 'Notification' in window ? Notification.permission : 'unsupported';
    },

    // Fragt nach der Erlaubnis (nur nach einem Tipp aufrufen!) und liefert
    // den Geräte-Token, oder '' wenn abgelehnt.
    enable: function () {
      return Notification.requestPermission().then(function (p) {
        return p === 'granted' ? getToken() : '';
      });
    },

    // Token ohne Nachfrage, falls die Erlaubnis schon besteht (beim Start).
    token: function () {
      if (!('Notification' in window) || Notification.permission !== 'granted') {
        return Promise.resolve('');
      }
      return getToken().catch(function () { return ''; });
    }
  };
})();
