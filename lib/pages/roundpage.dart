import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../utils/csv.dart';
import '../utils/pdf.dart';
import '../utils/export.dart';
import '../dialogs/roundtimelinedialog.dart';
import '../dialogs/holedialog.dart';
import '../dialogs/playholedialog.dart';
import '../dialogs/scoredialog.dart';
import '../dialogs/twobuttondialog.dart';
import '../widgets/appbar.dart';
import '../widgets/space.dart';
import './mainpage.dart';
import './finishpage.dart';

/// Scorecard einer Runde. [round] 0 = laufende Runde (Eintragen möglich),
/// 1..10 = gespeicherte Runden aus der Historie.
class RoundPage extends StatefulWidget {
  const RoundPage(this.roundWidget, {super.key});

  final int roundWidget;

  @override
  State<RoundPage> createState() => _RoundPageState();
}

class _RoundPageState extends State<RoundPage> {
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _scroll = ScrollController();
  final List<GlobalKey> _rowKeys = List.generate(18, (_) => GlobalKey());

  late int round = widget.roundWidget;
  Locality loc = Locality.SALZBURG;
  List<String> names = [];
  List<List<int>> scores = [];
  List<int> pars = [];
  bool loaded = false;

  // Spaltenbreiten
  static const double holeWidth = 52;
  static const double parWidth = 40;

  @override
  void initState() {
    super.initState();
    Data.getRoundData(round).then((roundData) {
      if (!mounted) return;
      setState(() {
        loc = roundData.loc;
        names = roundData.names;
        scores = roundData.scores;
        pars = Data.getPars(loc);
        loaded = true;
      });
      // Zur aktuellen Bahn scrollen.
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToCurrent());
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool get playing => round == 0;

  // ------------------------------------------------------------------
  // Daten
  // ------------------------------------------------------------------

  bool holeComplete(int hole) =>
      names.isNotEmpty && scores.every((s) => s[hole - 1] > 0);

  int get holesDone =>
      List.generate(18, (i) => i + 1).where(holeComplete).length;

  /// Erste Bahn, die noch nicht für alle eingetragen ist (null = fertig).
  int? get currentHole {
    for (var hole = 1; hole <= 18; hole++) {
      if (!holeComplete(hole)) return hole;
    }
    return null;
  }

  bool isFinished() => currentHole == null;

  void setScore(int player, int hole, int score) {
    setState(() {
      scores[player][hole - 1] = score;
    });
    Data.storeScore(round, player + 1, hole, score);
  }

  /// Summe und Par der gespielten Bahnen eines Spielers in [from]..[to].
  (int, int) totals(int player, int from, int to) {
    var total = 0, par = 0;
    for (var hole = from; hole <= to; hole++) {
      final s = scores[player][hole - 1];
      if (s > 0) {
        total += s;
        par += pars[hole - 1];
      }
    }
    return (total, par);
  }

  int parSum(int from, int to) {
    var sum = 0;
    for (var hole = from; hole <= to; hole++) sum += pars[hole - 1];
    return sum;
  }

  void scrollToCurrent() {
    final hole = currentHole;
    if (hole == null) return;
    final ctx = _rowKeys[hole - 1].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          alignment: 0.4, duration: Duration(milliseconds: 300));
    }
  }

  // ------------------------------------------------------------------
  // Aufbau
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final intermediate = App.of(context).isIntermediate();

    final rows = <Widget>[];
    for (var hole = 1; hole <= 18; hole++) {
      rows.add(getHoleRow(hole));
      if (intermediate && hole == 10) rows.add(getSumRow("1–10", 1, 10));
      if (intermediate && hole == 18) rows.add(getSumRow("11–18", 11, 18));
    }

