import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import './mainpage.dart';
import '../utils/data.dart';
import '../utils/csv.dart';
import '../utils/pdf.dart';
import '../utils/share.dart';
import '../utils/export.dart';
import '../utils/online_highscores.dart';
import '../dialogs/onlinehighscoredialog.dart';
import '../widgets/toast.dart';
import '../widgets/appbar.dart';
import '../widgets/space.dart';
import '../widgets/chart.dart';

class FinishPage extends StatefulWidget {
  final RoundData data;
  final List<int> pars;

  FinishPage(this.data, this.pars) {}

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class ScorePair {
  String name;
  int score;

  ScorePair(this.name, this.score);
}

enum GeneralType { CURRENT, COMPARE }

enum DetailType { SINGLE, CUMULATED }

class _FinishPageState extends State<FinishPage> {
  GlobalKey _globalKey = new GlobalKey();

  List<int> totalScores = [];
  TextStyle styleRanking = GoogleFonts.lato(
      color: maincolor, fontSize: 20, fontWeight: FontWeight.bold);

  GeneralType generalType = GeneralType.CURRENT;
  DetailType detailType = DetailType.SINGLE;

  final List<List<List<PointPair>>> chartData = [[], [], [], []];

  @override
  void initState() {
    super.initState();

    setState(() {
      initChartData();
    });

    setState(() {
      totalScores = [];
      for (var i = 0; i < widget.data.names.length; i++) {
        totalScores.add(widget.data.scores[i].reduce((a, b) => a + b));
      }
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkOnlineHighscores());
  }

  /// Prüft nach einer vollen Runde, ob Spieler in die monatliche
  /// Online-Bestenliste kommen, und bietet das Eintragen an.
  /// Ohne Internet oder ohne Supabase-Konfiguration passiert nichts.
  Future<void> checkOnlineHighscores() async {
    if (!OnlineHighscores.isConfigured) return;

    final loc = widget.data.loc;
    // In load() gesetzt (auch für Closures erlaubt dank late).
    late List<OnlineHighscore> monthList;
    late List<OnlineHighscore> dayList;
    Future<void> load() async {
      final results = await Future.wait([
        OnlineHighscores.fetch(loc, OnlineHighscores.currentMonth()),
        OnlineHighscores.fetchDay(loc, OnlineHighscores.currentDay()),
      ]);
      monthList = results[0];
      dayList = results[1];
    }

    try {
      await load();
    } catch (e) {
      debugPrint('Online highscores not available: $e');
      return;
    }

    // Beste Runde zuerst; sobald einer nicht reicht, reicht keiner mehr.
    final order = List<int>.generate(widget.data.names.length, (i) => i)
      ..sort((a, b) => totalScores[a].compareTo(totalScores[b]));

    for (final pl in order) {
      if (!mounted) return;
      final total = totalScores[pl];
      final monthRank = OnlineHighscores.prospectiveRank(monthList, total);
      final dayRank = OnlineHighscores.prospectiveRank(dayList, total,
          size: OnlineHighscores.daySize);
      if (monthRank == null && dayRank == null) break;

      final playerName = widget.data.names[pl];
      final suggested = await OnlineHighscores.suggestedName(playerName);
      if (!mounted) return;

      final l = AppLocalizations.of(context)!;
      final venue = Data.getLocalityStringImm(loc);
      final monthName = OnlineHighscores.monthLabel(
          OnlineHighscores.currentMonth(),
          Localizations.localeOf(context).languageCode);
      final message = monthRank != null && dayRank != null
          ? l.online_hs_text_both(
              playerName, total, dayRank, monthRank, monthName, venue)
          : (dayRank != null
              ? l.online_hs_text_day(playerName, total, dayRank, venue)
              : l.online_hs_text(playerName, total, monthRank!, venue));

      final chosen = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => OnlineHighscoreDialog(message, suggested));
      if (chosen == null || !mounted) continue;

      await OnlineHighscores.saveName(playerName, chosen);
      try {
        final placed =
            await OnlineHighscores.submit(loc, chosen, widget.data.scores[pl]);
        if (!mounted) return;
        if (placed.month != null || placed.day != null) {
          CustomToast.showToastIcon(context,
              AppLocalizations.of(context)!.online_hs_saved, Icons.emoji_events);
        } else {
          CustomToast.showToast(
              context, AppLocalizations.of(context)!.online_hs_too_late);
        }
      } catch (e) {
        debugPrint('Submitting online highscore failed: $e');
        if (!mounted) return;
        CustomToast.showToast(
            context, AppLocalizations.of(context)!.online_hs_error);
        continue;
      }

      // Listen für die weiteren Spieler aktualisieren.
      try {
        await load();
      } catch (e) {
        return;
      }
    }
  }

