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
  _foregroundSubscription ??=
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final n = message.notification;
    if (n == null) return; // data-only message, nothing to display

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
          if (n.title != null && n.title!.isNotEmpty)
            Text(n.title!, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (n.body != null && n.body!.isNotEmpty) Text(n.body!),
        ],
      ),
    ));
  });
}

Future<void> requestNotificationPermission() async {
  try {
    await FirebaseMessaging.instance.requestPermission();
  } catch (e) {
    debugPrint('Notification permission failed: $e');
  }
}

Future<void> updateNotificationLanguage(bool english) async {
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
