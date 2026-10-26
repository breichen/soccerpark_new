import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../utils/online_highscores.dart';
import '../widgets/appbar.dart';
import '../widgets/space.dart';
import '../widgets/dropdown.dart';

/// Bestenlisten: Highscores, persönliche Rekorde, Durchschnitt und die
/// monatliche Online-Bestenliste der gewählten Anlage.
class HighscorePage extends StatefulWidget {
  const HighscorePage({super.key});

  @override
  State<HighscorePage> createState() => _HighscorePageState();
}

class _HighscorePageState extends State<HighscorePage> {
  GlobalKey _globalKey = new GlobalKey();

  List<NamedHighscore> highscores = [];
  List<Average> averages = [];

  int highscoreType = 0;
  int highscoreDetail = 0;

  // Online-Bestenliste (highscoreType == onlineType)
  static const int onlineType = 3;
  List<OnlineHighscore> onlineHighscores = [];
  List<String> onlineMonths = [];
  int onlineMonthIdx = 0;
  bool onlineLoading = false;
  bool onlineError = false;
  bool onlineShowAll = false;
  /// Aufgeklappter Eintrag ("local-<i>" oder "online-<id>").
  String? expandedKey;

  @override
  void initState() {
    super.initState();
    setListData();
  }

  @override
  Widget build(BuildContext context) {
    List<String> holes = [AppLocalizations.of(context)!.total];
    for (var i = 1; i <= 18; i++)
      holes.add(AppLocalizations.of(context)!.hole + " " + i.toString());
    List<String> highscoreTypes = [
      AppLocalizations.of(context)!.local_top10,
      AppLocalizations.of(context)!.personal_records,
      AppLocalizations.of(context)!.average
    ];
    if (OnlineHighscores.isConfigured) {
      highscoreTypes.add(AppLocalizations.of(context)!.online_highscores);
    }
    final loc = App.of(context).getLocality();

    return Scaffold(
        appBar: CustomAppBar(context,
            AppLocalizations.of(context)!.leaderboards, MenuItemE.COUNT, [
          getShareButton(),
        ]),
        body: Stack(children: [
          RepaintBoundary(
              key: _globalKey,
              child: Container(
                  color: bgcolor,
                  child: ListView(children: <Widget>[
                    Space(16),
                    Center(
                        child: ConstrainedBox(
                            constraints:
                                BoxConstraints(maxHeight: 90, maxWidth: 260),
                            child: Image.asset(
                                Data.getLocalityImageString(loc),
                                fit: BoxFit.contain))),
                    Space(20),
                    getListDropdown(highscoreTypes, holes),
                    Space(10),
                    getList(),
                    Space(10)
                  ])))
        ]));
  }

  void setListData() {
    expandedKey = null;
    if (highscoreType == onlineType) {
      loadOnlineHighscores();
      return;
    }
    if (highscoreType != 2) {
      loadHighscores().then((d) {
        if (mounted) setState(() => highscores = d);
      });
    } else {
      loadAverages().then((d) {
        if (mounted) setState(() => averages = d);
      });
    }
  }

  Future<List<NamedHighscore>> loadHighscores() async {
    if (highscoreType == 0) {
      return Data.getOverallHighscores(highscoreDetail);
    }
    return Data.getPersonalHighscores(highscoreDetail);
  }

  Future<void> loadOnlineHighscores() async {
    final loc = App.of(context).getLocality();
    setState(() {
      onlineLoading = true;
      onlineError = false;
      expandedKey = null;
    });
    try {
      if (onlineMonths.isEmpty) {
        onlineMonths = await OnlineHighscores.fetchMonths(loc);
        onlineMonthIdx = 0;
      }
      final month = onlineMonths[onlineMonthIdx];
      final list = await OnlineHighscores.fetch(loc, month);
      if (!mounted) return;
      setState(() {
        onlineHighscores = list;
        onlineLoading = false;
      });
    } catch (e) {
      debugPrint('Loading online highscores failed: $e');
      if (!mounted) return;
      setState(() {
        onlineHighscores = [];
        onlineLoading = false;
        onlineError = true;
      });
    }
  }

  Future<List<Average>> loadAverages() async {
    return Data.getPersonalAverages(highscoreDetail);
  }