    return Scaffold(
      appBar: CustomAppBar(
          context, l.round, MenuItemE.COUNT, getQuickButtons(context)),
      bottomNavigationBar: playing && loaded ? getBottomBar(l) : null,
      body: !loaded
          ? Center(child: CircularProgressIndicator())
          : Stack(children: [
              // Die ganze Scorecard (auch fürs Teilen als Bild).
              ListView(controller: _scroll, children: [
                RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                        color: Colors.white,
                        child: Column(children: [
                          getHeaderRow(),
                          ...rows,
                          getSumRow("Σ", 1, 18, total: true),
                        ]))),
              ]),
              // Kopf- und Summenzeile bleiben beim Scrollen sichtbar.
              Column(children: [getHeaderRow(), Spacer()]),
              Column(children: [Spacer(), getSumRow("Σ", 1, 18, total: true)]),
            ]),
    );
  }

  TextStyle get styleHeader => GoogleFonts.lato(
      color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold);

  Widget getHeaderRow() {
    final l = AppLocalizations.of(context)!;
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 2))),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          SizedBox(
              width: holeWidth,
              child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(l.hole, style: styleHeader, maxLines: 1))),
          SizedBox(
              width: parWidth,
              child: Text("Par",
                  textAlign: TextAlign.center,
                  style: styleHeader.copyWith(color: Colors.grey[600]))),
          for (final name in names)
            Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: styleHeader))),
          SizedBox(width: 6),
        ]));
  }

  Widget getHoleRow(int hole) {
    final current = playing && hole == currentHole;
    final bg = current
        ? Color(0xFFE3EFE3)
        : (hole.isEven ? Color(0xFFF7F7F7) : Colors.white);

    return Material(
        key: _rowKeys[hole - 1],
        color: bg,
        child: InkWell(
            onTap: () => openHole(hole),
            child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            color: current ? maincolor : Colors.transparent,
                            width: 4),
                        bottom: BorderSide(color: Colors.grey[200]!))),
                padding: EdgeInsets.symmetric(vertical: 9),
                child: Row(children: [
                  SizedBox(
                      width: holeWidth - 4,
                      child: Padding(
                          padding: EdgeInsets.only(left: current ? 2 : 8),
                          child: Row(children: [
                            // Aktuelle Bahn: grüner Pfeil (Icon statt
                            // Zeichen, das sonst als Emoji erscheint).
                            if (current)
                              Icon(Icons.play_arrow_rounded,
                                  color: maincolor, size: 18),
                            Text(hole.toString(),
                                style: GoogleFonts.lato(
                                    color:
                                        current ? maincolor : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: current
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                          ]))),
                  SizedBox(
                      width: parWidth,
                      child: Text(pars[hole - 1].toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.grey[600], fontSize: 15))),
                  for (var pl = 0; pl < names.length; pl++)
                    Expanded(child: scoreCell(pl, hole)),
                  SizedBox(width: 6),
                ]))));
  }

  /// Zelle eines Spielers: in der laufenden Runde öffnet Antippen die
  /// Auswahl der Schlagzahl für genau diesen Spieler; sonst wie die Zeile.
  Widget scoreCell(int pl, int hole) {
    final text = scoreText(scores[pl][hole - 1], hole);
    if (!playing) return text;
    return InkWell(
        onTap: () => openScore(pl, hole),
        child: SizedBox(height: 24, child: Center(child: text)));
  }

  Widget scoreText(int score, int hole) {
    if (score == 0) return Text("", textAlign: TextAlign.center);
    final par = pars[hole - 1];
    return Text(score.toString(),
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
            color: score < par
                ? maincolor
                : (score > par ? mainred : Colors.black87),
            fontSize: 17,
            fontWeight: score == par ? FontWeight.normal : FontWeight.bold));
  }

  /// Summenzeile (Zwischensumme oder Gesamt) mit Abstand zu Par der
  /// bereits gespielten Bahnen.
  Widget getSumRow(String label, int from, int to, {bool total = false}) {
    return Container(
        decoration: BoxDecoration(
            color: total ? Colors.white : Color(0xFFF1F1F1),
            border: Border(
                top: BorderSide(
                    color: Colors.grey[300]!, width: total ? 2 : 1),
                bottom: BorderSide(color: Colors.grey[300]!))),
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(
              width: holeWidth,
              child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(label,
                      maxLines: 1,
                      style: GoogleFonts.lato(
                          color: Colors.black87,
                          fontSize: total ? 18 : 13,
                          fontWeight: FontWeight.bold)))),
          SizedBox(
              width: parWidth,
              child: Text(pars.isEmpty ? "" : parSum(from, to).toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.bold))),
          for (var pl = 0; pl < names.length; pl++)
            Expanded(child: sumCell(pl, from, to, total)),
          SizedBox(width: 6),
        ]));
  }

  Widget sumCell(int pl, int from, int to, bool total) {
    final (sum, par) = totals(pl, from, to);
    if (sum == 0) return Text("", textAlign: TextAlign.center);
    final diff = sum - par;
    final diffColor =
        diff < 0 ? maincolor : (diff > 0 ? mainred : Colors.grey[600]!);
    final diffText =
        diff == 0 ? "±0" : (diff > 0 ? "+" : "−") + diff.abs().toString();
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(sum.toString(),
          style: GoogleFonts.lato(
              color: Colors.black87,
              fontSize: total ? 18 : 15,
              fontWeight: FontWeight.bold)),
      Text(diffText,
          style: GoogleFonts.lato(
              color: diffColor, fontSize: 11, fontWeight: FontWeight.bold)),
    ]);
  }

  /// Untere Leiste der laufenden Runde: Abbrechen, Fortschritt und die
  /// nächste Aktion (aktuelle Bahn eintragen bzw. Runde abschließen).
  Widget getBottomBar(AppLocalizations l) {
    final done = holesDone;
    final hole = currentHole;
    return SafeArea(
        child: Container(
            padding: EdgeInsets.fromLTRB(4, 8, 12, 8),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!))),
            child: Row(children: [
              TextButton(
                  style: TextButton.styleFrom(foregroundColor: mainred),
                  onPressed: askCancel,
                  child: Text(l.cancel,
                      style: GoogleFonts.lato(
                          fontSize: 14, fontWeight: FontWeight.bold))),
              Expanded(
                  child: Row(children: [
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                            value: done / 18,
                            minHeight: 6,
                            backgroundColor: Colors.grey[200],
                            color: maincolor))),
                SpaceH(6),
                Text("$done/18",
                    style: GoogleFonts.lato(
                        color: Colors.grey[700], fontSize: 12)),
                SpaceH(10),
              ])),
              FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: maincolor,
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: hole == null ? finish : () => openHole(hole),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                        hole == null
                            ? l.finish_round
                            : l.hole + " " + hole.toString(),
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Icon(hole == null ? Icons.flag : Icons.chevron_right,
                        color: Colors.white, size: 20),
                  ])),
            ])));
  }

  // ------------------------------------------------------------------
  // Aktionen
  // ------------------------------------------------------------------

  void openHole(int hole) {
    if (!playing) {
      showDialog(
          context: context,
          builder: (BuildContext context) => HoleDialog(loc, hole));
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            PlayHoleDialog(loc, hole, names, scores, setScore)).then((_) {
      if (mounted) scrollToCurrent();
    });
  }

  void openScore(int pl, int hole) {
    showDialog(
        context: context,
        builder: (BuildContext context) => ScoreDialog(
            loc, hole, names[pl], (int score) => setScore(pl, hole, score),
            current: scores[pl][hole - 1])).then((_) {
      if (mounted) scrollToCurrent();
    });
  }

  void askCancel() {
    final l = AppLocalizations.of(context)!;
    TwoButtonDialog dialog = TwoButtonDialog(
        l.cancel_round, l.ask_cancel_round, l.back, l.cancel_round, () {
      Navigator.of(context).pop();
    }, () {
      Data.clearCurrent();
      Navigator.of(context).pop();
      goToMainPage(context);
    });
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  void finish() {
    Data.shift();
    setState(() {
      round = 1;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              FinishPage(RoundData(loc, names, scores), pars)),
    );
  }

  List<Widget> getQuickButtons(BuildContext context) {
    ShareButton shareB = ShareButton(() {
      share(
          _globalKey,
          AppLocalizations.of(context)!.share_text +
              " " +
              Data.getLocalityStringImm(App.of(context).getLocality()) +
              AppLocalizations.of(context)!.share_text2 +
              Data.getWebsiteStringImm(context, App.of(context).getLocality()));
    });

    if (playing) return [getTimelineButton(), shareB];
    return [getExportMenu(context), getTimelineButton(), shareB];
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

  List<int> get totalScores =>
      List.generate(names.length, (pl) => scores[pl].reduce((a, b) => a + b));

  void exportCsv() {
    Data.getDate(round).then((date) => generateCsvSingleRound(
        context, date, names, scores, totalScores, date));
  }

  void exportPdf() {
    Data.getDate(round)
        .then((date) => generatePdfSingleRound(context, round, date));
  }

  Widget getTimelineButton() {
    return TimelineButton(() {
      RoundTimelineDialog dialog =
          RoundTimelineDialog(loc, names, scores, pars);
      showDialog(context: context, builder: (BuildContext context) => dialog);
    });
  }
}
