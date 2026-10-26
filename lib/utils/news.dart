import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'online_highscores.dart';

/// Ein Beitrag aus der Supabase-Tabelle "news" (siehe supabase/news.sql).
class NewsItem {
  NewsItem(
      {required this.id,
      required this.title,
      required this.body,
      required this.date,
      this.imageUrl,
      this.linkUrl});

  final int id;
  final String title;
  final String body;
  final DateTime date;
  final String? imageUrl;
  final String? linkUrl;

  /// Englisch, falls vorhanden, sonst Deutsch.
  static NewsItem fromJson(Map<String, dynamic> j, {required bool english}) {
    String? text(String key) {
      final v = j[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    return NewsItem(
      id: (j['id'] as num).toInt(),
      title: (english ? text('title_en') : null) ?? text('title_de') ?? '',
      body: (english ? text('body_en') : null) ?? text('body_de') ?? '',
      date: DateTime.parse(j['visible_from'] as String).toLocal(),
      imageUrl: text('image_url'),
      linkUrl: text('link_url'),
    );
  }
}

/// Laden der Neuigkeiten und Merken, was schon gelesen wurde.
class News {
  static const _seenKey = 'newsSeen';
  static const _timeout = Duration(seconds: 10);
  static const _fields =
      'id,title_de,body_de,title_en,body_en,image_url,link_url,visible_from';

  static bool get isConfigured => OnlineHighscores.isConfigured;

  /// Aktuelle Beiträge für die Anlage (und für alle Anlagen), neueste zuerst.
  /// Abgelaufene liefert Supabase gar nicht aus.
  static Future<List<NewsItem>> fetch(Locality loc) async {
    if (!isConfigured) return [];
    final english = await Data.isEnglish();
    final res = await http
        .get(
            OnlineHighscores.restUri('/rest/v1/news', {
              'select': _fields,
              'or':
                  '(locality.is.null,locality.eq.${OnlineHighscores.localityKey(loc)})',
              'order': 'visible_from.desc,id.desc',
              'limit': '30',
            }),
            headers: OnlineHighscores.restHeaders())
        .timeout(_timeout);
    final list = OnlineHighscores.restDecode(res) as List<dynamic>;
    return list
        .map((e) =>
            NewsItem.fromJson(e as Map<String, dynamic>, english: english))
        .toList();
  }

  /// Einzelner Beitrag (z. B. aus einer Mitteilung); null, wenn er nicht
  /// (mehr) sichtbar ist.
  static Future<NewsItem?> fetchOne(int id) async {
    if (!isConfigured) return null;
    final english = await Data.isEnglish();
    final res = await http
        .get(
            OnlineHighscores.restUri('/rest/v1/news', {
              'select': _fields,
              'id': 'eq.$id',
              'limit': '1',
            }),
            headers: OnlineHighscores.restHeaders())
        .timeout(_timeout);
    final list = OnlineHighscores.restDecode(res) as List<dynamic>;
    if (list.isEmpty) return null;
    return NewsItem.fromJson(list.first as Map<String, dynamic>,
        english: english);
  }

  static Future<Set<int>> seenIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_seenKey) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  static Future<void> markSeen(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_seenKey) ?? []).toSet()..add('$id');
    // Liste klein halten: nur die letzten 200 merken.
    final list = ids.toList();
    await prefs.setStringList(
        _seenKey, list.length > 200 ? list.sublist(list.length - 200) : list);
  }
}
