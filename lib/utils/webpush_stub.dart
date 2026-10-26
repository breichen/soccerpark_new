/// Android/iOS: Push läuft dort über firebase_messaging (utils/firebase.dart).
/// Diese Funktionen gibt es nur im Web; hier tun sie nichts.

Future<bool> webPushSupported() async => false;

String webPushPermission() => 'unsupported';

Future<String> enableWebPush() async => '';

Future<void> initWebPush() async {}

Future<String> storedWebPushToken() async => '';

Future<void> webPushSetLanguage(bool english) async {}
