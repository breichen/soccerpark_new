import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:soccerpark/generated/app_localizations.dart';

import '../pages/newspage.dart' show NewsDetailPage;
import 'webpush_stub.dart' if (dart.library.js_interop) 'webpush_web.dart';

/// Attach this to MaterialApp(scaffoldMessengerKey: ...) so notifications
/// received while the app is open can be shown without a BuildContext.
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// MaterialApp(navigatorKey: ...): zum Öffnen eines Beitrags aus einer
/// Mitteilung, ohne BuildContext.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

StreamSubscription<RemoteMessage>? _foregroundSubscription;
StreamSubscription<RemoteMessage>? _openedSubscription;

/// Nummer des Beitrags aus den Mitteilungsdaten ("news": "7"), sonst null.
int? newsIdFromData(Map<String, dynamic> data) =>
    int.tryParse('${data['news'] ?? ''}'.trim());

/// FCM only shows notifications automatically when the app is in the
/// background. While the app is open, we show a banner ourselves.
/// Call once after Firebase.initializeApp().
void listenForForegroundNotifications() {
  if (kIsWeb) return; // Web: siehe utils/webpush_web.dart
  _foregroundSubscription ??=
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final n = message.notification;
    if (n == null) return; // data-only message, nothing to display
    showInAppNotification(n.title ?? '', n.body ?? '',
        newsId: newsIdFromData(message.data));
  });
}

/// Antippen einer Mitteilung (Android/iOS): enthält sie eine Beitragsnummer,
/// den Beitrag öffnen. Deckt beide Fälle ab: App lief im Hintergrund bzw.
/// wurde durch das Antippen erst gestartet.
void listenForNotificationTaps() {
  if (kIsWeb) return; // Web: Service Worker + utils/webpush_web.dart
  void handle(RemoteMessage message) {
    final id = newsIdFromData(message.data);
    if (id == null) return;
    openNewsFromNotification(id,
        title: message.notification?.title, body: message.notification?.body);
  }

  _openedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(handle);
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) handle(message);
  }).catchError((Object e) {
    debugPrint('Initial message failed: $e');
  });
}

/// Öffnet den Beitrag [id]; wartet kurz, falls die App gerade erst startet.
void openNewsFromNotification(int id,
    {String? title, String? body, int attempt = 0}) {
  final navigator = appNavigatorKey.currentState;
  if (navigator == null) {
    if (attempt < 20) {
      Future.delayed(const Duration(milliseconds: 250),
          () => openNewsFromNotification(id,
              title: title, body: body, attempt: attempt + 1));
    }
    return;
  }
  navigator.push(MaterialPageRoute(
      builder: (context) => NewsDetailPage(id,
          fallbackTitle: title, fallbackBody: body)));
}

/// Zeigt eine Mitteilung als Banner in der App (wenn sie gerade offen ist).
/// Wird von Android/iOS (oben) und vom Web (utils/webpush_web.dart) genutzt.
/// Mit [newsId] gibt es den Knopf "Ansehen".
void showInAppNotification(String title, String body, {int? newsId}) {
  if (title.isEmpty && body.isEmpty) return;
  final messenger = messengerKey.currentState;
  if (messenger == null) return;
  final ctx = messengerKey.currentContext;
  final l = ctx == null ? null : AppLocalizations.of(ctx);

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    duration: const Duration(seconds: 8),
    behavior: SnackBarBehavior.floating,
    showCloseIcon: newsId == null,
    action: newsId == null
        ? null
        : SnackBarAction(
            label: l?.news_view ?? 'OK',
            onPressed: () =>
                openNewsFromNotification(newsId, title: title, body: body)),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (body.isNotEmpty) Text(body),
      ],
    ),
  ));
}

Future<void> requestNotificationPermission() async {
  if (kIsWeb) return;
  try {
    await FirebaseMessaging.instance.requestPermission();
  } catch (e) {
    debugPrint('Notification permission failed: $e');
  }
}

Future<void> updateNotificationLanguage(bool english) async {
  if (kIsWeb) {
    // Browser können keine Themen abonnieren: läuft über den Server.
    await webPushSetLanguage(english);
    return;
  }
  // Debug builds use separate topics, so tests never reach real users.
  final prefix = kDebugMode ? 'dev_' : '';
  final lang = english ? 'en' : 'de';
  final other = english ? 'de' : 'en';
  try {
    final messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic('${prefix}lang_$lang');
    await messaging.unsubscribeFromTopic('${prefix}lang_$other');
  } catch (e) {
    // e.g. offline, or the APNs token isn't ready yet on iOS; the next
    // app start or language change tries again.
    debugPrint('Topic update failed: $e');
  }
}
