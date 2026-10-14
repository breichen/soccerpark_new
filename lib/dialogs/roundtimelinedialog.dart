import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/sharebutton.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';
import '../widgets/radio.dart';
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
    print("w");
    print(Theme.of(context).dialogTheme.backgroundColor);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                color: mainred,
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(children: [
                  TitleText(
                      text: AppLocalizations.of(context)!.timeline,
                      indent: 8,
                      color: Colors.white),
                  Spacer(),
                  /*DialogShareButton(
                      _globalKey,
                      AppLocalizations.of(context)!.share_text +
                          " " +
                          Data.getLocalityStringImm(
                              App.of(context).getLocality()) +
                          AppLocalizations.of(context)!.share_text2 +
                          Data.getWebsiteStringImm(
                              context, App.of(context).getLocality()))*/
                ])),
            Space(32),
            Row(children: [
              SpaceH(8),
              Expanded(
                  flex: 1,
                  child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                          //color: ColorScheme.of(context).surfaceContainerHigh,
                          height: 200,
                          child: LineChartWidget(getData(),
                              addDummy: true, legendEntries: widget.names)))),
              SpaceH(16),
            ]),
            Space(8),
            getRadioButtons(),
            Space(20),
            Row(children: [
              Spacer(),
              DialogButton(AppLocalizations.of(context)!.back, () {
                Navigator.of(context).pop();
              }),
              SpaceH(20)
            ]),
            Space(10),
          ],
        ),
      ),
    );
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
      }, generalType != GeneralType.CURRENT, small: true),
      //SpaceH(4),
      RadioButton(2, AppLocalizations.of(context)!.comp, () {
        setState(() {
          generalType = GeneralType.COMPARE;
        });
      }, generalType != GeneralType.COMPARE, small: true),
      Spacer()
    ]));
    children.add(Space(8));*/

    children.add(
      Row(children: [
        SpaceH(20),
        RadioButton(0, AppLocalizations.of(context)!.single, () {
          setState(() {
            detailType = DetailType.SINGLE;
          });
        }, detailType != DetailType.SINGLE, small: true),
        //SpaceH(4),
        RadioButton(2, AppLocalizations.of(context)!.cumulated, () {
          setState(() {
            detailType = DetailType.CUMULATED;
          });
        }, detailType != DetailType.CUMULATED, small: true),
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
}
