import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'firebase.dart' show showInAppNotification;
import 'supabase_config.dart';

// Brücke zu window.soccerparkPush (web/push.js).

@JS('soccerparkPush.supported')
external JSPromise<JSBoolean> _supported();

@JS('soccerparkPush.permission')
external JSString _permission();

@JS('soccerparkPush.enable')
external JSPromise<JSString> _enable();

@JS('soccerparkPush.token')
external JSPromise<JSString> _token();

@JS('soccerparkPush.onForeground')
external set _onForeground(JSFunction callback);

const _tokenKey = 'webPushToken';

/// Zuletzt erfolgreich angemeldet: "<token>|<thema>".
const _subscribedKey = 'webPushSubscribed';

/// In der App abgeschaltet (Browser-Erlaubnis bleibt bestehen).
const _disabledKey = 'webPushDisabled';

/// Mitteilungen aktiv: Browser erlaubt sie und sie sind nicht in der App
/// abgeschaltet.
Future<bool> webPushEnabled() async {
  if (webPushPermission() != 'granted') return false;
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_disabledKey) ?? false);
}

Future<bool> _isDisabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_disabledKey) ?? false;
}

/// In der App abschalten: bei allen Themen abmelden. Die Erlaubnis im
/// Browser bleibt (eine Website kann sie nicht zurückgeben); "Aktivieren"
/// meldet ohne erneute Nachfrage wieder an.
Future<bool> disableWebPush() async {
  final prefs = await SharedPreferences.getInstance();
  final token = await storedWebPushToken();
  final prefix = kDebugMode ? 'dev_' : '';
  final ok = token.isEmpty ||
      await _callTopics({
        'token': token,
        'remove': ['${prefix}lang_de', '${prefix}lang_en'],
      });
  if (ok) {
    await prefs.setBool(_disabledKey, true);
    await prefs.remove(_subscribedKey);
  }
  return ok;
}

/// Kann dieser Browser Push? (iPhone: nur als installierte App.)
Future<bool> webPushSupported() async {
  try {
    return (await _supported().toDart).toDart;
  } catch (e) {
    debugPrint('Web push not available: $e');
    return false;
  }
}

/// 'default', 'granted', 'denied' oder 'unsupported'.
String webPushPermission() {
  try {
    return _permission().toDart;
  } catch (_) {
    return 'unsupported';
  }
}

/// Nach einem Tipp aufrufen: fragt nach der Erlaubnis und liefert den
/// Geräte-Token ('' = abgelehnt oder Fehler).
Future<String> enableWebPush() async {
  try {
    final token = (await _enable().toDart).toDart;
    await _storeToken(token);
    if (token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_disabledKey);
      await _subscribe(token, await Data.isEnglish());
    }
    return token;
  } catch (e) {
    debugPrint('Enabling web push failed: $e');
    return '';
  }
}

/// Beim App-Start: Anzeige während die App offen ist einrichten und, falls
/// die Erlaubnis schon besteht, den (ggf. erneuerten) Token holen.
Future<void> initWebPush() async {
  try {
    _onForeground = ((JSString title, JSString body) {
      showInAppNotification(title.toDart, body.toDart);
    }).toJS;
    if (webPushPermission() == 'granted' && !await _isDisabled()) {
      final token = (await _token().toDart).toDart;
      await _storeToken(token);
      if (token.isNotEmpty) {
        await _subscribe(token, await Data.isEnglish());
      }
    }
  } catch (e) {
    debugPrint('Web push init failed: $e');
  }
}

/// Zuletzt bekannter Token (zum Testen, z. B. "Testnachricht senden" in der
/// Firebase Console). Später für die Anmeldung bei den Themen gebraucht.
Future<String> storedWebPushToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_tokenKey) ?? '';
}

Future<void> _storeToken(String token) async {
  if (token.isEmpty) return;
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString(_tokenKey) != token) {
    await prefs.setString(_tokenKey, token);
    debugPrint('Web push token: $token');
  }
}

/// Nach einem Sprachwechsel: Token beim passenden Thema anmelden.
Future<void> webPushSetLanguage(bool english) async {
  if (webPushPermission() != 'granted' || await _isDisabled()) return;
  final token = await storedWebPushToken();
  if (token.isNotEmpty) await _subscribe(token, english);
}

/// Meldet den Token über die Supabase-Funktion "push-topics" beim Thema
/// lang_de bzw. lang_en an (Browser können das nicht selbst). Wie bei
/// Android nutzen Debug-Builds eigene Themen (dev_…).
Future<void> _subscribe(String token, bool english) async {
  if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) return;
  final prefix = kDebugMode ? 'dev_' : '';
  final topic = '${prefix}lang_${english ? 'en' : 'de'}';
  final other = '${prefix}lang_${english ? 'de' : 'en'}';

  final prefs = await SharedPreferences.getInstance();
  final marker = '$token|$topic';
  if (prefs.getString(_subscribedKey) == marker) return; // schon erledigt

  if (await _callTopics({
    'token': token,
    'topic': topic,
    'remove': [other],
  })) {
    await prefs.setString(_subscribedKey, marker);
    debugPrint('Web push subscribed to $topic');
  }
}

/// Ruft die Supabase-Funktion "push-topics" auf; true bei Erfolg.
Future<bool> _callTopics(Map<String, Object> body) async {
  if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) {
    return false;
  }
  var base = supabaseUrl.trim();
  while (base.endsWith('/')) {
    base = base.substring(0, base.length - 1);
  }
  final key = supabaseAnonKey.trim();
  try {
    final res = await http
        .post(Uri.parse('$base/functions/v1/push-topics'),
            headers: {
              'apikey': key,
              // Alte "anon"-Keys sind JWTs und werden auch als Bearer erwartet.
              if (!key.startsWith('sb_')) 'Authorization': 'Bearer $key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 200 && res.statusCode < 300) return true;
    debugPrint('Web push topics failed (${res.statusCode}): ${res.body}');
    return false;
  } catch (e) {
    // Offline o. Ä.: beim nächsten Start erneut versuchen.
    debugPrint('Web push topics failed: $e');
    return false;
  }
}
