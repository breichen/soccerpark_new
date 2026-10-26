// Service Worker für Push-Mitteilungen (Firebase Cloud Messaging) im Web.
//
// Empfängt Mitteilungen, während die App geschlossen oder im Hintergrund ist,
// und zeigt sie an. Ist die App offen, kümmert sich der Dart-Code darum
// (lib/utils/firebase.dart).
//
// Diese Datei wird beim "flutter build web" nach build/web kopiert.
// Die Werte unten entsprechen DefaultFirebaseOptions.web in
// lib/firebase_options.dart; nach "flutterfire configure" hier abgleichen.

// Adresse der App (Ordner, in dem diese Datei liegt). Wird geöffnet, wenn
// man auf eine Mitteilung tippt und die Mitteilung keinen eigenen Link hat.
const APP_URL = new URL('./', self.location.href).href;

// Antippen einer Mitteilung: offenes App-Fenster nach vorne holen, sonst
// die App (bzw. den Link aus der Mitteilung) öffnen. Muss vor dem Laden
// des Firebase-SDKs registriert werden, damit es Vorrang hat.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.stopImmediatePropagation();

  const fcm = (event.notification.data && event.notification.data.FCM_MSG) || {};
  const link =
    (fcm.fcmOptions && fcm.fcmOptions.link) ||
    (fcm.data && fcm.data.link) ||
    APP_URL;

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windows) => {
      for (const w of windows) {
        if (w.url.startsWith(APP_URL) && 'focus' in w) return w.focus();
      }
      return clients.openWindow(link);
    })
  );
});

importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyB6nfVIu8KSUdAXrke-GJoCtW_0Zkg7-Mc',
  appId: '1:1018336090361:web:b79051b9e59e84158eea28',
  messagingSenderId: '1018336090361',
  projectId: 'soccerpark-aa64d',
  authDomain: 'soccerpark-aa64d.firebaseapp.com',
  storageBucket: 'soccerpark-aa64d.firebasestorage.app',
});

// Mitteilungen mit Titel/Text (z. B. aus der Firebase Console) zeigt das
// SDK im Hintergrund automatisch an; dafür ist kein weiterer Code nötig.
firebase.messaging();
