import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Attach this to MaterialApp(scaffoldMessengerKey: ...) so notifications
/// received while the app is open can be shown without a BuildContext.
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

StreamSubscription<RemoteMessage>? _foregroundSubscription;

/// FCM only shows notifications automatically when the app is in the
/// background. While the app is open, we show a banner ourselves.
/// Call once after Firebase.initializeApp().
void listenForForegroundNotifications() {
  if (kIsWeb) return; // push is only set up for Android/iOS
  _foregroundSubscription ??=
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final n = message.notification;
    if (n == null) return; // data-only message, nothing to display
    showInAppNotification(n.title ?? '', n.body ?? '');
  });
}

/// Zeigt eine Mitteilung als Banner in der App (wenn sie gerade offen ist).
/// Wird von Android/iOS (oben) und vom Web (utils/webpush_web.dart) genutzt.
void showInAppNotification(String title, String body) {
  if (title.isEmpty && body.isEmpty) return;
  final messenger = messengerKey.currentState;
  if (messenger == null) return;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    duration: const Duration(seconds: 8),
    behavior: SnackBarBehavior.floating,
    showCloseIcon: true,
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
  if (kIsWeb) return; // topics are not supported by firebase_messaging on web
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
