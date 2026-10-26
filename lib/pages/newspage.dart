import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/news.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart' show ContactCard;
import '../widgets/space.dart';

final _dateFormat = DateFormat('dd.MM.yyyy');

/// Liste der aktuellen Neuigkeiten der Anlage.
class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsItem>? items;
  Set<int> seen = {};
  bool error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  Future<void> load() async {
    try {
      final list = await News.fetch(App.of(context).getLocality());
      final s = await News.seenIds();
      if (!mounted) return;
      setState(() {
        items = list;
        seen = s;
        error = false;
      });
    } catch (e) {
      debugPrint('Loading news failed: $e');
      if (!mounted) return;
      setState(() => error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    Widget body;
    if (error) {
      body = message(l.news_load_error);
    } else if (items == null) {
      body = Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()));
    } else if (items!.isEmpty) {
      body = message(l.news_empty);
    } else {
      final children = <Widget>[];
      for (var i = 0; i < items!.length; i++) {
        if (i > 0) {
          children.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
        }
        children.add(newsRow(items![i]));
      }
      body = Container(
          margin: EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: children));
    }

    return Scaffold(
        appBar: CustomAppBar(context, l.news_title, MenuItemE.COUNT, []),
        body: RefreshIndicator(
            onRefresh: load, child: ListView(children: [body])));
  }

  Widget message(String text) => Padding(
      padding: EdgeInsets.all(24),
      child: Text(text,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(color: Colors.grey[700], fontSize: 15)));

  Widget newsRow(NewsItem item) {
    final unread = !seen.contains(item.id);
    return Material(
        color: Colors.white,
        child: InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewsDetailPage(item.id, item: item)));
              final s = await News.seenIds();
              if (mounted) setState(() => seen = s);
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          if (unread) ...[
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: maincolor, shape: BoxShape.circle)),
                            SpaceH(6),
                          ],
                          Text(_dateFormat.format(item.date),
                              style: GoogleFonts.lato(
                                  color: Colors.grey[600], fontSize: 12)),
                        ]),
                        Space(2),
                        Text(item.title,
                            style: GoogleFonts.lato(
                                color: unread ? maincolor : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        if (item.body.isNotEmpty) ...[
                          Space(2),
                          Text(item.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                  height: 1.35)),
                        ],
                      ])),
                  Icon(Icons.chevron_right, color: Colors.grey[500]),
                ]))));
  }
}

/// Vorlage für einen Beitrag: Datum, Überschrift, Bild, Text, Link.
///
/// Lädt den Beitrag aus Supabase (ist [item] schon bekannt, wird er sofort
/// gezeigt). Ist er nicht mehr sichtbar oder fehlt das Netz, zeigt die
/// Seite Titel und Text aus der Mitteilung ([fallbackTitle]/[fallbackBody]),
/// sonst einen Hinweis.
class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage(this.id,
      {this.item, this.fallbackTitle, this.fallbackBody, super.key});

  final int id;
  final NewsItem? item;
  final String? fallbackTitle;
  final String? fallbackBody;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  NewsItem? item;
  bool loading = false;
  bool unavailable = false;

  @override
  void initState() {
    super.initState();
    item = widget.item;
    News.markSeen(widget.id);
    if (item == null) load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    NewsItem? result;
    try {
      result = await News.fetchOne(widget.id);
    } catch (e) {
      debugPrint('Loading news ${widget.id} failed: $e');
    }
    if (!mounted) return;
    setState(() {
      loading = false;
      item = result;
      unavailable = result == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final it = item;

    Widget content;
    if (loading) {
      content = Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()));
    } else if (it != null) {
      content = article(l, null, it.title, it.body, it.imageUrl, it.linkUrl,
          it.date);
    } else if ((widget.fallbackTitle ?? '').isNotEmpty ||
        (widget.fallbackBody ?? '').isNotEmpty) {
      content = article(l, unavailable ? l.news_outdated : null,
          widget.fallbackTitle ?? '', widget.fallbackBody ?? '', null, null,
          null);
    } else {
      content = Padding(
          padding: EdgeInsets.all(24),
          child: Text(l.news_outdated,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(color: Colors.grey[700], fontSize: 15)));
    }

    return Scaffold(
        appBar: CustomAppBar(context, l.news_title, MenuItemE.COUNT, []),
        body: ListView(children: [content]));
  }

  Widget article(AppLocalizations l, String? notice, String title, String body,
      String? imageUrl, String? linkUrl, DateTime? date) {
    return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (notice != null) ...[
            Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(notice,
                    style: GoogleFonts.lato(
                        color: Color(0xFF8A4B00), fontSize: 14))),
            Space(12),
          ],
          if (date != null)
            Text(_dateFormat.format(date),
                style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 13)),
          Space(4),
          Text(title,
              style: GoogleFonts.lato(
                  color: maincolor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.25)),
          if (imageUrl != null) ...[
            Space(14),
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => SizedBox.shrink())),
          ],
          if (body.isNotEmpty) ...[
            Space(14),
            SelectableText(body,
                style: GoogleFonts.lato(
                    color: Colors.grey[850], fontSize: 16, height: 1.5)),
          ],
          if (linkUrl != null) ...[
            Space(18),
            FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: maincolor,
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () => ContactCard.open(context, linkUrl),
                icon: Icon(Icons.open_in_new, color: Colors.white, size: 20),
                label: Text(l.news_more,
                    style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold))),
          ],
        ]));
  }
}