  void initChartData() {
    for (var pl = 0; pl < widget.data.names.length; pl++) {
      chartData[0].add([]);
      chartData[1].add([]);

      int sum = 0;
      for (var hole = 1; hole <= 18; hole++) {
        sum += widget.data.scores[pl][hole - 1];
        chartData[0]
            .last
            .add(PointPair(hole, widget.data.scores[pl][hole - 1].toDouble()));
        chartData[1].last.add(PointPair(hole, sum.toDouble()));
      }

      chartData[2].add([]);
      chartData[3].add([]);

      int compSum = 0;
      for (var hole = 1; hole <= 18; hole++) {
        int diff = widget.data.scores[pl][hole - 1] - widget.pars[hole - 1];
        compSum += diff;
        chartData[2].last.add(PointPair(hole, diff.toDouble()));
        chartData[3].last.add(PointPair(hole, compSum.toDouble()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locality = widget.data.loc;
    final parTotal = widget.pars.reduce((a, b) => a + b);

    // Rangliste: wenigste Schläge zuerst, Gleichstand = gleicher Platz.
    final order = List<int>.generate(totalScores.length, (i) => i)
      ..sort((a, b) => totalScores[a].compareTo(totalScores[b]));
    final ranks = <int>[];
    for (var i = 0; i < order.length; i++) {
      ranks.add(i > 0 && totalScores[order[i]] == totalScores[order[i - 1]]
          ? ranks[i - 1]
          : i + 1);
    }

    final rows = <Widget>[];
    for (var i = 0; i < order.length; i++) {
      if (i > 0) {
        rows.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      rows.add(getRankRow(ranks[i], widget.data.names[order[i]],
          totalScores[order[i]], parTotal));
    }

    return Scaffold(
        appBar: CustomAppBar(context, l.finish, MenuItemE.COUNT,
            [getExportMenu(context), getShareButton()]),
        bottomNavigationBar: SafeArea(
            child: Container(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[300]!))),
                child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: maincolor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    onPressed: () => goToMainPage(context),
                    icon: Icon(Icons.home_outlined, color: Colors.white),
                    label: Text(l.menu,
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))))),
        body: ListView(children: [
          RepaintBoundary(
              key: _globalKey,
              child: Container(
                  color: bgcolor,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.emoji_events,
                              color: mainyellow, size: 30),
                          SpaceH(8),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(l.round_finished,
                                    style: GoogleFonts.lato(
                                        color: maincolor,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    Data.getLocalityStringImm(locality) +
                                        " · Par " +
                                        parTotal.toString(),
                                    style: GoogleFonts.lato(
                                        color: Colors.grey[700],
                                        fontSize: 14)),
                              ])),
                        ]),
                        Space(14),
                        Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(children: rows)),
                        Space(20),
                        Text(l.chart_title,
                            style: GoogleFonts.lato(
                                color: maincolor,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                        Space(10),
                        Center(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 700),
                                child: LineChartWidget(getData(),
                                    legendEntries: widget.data.names,
                                    parLine: getParLine(widget.pars),
                                    tooltipTitle: (x) => l.hole + " $x"))),
                      ]))),
          Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<DetailType>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      foregroundColor: maincolor,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: maincolor,
                      side: BorderSide(color: maincolor),
                      textStyle: GoogleFonts.lato(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    segments: [
                      ButtonSegment(
                          value: DetailType.SINGLE,
                          label: Text(capitalize(l.single))),
                      ButtonSegment(
                          value: DetailType.CUMULATED,
                          label: Text(capitalize(l.cumulated))),
                    ],
                    selected: {detailType},
                    onSelectionChanged: (s) =>
                        setState(() => detailType = s.first),
                  ))),
        ]));
  }

  String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// Zeile der Rangliste: Platz (Medaille für 1-3), Name, Schläge und
  /// Abstand zu Par.
  Widget getRankRow(int rank, String name, int score, int par) {
    const medalColors = [
      Color(0xFFF1C40F),
      Color(0xFFCFD8DC),
      Color(0xFFE8C3A0)
    ];
    const medalText = [
      Color(0xFF5C4500),
      Color(0xFF37474F),
      Color(0xFF6D3D12)
    ];
    final medal = rank <= 3;
    final diff = score - par;
    final diffColor =
        diff < 0 ? maincolor : (diff > 0 ? mainred : Colors.grey[700]!);
    final diffText =
        diff == 0 ? "±0" : (diff > 0 ? "+" : "−") + diff.abs().toString();

    return Container(
        color: rank == 1 ? Color(0xFFFFFBEA) : Colors.white,
        padding: EdgeInsets.fromLTRB(12, 10, 14, 10),
        child: Row(children: [
          Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: medal
                  ? BoxDecoration(
                      color: medalColors[rank - 1], shape: BoxShape.circle)
                  : null,
              child: Text(rank.toString(),
                  style: GoogleFonts.lato(
                      color: medal ? medalText[rank - 1] : Colors.grey[600],
                      fontSize: 15,
                      fontWeight: FontWeight.bold))),
          SpaceH(12),
          Expanded(
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                      color: Colors.black87,
                      fontSize: rank == 1 ? 18 : 16,
                      fontWeight: FontWeight.bold))),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(score.toString(),
                style: GoogleFonts.lato(
                    color: rank == 1 ? maincolor : Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text(diffText,
                style: GoogleFonts.lato(
                    color: diffColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ]),
        ]));
  }

  Widget getShareButton() {
    return ShareButton(() {
      share(
          _globalKey,
          AppLocalizations.of(context)!.share_text +
              " " +
              Data.getLocalityStringImm(App.of(context).getLocality()) +
              AppLocalizations.of(context)!.share_text2 +
              Data.getWebsiteStringImm(context, App.of(context).getLocality()));
    });
  }

  /// Par-Linie zur aktuellen Ansicht (nicht beim Vergleich mit Par).
  List<double>? getParLine(List<int> pars) {
    if (generalType != GeneralType.CURRENT) return null;
    return detailType == DetailType.SINGLE
        ? LineChartWidget.holeParLine(pars)
        : LineChartWidget.cumulativeParLine(pars);
  }

  List<List<PointPair>> getData() {
    if (generalType == GeneralType.CURRENT) {
      if (detailType == DetailType.SINGLE) return chartData[0];
      return chartData[1];
    }
    if (detailType == DetailType.SINGLE) return chartData[2];
    return chartData[3];
  }

  PopupMenuButton getExportMenu(BuildContext context) {
    return getExportMenuImpl(context, export);
  }

  void export(ExportMenuItemE value) {
    switch (value) {
      case ExportMenuItemE.CSV:
        exportCsv();
        break;
      case ExportMenuItemE.PDF:
        exportPdf();
        break;
      default:
        assert(false);
        exportCsv();
    }
  }

  void exportCsv() {
    List<int> total = [];
    for (var pl = 1; pl <= widget.data.names.length; pl++) {
      total.add(0);
      for (var hole = 1; hole <= 18; hole++)
        total.last += widget.data.scores[pl - 1][hole - 1];
    }

    Data.getDate(1).then((date) => generateCsvSingleRound(
        context, date, widget.data.names, widget.data.scores, total, date));
  }

  void exportPdf() {
    Data.getDate(1).then((date) => generatePdfSingleRound(context, 1, date));
  }
}
