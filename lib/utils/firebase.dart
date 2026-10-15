import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