  /// Chips nebeneinander; bricht auf schmalen Bildschirmen um.
  Widget dropdownRow(List<Widget> children) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(spacing: 10, runSpacing: 8, children: children));
  }

  Widget getListDropdown(List<String> highscoreTypes, List<String> holes) {
    return dropdownRow([
      CustomDropdownButton(highscoreTypes, highscoreType, (int v) {
        setState(() {
          highscoreType = v;
          setListData();
        });
      }, icon: Icons.emoji_events),
      highscoreType == onlineType
          ? getOnlineMonthDropdown()
          : CustomDropdownButton(holes, highscoreDetail, (int v) {
              setState(
                () {
                  highscoreDetail = v;
                  setListData();
                },
              );
            }, icon: Icons.flag)
    ]);
  }

  Widget getOnlineMonthDropdown() {
    final months =
        onlineMonths.isEmpty ? [OnlineHighscores.currentMonth()] : onlineMonths;
    final lang = Localizations.localeOf(context).languageCode;
    return CustomDropdownButton(
        months.map((m) => OnlineHighscores.monthLabel(m, lang)).toList(),
        onlineMonths.isEmpty ? 0 : onlineMonthIdx, (int v) {
      if (onlineMonths.isEmpty) return;
      setState(() {
        onlineMonthIdx = v;
        onlineShowAll = false;
      });
      loadOnlineHighscores();
    }, icon: Icons.calendar_month);
  }

  Widget getList() {
    if (highscoreType == onlineType) return getOnlineList();
    final empty = highscoreType == 2 ? averages.isEmpty : highscores.isEmpty;
    if (empty) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(AppLocalizations.of(context)!.no_entries,
              style: styleHist));
    }
    if (highscoreType == 2) return getAverageList();
    return getHighscoreList();
  }

  Widget getHighscoreList() {
    final pars = Data.getPars(App.of(context).getLocality());
    final par = highscoreDetail == 0
        ? pars.reduce((a, b) => a + b)
        : pars[highscoreDetail - 1];
    final rows = <RankRow>[];
    for (var i = 0; i < highscores.length; i++) {
      final entry = highscores[i];
      rows.add(RankRow(
        key: 'local-$i',
        value: entry.score.toDouble(),
        name: entry.name,
        subtitle: dateOnly(entry.date),
        scoreText: entry.score.toString(),
        diffToPar: (entry.score - par).toDouble(),
        // Lochwerte gibt es nur beim Gesamt-Highscore (und nur bei Runden,
        // die nach der Erweiterung gespeichert wurden).
        holes: highscoreDetail == 0 ? entry.holes : null,
      ));
    }
    return buildRankedList(rows, pars);
  }

  Widget getOnlineList() {
    if (onlineLoading) {
      return Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()));
    }
    if (onlineError || onlineHighscores.isEmpty) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
              onlineError
                  ? AppLocalizations.of(context)!.online_hs_load_error
                  : AppLocalizations.of(context)!.online_hs_empty,
              style: styleHist));
    }

    final pars = Data.getPars(App.of(context).getLocality());
    final par = pars.reduce((a, b) => a + b);
    final dateFormat = DateFormat('dd.MM.yyyy');
    // Erst die besten 10, der Rest auf Wunsch.
    final shown = onlineShowAll
        ? onlineHighscores
        : onlineHighscores.take(OnlineHighscores.previewSize).toList();
    final hidden = onlineHighscores.length - shown.length;
    final rows = shown
        .map((entry) => RankRow(
              key: 'online-${entry.id}',
              value: entry.total.toDouble(),
              name: entry.name,
              subtitle: dateFormat.format(entry.createdAt),
              scoreText: entry.total.toString(),
              diffToPar: (entry.total - par).toDouble(),
              holes: entry.holes,
            ))
        .toList();
    return Column(children: [
      buildRankedList(rows, pars),
      if (hidden > 0)
        TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: maincolor),
            onPressed: () => setState(() => onlineShowAll = true),
            icon: Icon(Icons.expand_more),
            label: Text(
                AppLocalizations.of(context)!
                    .online_hs_show_all(onlineHighscores.length),
                style: GoogleFonts.lato(
                    fontSize: 15, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget getHoleTable(List<int> holes, List<int> pars) {
    final styleHole = GoogleFonts.lato(color: Colors.grey[700], fontSize: 11);
    TextStyle styleScore(int hole) {
      final diff = holes[hole] - pars[hole];
      return GoogleFonts.lato(
          color: diff < 0 ? maincolor : (diff > 0 ? mainred : Colors.black),
          fontSize: 14,
          fontWeight: FontWeight.bold);
    }

    TableRow numbers(int start) => TableRow(
        children: List.generate(
            9,
            (i) => Center(
                child: Text((start + i + 1).toString(), style: styleHole))));
    TableRow scores(int start) => TableRow(
        children: List.generate(
            9,
            (i) => Padding(
                padding: EdgeInsets.only(top: 2, bottom: 6),
                child: Center(
                    child: Text(holes[start + i].toString(),
                        style: styleScore(start + i))))));

    return Padding(
        padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: Table(children: [
          numbers(0),
          scores(0),
          numbers(9),
          scores(9),
        ]));
  }

  Widget getAverageList() {
    final pars = Data.getPars(App.of(context).getLocality());
    final par = highscoreDetail == 0
        ? pars.reduce((a, b) => a + b)
        : pars[highscoreDetail - 1];
    final rows = <RankRow>[];
    for (var i = 0; i < averages.length; i++) {
      final entry = averages[i];
      // Auf eine Nachkommastelle runden, damit Gleichstände gleich gewertet
      // werden wie angezeigt.
      final avg = (entry.avg * 10).round() / 10;
      rows.add(RankRow(
        key: 'avg-$i',
        value: avg,
        name: entry.name,
        subtitle: entry.games.toString() +
            " " +
            (entry.games == 1
                ? AppLocalizations.of(context)!.game
                : AppLocalizations.of(context)!.games),
        scoreText: formatDecimal(avg),
        diffToPar: avg - par,
        decimals: true,
      ));
    }
    return buildRankedList(rows, pars);
  }

  /// "12.10.2026 15:20" -> "12.10.2026"
  String dateOnly(String date) {
    final i = date.indexOf(' ');
    return i < 0 ? date : date.substring(0, i);
  }

  String formatDecimal(double v) {
    final s = v.toStringAsFixed(1);
    return Localizations.localeOf(context).languageCode == 'de'
        ? s.replaceAll('.', ',')
        : s;
  }

  /// Eine weiße Karte mit Trennlinien; Platz, Name, Untertitel, Schläge
  /// und Abstand zu Par. Gleiche Werte bekommen den gleichen Platz.
  Widget buildRankedList(List<RankRow> rows, List<int> pars) {
    final List<Widget> children = [];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      var rank = i + 1;
      for (var j = i - 1; j >= 0 && rows[j].value == row.value; j--) {
        rank = j + 1;
      }
      if (i > 0) {
        children.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      children.add(buildRankRow(row, rank, pars));
    }
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: children));
  }

  Widget buildRankRow(RankRow row, int rank, List<int> pars) {
    final holes = row.holes;
    final expanded = holes != null && expandedKey == row.key;
    final diff = row.diffToPar;
    final diffColor =
        diff < 0 ? maincolor : (diff > 0 ? mainred : Colors.grey[700]!);
    final diffText = diff == 0
        ? "±0"
        : (diff > 0 ? "+" : "−") +
            (row.decimals
                ? formatDecimal(diff.abs())
                : diff.abs().round().toString());

    return Material(
        color: Colors.white,
        child: InkWell(
            onTap: holes == null
                ? null
                : () => setState(() {
                      expandedKey = expanded ? null : row.key;
                    }),
            child: Column(children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(12, 9, 8, 9),
                  child: Row(children: [
                    rankBadge(rank),
                    SpaceH(10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(row.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                          Text(row.subtitle,
                              style: GoogleFonts.lato(
                                  color: Colors.grey[600], fontSize: 12)),
                        ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(row.scoreText,
                          style: GoogleFonts.lato(
                              color: rank == 1 ? maincolor : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(diffText,
                          style: GoogleFonts.lato(color: diffColor, fontSize: 12)),
                    ]),
                    SizedBox(
                        width: 28,
                        child: holes == null
                            ? null
                            : Icon(
                                expanded ? Icons.expand_less : Icons.expand_more,
                                size: 20,
                                color: Colors.grey[500])),
                  ])),
              if (expanded && holes != null) getHoleTable(holes, pars),
              if (expanded) Space(6),
            ])));
  }

  /// Platz 1-3 als Medaille (Gold, Silber, Bronze), danach nur die Zahl.
  Widget rankBadge(int rank) {
    const medalColors = [Color(0xFFF1C40F), Color(0xFFCFD8DC), Color(0xFFE8C3A0)];
    const medalText = [Color(0xFF5C4500), Color(0xFF37474F), Color(0xFF6D3D12)];
    final medal = rank <= 3;
    return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: medal
            ? BoxDecoration(color: medalColors[rank - 1], shape: BoxShape.circle)
            : null,
        child: Text(rank.toString(),
            style: GoogleFonts.lato(
                color: medal ? medalText[rank - 1] : Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold)));
  }

  TextStyle styleHist = GoogleFonts.lato(color: Colors.black, fontSize: 14);

  Widget getShareButton() {
    return ShareButton(() {
      share(
          _globalKey,
          AppLocalizations.of(context)!.share_text_history +
              " " +
              Data.getLocalityStringImm(App.of(context).getLocality()) +
              AppLocalizations.of(context)!.share_text2 +
              Data.getWebsiteStringImm(context, App.of(context).getLocality()));
    });
  }
}

/// Eine Zeile der Bestenliste.
class RankRow {
  RankRow(
      {required this.key,
      required this.value,
      required this.name,
      required this.subtitle,
      required this.scoreText,
      required this.diffToPar,
      this.holes,
      this.decimals = false});

  final String key;
  final double value; // für Platzierung (kleiner = besser)
  final String name;
  final String subtitle;
  final String scoreText;
  final double diffToPar;
  final List<int>? holes;
  final bool decimals;
}
