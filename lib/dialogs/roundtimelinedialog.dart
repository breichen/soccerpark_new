import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/appdialog.dart';
import '../widgets/chart.dart';

class RoundTimelineDialog extends StatefulWidget {
  const RoundTimelineDialog(this.loc, this.names, this.scores, this.pars);

  final Locality loc;
  final List<String> names;
  final List<List<int>> scores;
  final List<int> pars;

  @override
  State<RoundTimelineDialog> createState() => _RoundTimelineDialogState();
}

class ScorePair {
  String name;
  int score;

  ScorePair(this.name, this.score);
}

enum GeneralType { CURRENT, COMPARE }

enum DetailType { SINGLE, CUMULATED }

class _RoundTimelineDialogState extends State<RoundTimelineDialog> {
  GlobalKey _globalKey = new GlobalKey();
  GeneralType generalType = GeneralType.CURRENT;
  DetailType detailType = DetailType.SINGLE;

  final List<List<List<PointPair>>> chartData = [[], [], [], []];

  @override
  void initState() {
    super.initState();

    setState(() {
      initChartData();
    });
  }

  void initChartData() {
    for (var pl = 0; pl < widget.names.length; pl++) {
      chartData[0].add([]);
      chartData[1].add([]);

      int sum = 0;
      for (var hole = 1; hole <= 18; hole++) {
        int score = widget.scores[pl][hole - 1];
        if (score == 0) continue;

        sum += score;
        chartData[0].last.add(PointPair(hole, score.toDouble()));
        chartData[1].last.add(PointPair(hole, sum.toDouble()));
      }

      chartData[2].add([]);
      chartData[3].add([]);

      int compSum = 0;
      for (var hole = 1; hole <= 18; hole++) {
        int score = widget.scores[pl][hole - 1];
        if (score == 0) continue;

        int diff = score - widget.pars[hole - 1];
        compSum += diff;
        chartData[2].last.add(PointPair(hole, diff.toDouble()));
        chartData[3].last.add(PointPair(hole, compSum.toDouble()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    String cap(String t) => t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);

    return AppDialog(
        title: l.timeline,
        child: Column(children: [
          RepaintBoundary(
              key: _globalKey,
              child: Container(
                  color: bgcolor,
                  height: 240,
                  child: LineChartWidget(getData(),
                      addDummy: true,
                      legendEntries: widget.names,
                      parLine: getParLine(),
                      tooltipTitle: (x) => l.hole + " $x"))),
          SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              child: SegmentedButton<DetailType>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  foregroundColor: maincolor,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: maincolor,
                  side: BorderSide(color: maincolor),
                  textStyle:
                      GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                segments: [
                  ButtonSegment(
                      value: DetailType.SINGLE, label: Text(cap(l.single))),
                  ButtonSegment(
                      value: DetailType.CUMULATED,
                      label: Text(cap(l.cumulated))),
                ],
                selected: {detailType},
                onSelectionChanged: (sel) =>
                    setState(() => detailType = sel.first),
              )),
        ]));
  }

  /// Par-Linie zur aktuellen Ansicht (nicht beim Vergleich mit Par).
  List<double>? getParLine() {
    if (generalType != GeneralType.CURRENT) return null;
    return detailType == DetailType.SINGLE
        ? LineChartWidget.holeParLine(widget.pars)
        : LineChartWidget.cumulativeParLine(widget.pars);
  }

  List<List<PointPair>> getData() {
    if (generalType == GeneralType.CURRENT) {
      if (detailType == DetailType.SINGLE) return chartData[0];
      return chartData[1];
    }
    if (detailType == DetailType.SINGLE) return chartData[2];
    return chartData[3];
  }
}
