import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import './mainpage.dart';
import '../utils/data.dart';
import '../utils/csv.dart';
import '../utils/pdf.dart';
import '../utils/share.dart';
import '../utils/export.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/space.dart';
import '../widgets/radio.dart';
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
    List<ScorePair> scores = [];
    for (var i = 0; i < totalScores.length; i++) {
      scores.add(ScorePair(widget.data.names[i], totalScores[i]));
    }
    scores.sort(
      (a, b) => a.score.compareTo(b.score),
    );

    List<int> ranks = [];
    for (var i = 0; i < scores.length; i++) ranks.add(i + 1);
    for (var i = 1; i < ranks.length; i++) {
      if (scores[i].score == scores[i - 1].score) ranks[i] = ranks[i - 1];
    }

    List<Widget> rows = [];
    for (var i = 0; i < ranks.length; i++) {
      rows.add(Row(children: [
        SizedBox(
          child: Text(
            ranks[i].toString() + ".",
            style: styleRanking,
            textAlign: TextAlign.right,
          ),
          width: 37,
        ),
        SpaceH(8),
        Text(
          scores[i].name,
          style: styleRanking,
          textAlign: TextAlign.left,
        ),
        Spacer(),
        Text(
          scores[i].score.toString(),
          style: styleRanking,
          textAlign: TextAlign.right,
        ),
        SpaceH(15)
      ]));
      if (i != ranks.length - 1) rows.add(Space(4));
    }

    return Scaffold(
        appBar: CustomAppBar(context, AppLocalizations.of(context)!.finish,
            MenuItemE.COUNT, [getExportMenu(context), getShareButton()]),
        body: Stack(children: [
          RepaintBoundary(
              key: _globalKey,
              child: Container(
                  color: bgcolor,
                  child: ListView(children: <Widget>[
                    Space(20),
                    FullWidthButton(AppLocalizations.of(context)!.menu, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                      );
                    }),
                    Space(20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey[400]!,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.grey[200]),
                      child: Column(children: rows),
                    ),
                    Space(80),
                    Row(children: [
                      SpaceH(32),
                      Expanded(
                          flex: 1,
                          child: Container(
                              //color: Colors.grey[300],
                              height: 200,
                              child: LineChartWidget(getData(),
                                  legendEntries: widget.data.names))),
                      SpaceH(32),
                    ]),
                    Space(8),
                    getRadioButtons(),
                    Visibility(
                        child: Footer(),
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true)
                  ]))),
          Column(children: [Spacer(), Footer()])
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

  Widget getRadioButtons() {
    List<Widget> children = [];

    // Comparison to par, unused.
    /*
      children.add(Row(children: [
        SpaceH(20),
        RadioButton(0, AppLocalizations.of(context)!.current_round, () {
          setState(() {
            generalType = GeneralType.CURRENT;
          });
        }, generalType != GeneralType.CURRENT),
        //SpaceH(4),
        RadioButton(2, AppLocalizations.of(context)!.comp, () {
          setState(() {
            generalType = GeneralType.COMPARE;
          });
        }, generalType != GeneralType.COMPARE),
        Spacer()
      ]));
      children.add(Space(8));
    */

    children.add(
      Row(children: [
        SpaceH(20),
        RadioButton(0, AppLocalizations.of(context)!.single, () {
          setState(() {
            detailType = DetailType.SINGLE;
          });
        }, detailType != DetailType.SINGLE),
        //SpaceH(4),
        RadioButton(2, AppLocalizations.of(context)!.cumulated, () {
          setState(() {
            detailType = DetailType.CUMULATED;
          });
        }, detailType != DetailType.CUMULATED),
        Spacer()
      ]),
    );

    return Column(children: children);
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
