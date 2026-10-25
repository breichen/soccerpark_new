import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import './mainpage.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../utils/export.dart';
import '../pages/roundpage.dart';
import '../widgets/chart.dart';
import '../widgets/appbar.dart';
import '../widgets/toast.dart';
import '../widgets/space.dart';
import '../widgets/dropdown.dart';
import '../dialogs/singlebuttoncanceldialog.dart';
import '../dialogs/exportdialog.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage();

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class ScorePair {
  String name;
  int score;

  ScorePair(this.name, this.score);
}

class _HistoryPageState extends State<HistoryPage> {
  GlobalKey _globalKey = new GlobalKey();

  List<int> totalScores = [];
  TextStyle styleRanking = GoogleFonts.lato(
      color: maincolor, fontSize: 22, fontWeight: FontWeight.bold);
  List<List<PointPair>> chartData = [];
  List<String> chartLegendData = [];
  int type = 0;
  int detail = 0;
  int? bestScore;

  List<String> dates = [];
  List<String> datesForChart = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      Data.getValidDates().then((list) => setState(() {
            dates = list;
            print("dates " + list.length.toString());

            for (var i = dates.length - 1; i >= 0; i--) {
              String s = dates[i];
              int first = s.indexOf(".");
              String r = s.substring(first + 1);
              int second = r.indexOf(".");
              s = s.substring(0, first + second + 2);

              datesForChart.add(s);
            }
          }));
    });
    setChartData();
    Data.getOverallHighscores(0).then((list) {
      if (mounted && list.isNotEmpty) {
        setState(() => bestScore = list.first.score);
      }
    });
  }

  void setChartData() {
    setState(() {
      loadChartData().then((d) => chartData = d);
      loadChartLegendData().then((d) => chartLegendData = d);
    });
  }

  Future<List<List<PointPair>>> loadChartData() async {
    if (type == 0) {
      int round = detail + 1;
      return Data.getScorePointsInRound(round);
    } else if (type == 1) {
      int hole = detail;
      return Data.getScoresAllRounds(hole);
    }
    return Data.getPersonalAverageScores();
  }

  Future<List<String>> loadChartLegendData() async {
    if (type == 0) {
      int round = detail + 1;
      return Data.getPlayerNames(round);
    } else if (type == 1) {
      return Data.getPlayerNamesAllRounds();
    }
    return Data.getPersonalAverageNames();
  }

  @override
  Widget build(BuildContext context) {
    List<String> types = [
      AppLocalizations.of(context)!.single_rounds,
      AppLocalizations.of(context)!.trend,
      AppLocalizations.of(context)!.average
    ];
    List<String> holes = [AppLocalizations.of(context)!.total];
    for (var i = 1; i <= 18; i++)
      holes.add(AppLocalizations.of(context)!.hole + " " + i.toString());
    return Scaffold(
        appBar: CustomAppBar(
            context, AppLocalizations.of(context)!.history, MenuItemE.COUNT, [
          getExportButton(),
          getShareButton(),
        ]),
        body: Stack(children: [
          RepaintBoundary(
              key: _globalKey,
              child: Container(
                  color: bgcolor,
                  child: ListView(children: <Widget>[
                    Space(16),
                    getChartDropdown(types, holes),
                    Space(28),
                    getChart(),
                    Space(20),
                    getRoundCard(),
                    Space(24),
                    getDeleteButton(),
                    Space(10)
                  ])))
        ]));
  }

  Widget getChart() {
    return Row(children: [
      SpaceH(16),
      Expanded(
          flex: 1,
          child: Container(
              //color: Colors.grey[300],
              width: double.infinity,
              child: LineChartWidget(
                chartData,
                xtitles: type == 0 || type == 2 ? [] : datesForChart,
                legendEntries: chartLegendData,
                parLine: chartParLine(),
                tooltipTitle: type == 1
                    ? null
                    : (x) => AppLocalizations.of(context)!.hole + " $x",
                tightY: type == 1,
              ))),
      SpaceH(32),
    ]);
  }

  /// Par-Linie passend zur Diagrammart.
  List<double> chartParLine() {
    final pars = Data.getPars(App.of(context).getLocality());
    if (type == 1) {
      final par = detail == 0 ? pars.reduce((a, b) => a + b) : pars[detail - 1];
      return LineChartWidget.constantParLine(par, datesForChart.length);
    }
    return LineChartWidget.holeParLine(pars);
  }

  Widget getChartDropdown(List<String> types, List<String> holes) {
    return dropdownRow([
      CustomDropdownButton(types, type, (int v) {
        setState(() {
          type = v;
          setChartData();
        });
      }, icon: Icons.show_chart),
      Visibility(
          child: CustomDropdownButton(
              type == 0 ? (dates.isEmpty ? [""] : dates) : holes, detail,
              (int v) {
            setState(
              () {
                detail = v;
                setChartData();
              },
            );
          }, icon: type == 0 ? Icons.event : Icons.flag),
          visible: type == 1 || (type == 0 && !dates.isEmpty))
    ]);
  }

  /// Chips nebeneinander; bricht auf schmalen Bildschirmen um.
  Widget dropdownRow(List<Widget> children) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(spacing: 10, runSpacing: 8, children: children));
  }

  /// Karte mit Anlage, Bestwert, letzter Runde und "Zur Runde".
  Widget getRoundCard() {
    final loc = App.of(context).getLocality();
    final styleTitle = GoogleFonts.lato(
        color: maincolor, fontSize: 16, fontWeight: FontWeight.bold);
    final styleInfo = GoogleFonts.lato(color: Colors.grey[700], fontSize: 13);
    final showRound = type == 0 && dates.isNotEmpty;

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          SizedBox(
              width: 64,
              height: 44,
              child: Image.asset(Data.getLocalityImageString(loc),
                  fit: BoxFit.contain)),
          SpaceH(12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(Data.getLocalityStringImm(loc), style: styleTitle),
                if (bestScore != null)
                  Text(
                      AppLocalizations.of(context)!.best_score +
                          ": " +
                          bestScore.toString(),
                      style: styleInfo),
                if (dates.isNotEmpty)
                  Text(
                      AppLocalizations.of(context)!.last_round +
                          ": " +
                          dates.first,
                      style: styleInfo),
              ])),
          if (showRound) ...[
            SpaceH(8),
            Material(
                color: dropdownChipColor,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RoundPage(detail + 1)),
                      );
                    },
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 6, 8),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(AppLocalizations.of(context)!.overview,
                              style: GoogleFonts.lato(
                                  color: maincolor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          Icon(Icons.chevron_right,
                              size: 20, color: maincolor),
                        ])))),
          ],
        ]));
  }

  /// Löscht alle Runden, Highscores, Rekorde und Durchschnitte der Anlage.
  Widget getDeleteButton() {
    return Center(
        child: TextButton.icon(
      style: TextButton.styleFrom(foregroundColor: mainred),
      icon: Icon(Icons.delete_outline),
      label: Text(AppLocalizations.of(context)!.delete_hist,
          style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        SingleButtonCancelDialog dialog = SingleButtonCancelDialog(
            context,
            AppLocalizations.of(context)!.delete_hist,
            AppLocalizations.of(context)!.delete_hist_question,
            AppLocalizations.of(context)!.delete, () {
          Navigator.of(context).pop();
          Data.clear();
          CustomToast.showToastIcon(
              context, AppLocalizations.of(context)!.deleted_data, Icons.check);
          goToMainPage(context);
        });
        showDialog(context: context, builder: (BuildContext context) => dialog);
      },
    ));
  }

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

  Widget getExportButton() {
    return ExportButton(() {
      ExportDialog dialog = ExportDialog();
      showDialog(context: context, builder: (BuildContext context) => dialog);
    });
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
    /*
    List<int> total = [];
    for (var pl = 1; pl <= widget.data.names.length; pl++) {
      total.add(0);
      for (var hole = 1; hole <= 18; hole++)
        total.last += widget.data.scores[pl - 1][hole - 1];
    }

    Data.getDate(1).then((date) => generateCsvSingleRound(
        context, date, widget.data.names, widget.data.scores, total, date));*/
  }

  void exportPdf() {
    /*
    Data.getDate(1).then((date) => generatePdfSingleRound(context, date));*/
  }
}
