import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'supabase_config.dart';

/// Ein Eintrag der monatlichen Online-Bestenliste.
class OnlineHighscore {
  OnlineHighscore(this.id, this.name, this.total, this.holes, this.createdAt);

  final int id;
  final String name;
  final int total;
  final List<int> holes;
  final DateTime createdAt;

  static OnlineHighscore fromJson(Map<String, dynamic> json) {
    return OnlineHighscore(
      (json['id'] as num).toInt(),
      json['name'] as String,
      (json['total'] as num).toInt(),
      (json['holes'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}

class OnlineHighscoreException implements Exception {
  OnlineHighscoreException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'OnlineHighscoreException($statusCode): $body';
}

/// Zugriff auf die monatlichen Online-Highscores (Supabase REST API).
///
/// Es werden pro Anlage und Monat nur die Top [listSize] gespeichert;
/// das Aufräumen erledigt die Datenbankfunktion submit_highscore().
class OnlineHighscores {
  static const int listSize = 50;

  /// Gespeicherte Einträge der Tageswertung (nur der aktuelle Tag).
  static const int daySize = 20;

  /// So viele Einträge zeigt die Bestenliste, bevor man "Alle" antippt.
  static const int previewSize = 10;
  static const int minNameLength = 2;
  static const int maxNameLength = 20;
  static const Duration _timeout = Duration(seconds: 10);
  static const String _namesKey = 'onlineHighscoreNames';

  static bool get isConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  static String localityKey(Locality loc) {
    if (loc == Locality.SALZBURG) return 'salzburg';
    if (loc == Locality.WAGRAIN) return 'wagrain';
    return 'goldberg';
  }

  /// Aktueller Monat im Format yyyy-MM.
  static String currentMonth() => DateFormat('yyyy-MM').format(DateTime.now());

  /// Heutiger Tag im Format yyyy-MM-dd.
  static String currentDay() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Monatsname zur Anzeige, z. B. "Oktober 2026".
  static String monthLabel(String month, String languageCode) {
    try {
      final date = DateTime.parse('$month-01');
      return DateFormat.yMMMM(languageCode).format(date);
    } catch (_) {
      return month;
    }
  }

  // ------------------------------------------------------------------
  // Ranglogik
  // ------------------------------------------------------------------

  /// Angezeigter Platz für [total] Schläge (gleiche Schlagzahl = gleicher
  /// Platz), oder null, wenn die Runde nicht in die Top [listSize] kommt.
  /// Bei Gleichstand liegt der frühere Eintrag vorne, daher reicht eine
  /// Schlagzahl, die schon auf Platz 10 steht, nicht.
  static int? prospectiveRank(List<OnlineHighscore> list, int total,
      {int size = listSize}) {
    final atLeastAsGood = list.where((e) => e.total <= total).length;
    if (atLeastAsGood >= size) return null;
    return list.where((e) => e.total < total).length + 1;
  }

  /// Plätze für eine sortierte Liste (gleiche Schlagzahl = gleicher Platz).
  static List<int> displayRanks(List<OnlineHighscore> list) {
    final ranks = <int>[];
    for (var i = 0; i < list.length; i++) {
      if (i > 0 && list[i].total == list[i - 1].total) {
        ranks.add(ranks[i - 1]);
      } else {
        ranks.add(i + 1);
      }
    }
    return ranks;
  }

  // ------------------------------------------------------------------
  // Server
  // ------------------------------------------------------------------

  static Map<String, String> _headers({bool jsonBody = false}) {
    final key = supabaseAnonKey.trim();
    final headers = <String, String>{
      'apikey': key,
      'Accept': 'application/json',
    };
    // Alte "anon"-Keys sind JWTs und werden zusätzlich als Bearer-Token
    // erwartet; neue "publishable"-Keys (sb_publishable_...) nicht.
    if (!key.startsWith('sb_')) headers['Authorization'] = 'Bearer $key';
    if (jsonBody) headers['Content-Type'] = 'application/json';
    return headers;
  }

  static Uri _uri(String path, [Map<String, String>? query]) {
    var base = supabaseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  static dynamic _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw OnlineHighscoreException(res.statusCode, res.body);
    }
    if (res.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  /// Top [listSize] einer Anlage für [month] (yyyy-MM), beste zuerst.
  static Future<List<OnlineHighscore>> fetch(Locality loc, String month) async {
    final res = await http
        .get(
            _uri('/rest/v1/online_highscores', {
              'select': 'id,name,total,holes,created_at',
              'locality': 'eq.${localityKey(loc)}',
              'month': 'eq.$month',
              'order': 'total.asc,created_at.asc,id.asc',
              'limit': '$listSize',
            }),
            headers: _headers())
        .timeout(_timeout);
    final list = _decode(res) as List<dynamic>;
    return list
        .map((e) => OnlineHighscore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tageswertung einer Anlage für [day] (yyyy-MM-dd), beste zuerst.
  static Future<List<OnlineHighscore>> fetchDay(Locality loc, String day) async {
    final res = await http
        .get(
            _uri('/rest/v1/online_highscores', {
              'select': 'id,name,total,holes,created_at',
              'locality': 'eq.${localityKey(loc)}',
              'day': 'eq.$day',
              'order': 'total.asc,created_at.asc,id.asc',
              'limit': '$daySize',
            }),
            headers: _headers())
        .timeout(_timeout);
    final list = _decode(res) as List<dynamic>;
    return list
        .map((e) => OnlineHighscore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Alle Monate mit Einträgen für eine Anlage, neueste zuerst.
  /// Der aktuelle Monat ist immer enthalten.
  static Future<List<String>> fetchMonths(Locality loc) async {
    final res = await http
        .get(
            _uri('/rest/v1/online_highscores', {
              'select': 'month',
              'locality': 'eq.${localityKey(loc)}',
              'order': 'month.desc',
            }),
            headers: _headers())
        .timeout(_timeout);
    final list = _decode(res) as List<dynamic>;
    final months = <String>{currentMonth()};
    for (final e in list) {
      months.add((e as Map<String, dynamic>)['month'] as String);
    }
    final sorted = months.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  /// Trägt eine volle Runde (18 Löcher) ein. Liefert die erreichten Plätze
  /// in Monats- und Tageswertung (null = nicht bzw. nicht mehr drin).
  static Future<({int? month, int? day})> submit(
      Locality loc, String name, List<int> holes) async {
    final res = await http
        .post(_uri('/rest/v1/rpc/submit_highscore'),
            headers: _headers(jsonBody: true),
            body: jsonEncode({
              'p_locality': localityKey(loc),
              'p_name': sanitizeName(name),
              'p_holes': holes,
            }))
        .timeout(_timeout);
    final result = _decode(res);
    if (result is Map<String, dynamic>) {
      int? read(String key) =>
          result[key] == null ? null : (result[key] as num).toInt();
      return (month: read('month_rank'), day: read('day_rank'));
    }
    // Ältere Server-Funktion (nur Monatsplatz als Zahl).
    if (result is num) return (month: result.toInt(), day: null);
    return (month: null, day: null);
  }

  // ------------------------------------------------------------------
  // Gespeicherte Online-Namen (lokaler Spielername -> Anzeigename)
  // ------------------------------------------------------------------

  static String sanitizeName(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ');

  static bool isValidName(String name) {
    final n = sanitizeName(name);
    return n.length >= minNameLength && n.length <= maxNameLength;
  }

  static String _nameKey(String playerName) =>
      sanitizeName(playerName).toLowerCase();

  static Future<Map<String, String>> _loadNames(SharedPreferences prefs) async {
    final str = prefs.getString(_namesKey);
    if (str == null) return {};
    try {
      return (jsonDecode(str) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }

  /// Vorschlag für den Anzeigenamen: zuletzt verwendeter Online-Name dieses
  /// Spielers, sonst sein Name aus der Runde.
  static Future<String> suggestedName(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    final names = await _loadNames(prefs);
    final saved = names[_nameKey(playerName)];
    if (saved != null && saved.isNotEmpty) return saved;
    final n = sanitizeName(playerName);
    return n.length > maxNameLength ? n.substring(0, maxNameLength) : n;
  }

  static Future<void> saveName(String playerName, String onlineName) async {
    final prefs = await SharedPreferences.getInstance();
    final names = await _loadNames(prefs);
    names[_nameKey(playerName)] = sanitizeName(onlineName);
    await prefs.setString(_namesKey, jsonEncode(names));
  }
}
