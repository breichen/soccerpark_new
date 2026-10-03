import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/widgets/button.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../utils/csv.dart';
import '../utils/pdf.dart';
import '../utils/export.dart';
import '../dialogs/roundtimelinedialog.dart';
import '../dialogs/holedialog.dart';
import '../dialogs/playholedialog.dart';
import '../dialogs/twobuttondialog.dart';
import '../dialogs/scoredialog.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import './mainpage.dart';
import './finishpage.dart';

double tableOuter = 10;
double linewidth = 1;
double dlinewidth = 2;
double holeWidth = 80;
double parwidth = 40;
double fontsize = 17;
double vpad = 2;

TextStyle styleBold = GoogleFonts.lato(
    color: Colors.black,
    fontSize: fontsize,
    fontWeight: FontWeight.bold,
    height: 1.3);
TextStyle styleBoldGreen = GoogleFonts.lato(
    color: maincolor,
    fontSize: fontsize,
    fontWeight: FontWeight.bold,
    height: 1.3);
TextStyle styleBoldRed = GoogleFonts.lato(
    color: mainred,
    fontSize: fontsize,
    fontWeight: FontWeight.bold,
    height: 1.3);
TextStyle styleGen =
    GoogleFonts.lato(color: Colors.black, fontSize: fontsize, height: 1.3);
TextStyle styleGenGreen =
    GoogleFonts.lato(color: maincolor, fontSize: fontsize, height: 1.3);
TextStyle styleGenRed =
    GoogleFonts.lato(color: mainred, fontSize: fontsize, height: 1.3);
TextStyle styleUnderline = GoogleFonts.lato(
    color: Colors.black,
    fontSize: fontsize,
    height: 1.3,
    decoration: TextDecoration.underline);

class RoundPage extends StatefulWidget {
  const RoundPage(this.roundWidget);

  final int roundWidget;

  @override
  State<RoundPage> createState() => _RoundPageState(roundWidget);
}

class _RoundPageState extends State<RoundPage> {
  GlobalKey _globalKey = new GlobalKey();

  Locality loc = Locality.SALZBURG;
  bool comp = false;

  List<String> names = [];
  List<List<int>> scores = [];
  List<List<String>> scoreTexts = [];
  List<int> totalScores = [];
  List<String> totalScoreTexts = [];
  List<int> pars = [];
  List<String> parTexts = [];
  int round;
  List<List<int>> prevScores = [];
  List<int> prevTotalScores = [];

  _RoundPageState(this.round);

  @override
  void initState() {
    super.initState();
    setState(() {
      comp = App.of(context).isCompare();
    });

    Data.getRoundData(round).then((roundData) => {
          setState(() {
            loc = roundData.loc;
            names = roundData.names;
            print("names size " + roundData.names.length.toString());
            scores = roundData.scores;
            for (var pl = 0; pl < names.length; pl++) {
              scoreTexts.add([]);
              int sum = 0;
              for (var hole = 0; hole < 18; hole++) {
                int score = scores[pl][hole];
                sum += score;
                scoreTexts.last.add(score == 0 ? " " : score.toString());
              }
              totalScores.add(sum);
              totalScoreTexts.add(sum == 0 ? " " : sum.toString());
            }

            pars = Data.getPars(loc);
            for (var i = 0; i < pars.length; i++)
              parTexts.add(pars[i].toString());
          })
        });

    Data.getPreviousScores(true).then((prev) => {
          for (var i = 0; i < prev.length; i++)
            {
              prevTotalScores
                  .add(prev[i].isEmpty ? 0 : prev[i].reduce((a, b) => a + b))
            },
          setState(() {
            prevScores = prev;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    final double sep = 8;
    return Scaffold(
      appBar: CustomAppBar(context, AppLocalizations.of(context)!.round,
          MenuItemE.COUNT, getQuickButtons(context)),
      body: ListView(children: <Widget>[
        Space(10),
        Row(children: [Spacer(), HeaderLogo(), Spacer()]),
        Space(10),
        getTable(),
        Space(10),
        getButtonRow(),
        Space(10),
        //Spacer(),
        Footer()
      ]),
    );
  }

  Widget getTable() {
    return RepaintBoundary(
        key: _globalKey,
        child: Container(
            color: bgcolor,
            child: Column(children: [
              Space(10),
              getHeaderRow(),
              Column(
                  children: List<int>.generate(17, (k) => k + 1)
                      .map((idx) => Column(children: [
                            getTableRow(idx),
                          ]))
                      .toList()),
              getTableRow(18),
              getLastRow(),
              Space(10),
            ])));
  }

  Widget getButtonRow() {
    return round == 0
        ? Row(children: [
            SpaceH(10),
            Expanded(
                flex: 9,
                child:
                    FullWidthButton(AppLocalizations.of(context)!.cancel, () {
                  TwoButtonDialog dialog = TwoButtonDialog(
                      AppLocalizations.of(context)!.cancel_round,
                      AppLocalizations.of(context)!.ask_cancel_round,
                      AppLocalizations.of(context)!.back,
                      AppLocalizations.of(context)!.cancel_round, () {
                    Navigator.of(context).pop();
                  }, () {
                    Data.clearCurrent();
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  });
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => dialog);
                }, padding: 10)),
            Expanded(
                flex: 11,
                child: isFinished()
                    ? FullWidthButton(
                        AppLocalizations.of(context)!.finish_round, () {
                        Data.shift();
                        setState(() {
                          round = 1;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FinishPage(
                                  RoundData(loc, names, scores), pars)),
                        );
                      }, padding: 10)
                    : Container()),
            SpaceH(10),
          ])
        : Row();
  }

  Widget getHeaderRow() {
    List<Widget> widgets = [
      SpaceH(tableOuter),
      getHeaderCellFix(AppLocalizations.of(context)!.hole, holeWidth, true, 0,
          0, linewidth, dlinewidth),
      getHeaderCellFix(
          "Par", parwidth, false, linewidth, 0, dlinewidth, dlinewidth),
    ];
    for (var i = 0; i < names.length; i++)
      widgets.add(getHeaderCell(names[i], i == 0 ? dlinewidth : linewidth, 0,
          i == names.length - 1 ? 0 : linewidth, dlinewidth));
    widgets.add(SpaceH(tableOuter));

    return Row(mainAxisSize: MainAxisSize.min, children: widgets);
  }

  Widget getLastRow() {
    List<Widget> widgets = [
      SpaceH(tableOuter),
      getHeaderCellFix(AppLocalizations.of(context)!.sum, holeWidth, true, 0,
          linewidth, linewidth, 0),
      getHeaderCellFix(
          "72", parwidth, false, linewidth, linewidth, dlinewidth, 0)
    ];
    for (var i = 0; i < names.length; i++)
      widgets.add(getTotalCell(i + 1, i == 0 ? dlinewidth : linewidth,
          linewidth, i == names.length - 1 ? 0 : linewidth, 0));
    widgets.add(SpaceH(tableOuter));

    return Row(mainAxisSize: MainAxisSize.min, children: widgets);
  }

  void updateScore(int pl, int hole) {
    setState(() {
      int score = scores[pl - 1][hole - 1];
      scoreTexts[pl - 1][hole - 1] = score == 0 ? " " : score.toString();
      Data.storeScore(round, pl, hole, scores[pl - 1][hole - 1]);

      int sum = 0;
      for (var h = 0; h < 18; h++) sum += scores[pl - 1][h];

      totalScores[pl - 1] = sum;
      totalScoreTexts[pl - 1] = sum.toString();
    });
  }

  void incScore(int pl, int hole) {
    scores[pl - 1][hole - 1] += 1;
    updateScore(pl, hole);
  }

  void decScore(int pl, int hole) {
    scores[pl - 1][hole - 1] -= 1;
    updateScore(pl, hole);
  }

  void setScore(int pl, int hole, int score) {
    scores[pl - 1][hole - 1] = score;
    updateScore(pl, hole);
  }

  Widget getTableRow(int holeId) {
    final double top = holeId == 1 ? dlinewidth : linewidth;
    final double bottom = holeId == 18 ? dlinewidth : linewidth;

    List<Widget> widgets = [
      SpaceH(tableOuter),
      GestureDetector(
          onTap: () {
            List<int> tmp = [];
            for (var i = 0; i < names.length; i++)
              tmp.add(scores[i][holeId - 1]);

            Widget dialog = round == 0
                ? PlayHoleDialog(loc, holeId, names, tmp, (int i) {
                    decScore(i, holeId);
                  }, (int i) {
                    incScore(i, holeId);
                  })
                : HoleDialog(loc, holeId);
            showDialog(
                context: context, builder: (BuildContext context) => dialog);
          },
          child: getCellFix(
              AppLocalizations.of(context)!.hole + " " + holeId.toString(),
              holeWidth,
              true,
              0,
              top,
              linewidth,
              bottom,
              true)),
      GestureDetector(
          onTap: () {
            List<int> tmp = [];
            for (var i = 0; i < names.length; i++)
              tmp.add(scores[i][holeId - 1]);

            Widget dialog = round == 0
                ? PlayHoleDialog(loc, holeId, names, tmp, (int i) {
                    decScore(i, holeId);
                  }, (int i) {
                    incScore(i, holeId);
                  })
                : HoleDialog(loc, holeId);
            showDialog(
                context: context, builder: (BuildContext context) => dialog);
          },
          child: getCellFix(parTexts.isEmpty ? "" : parTexts[holeId - 1],
              parwidth, false, linewidth, top, dlinewidth, bottom, false)),
    ];
    for (var i = 0; i < names.length; i++)
      widgets.add(getCell(i + 1, holeId, i == 0 ? dlinewidth : linewidth, top,
          i == names.length - 1 ? 0 : linewidth, bottom));
    widgets.add(SpaceH(tableOuter));

    return Row(mainAxisSize: MainAxisSize.min, children: widgets);
  }

  Widget getHeaderCellFix(String text, double width, bool alignleft,
      double left, double top, double right, double bottom) {
    return Container(
      decoration: getDecoration(left, top, right, bottom),
      child: Text(text,
          maxLines: 1,
          textAlign: alignleft ? TextAlign.left : TextAlign.center,
          style: styleBold),
      width: width,
      padding: EdgeInsets.fromLTRB(0, vpad, 0, vpad),
    );
  }

  Widget getHeaderCell(
      String text, double left, double top, double right, double bottom) {
    return Expanded(
        child: Container(
            decoration: getDecoration(left, top, right, bottom),
            child: Text(text,
                maxLines: 1, textAlign: TextAlign.center, style: styleBold),
            padding: EdgeInsets.fromLTRB(0, vpad, 0, vpad)));
  }

  Widget getTotalCell(
      int pl, double left, double top, double right, double bottom) {
    return Expanded(child: getTotalCellContainer(pl, left, top, right, bottom));
  }

  Widget getTotalCellContainer(
      int pl, double left, double top, double right, double bottom) {
    return Container(
        decoration: getDecoration(left, top, right, bottom),
        child: comp
            ? getTotalCellContentWithComp(pl)
            : getTotalCellContentNoComp(pl),
        padding: EdgeInsets.fromLTRB(0, vpad, 0, vpad));
  }

  Widget getTotalCellContentWithComp(int pl) {
    if (prevTotalScores.length < pl || prevTotalScores[pl - 1] == 0)
      return getTotalCellContentNoComp(pl);

    return RichText(
      text: TextSpan(children: [
        WidgetSpan(
            child: getTotalCellCompText(pl),
            alignment: PlaceholderAlignment.top),
        WidgetSpan(child: SpaceH(2)),
        WidgetSpan(child: getTotalCellMainText(pl))
      ]),
      textAlign: TextAlign.center,
    );
  }

  Widget getTotalCellContentNoComp(int pl) {
    return getTotalCellMainText(pl);
  }

  Text getTotalCellMainText(int pl) {
    return Text(totalScoreTexts[pl - 1],
        maxLines: 1,
        textAlign: TextAlign.center,
        style: totalScores[pl - 1] < 72
            ? styleBoldGreen
            : (totalScores[pl - 1] > 72 ? styleBoldRed : styleBold));
  }

  Widget getTotalCellCompText(int pl) {
    final double compwidth = 10;

    int score = totalScores[pl - 1];
    if (score == 0) return SizedBox(child: Text(""), width: compwidth);

    int prev = prevTotalScores[pl - 1];
    int diff = score - prev;
    if (diff == 0) return SizedBox(child: Text(""), width: compwidth);

    String prefix = diff > 0 ? "+" : "";
    Color color = diff > 0 ? mainred : maincolor;

    return Text(prefix + diff.toString(),
        maxLines: 1,
        textAlign: TextAlign.right,
        style: GoogleFonts.lato(
            color: color,
            fontSize: 10,
            height: 1.0,
            fontWeight: FontWeight.bold));
  }

  Widget getCellFix(String text, double width, bool alignleft, double left,
      double top, double right, double bottom, bool underline) {
    return Container(
        decoration: getDecoration(left, top, right, bottom),
        child: Text(text,
            maxLines: 1,
            textAlign: alignleft ? TextAlign.left : TextAlign.center,
            style: underline ? styleUnderline : styleGen),
        width: width,
        padding: EdgeInsets.fromLTRB(0, vpad, 0, vpad));
  }

  Widget getCell(
      int pl, int hole, double left, double top, double right, double bottom) {
    return Expanded(
        child: GestureDetector(
            onTap: () {
              if (round == 0) {
                ScoreDialog dialog =
                    ScoreDialog(loc, hole, names[pl - 1], (int score) {
                  setScore(pl, hole, score);
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) => dialog);
              }
            },
            child: getCellContainer(pl, hole, left, top, right, bottom)));
  }

  Widget getCellContainer(
      int pl, int hole, double left, double top, double right, double bottom) {
    return Container(
        decoration: getDecoration(left, top, right, bottom),
        child: comp
            ? getCellContentWithComp(pl, hole)
            : getCellContentNoComp(pl, hole),
        padding: EdgeInsets.fromLTRB(0, vpad, 0, vpad));
  }

  Widget getCellContentWithComp(int pl, int hole) {
    if (prevScores.length < pl || prevScores[pl - 1].isEmpty)
      return getCellContentNoComp(pl, hole);

    return RichText(
      text: TextSpan(children: [
        WidgetSpan(
            child: getCellCompText(pl, hole),
            alignment: PlaceholderAlignment.top),
        WidgetSpan(child: SpaceH(2)),
        WidgetSpan(child: getCellMainText(pl, hole))
      ]),
      textAlign: TextAlign.center,
    );
  }

  Widget getCellContentNoComp(int pl, int hole) {
    return getCellMainText(pl, hole);
  }

  Text getCellMainText(int pl, int hole) {
    return Text(scoreTexts[pl - 1][hole - 1],
        maxLines: 1,
        textAlign: TextAlign.center,
        style: getTextStyle(pl, hole));
  }

  Widget getCellCompText(int pl, int hole) {
    final double compwidth = 10;

    int score = scores[pl - 1][hole - 1];
    if (score == 0) return SizedBox(child: Text(""), width: compwidth);

    int prev = prevScores[pl - 1][hole - 1];
    int diff = score - prev;
    if (diff == 0) return SizedBox(child: Text(""), width: compwidth);

    String prefix = diff > 0 ? "+" : "";
    Color color = diff > 0 ? mainred : maincolor;

    return Text(prefix + diff.toString(),
        maxLines: 1,
        textAlign: TextAlign.right,
        style: GoogleFonts.lato(color: color, fontSize: 10, height: 1.0));
  }

  TextStyle getTextStyle(int pl, int hole) {
    return scores[pl - 1][hole - 1] < pars[hole - 1]
        ? styleGenGreen
        : (scores[pl - 1][hole - 1] > pars[hole - 1] ? styleGenRed : styleGen);
  }

  Decoration getDecoration(
      double left, double top, double right, double bottom) {
    if (left == 0.0) {
      if (top == 0.0)
        return BoxDecoration(
          border: Border(
            left: BorderSide(width: left, color: Colors.grey[300]!),
            bottom: BorderSide(width: bottom, color: Colors.grey[300]!),
          ),
        );
      else if (bottom == 0.0)
        return BoxDecoration(
          border: Border(
            left: BorderSide(width: left, color: Colors.grey[300]!),
            top: BorderSide(width: top, color: Colors.grey[300]!),
          ),
        );
      else
        return BoxDecoration(
          border: Border(
            left: BorderSide(width: left, color: Colors.grey[300]!),
            top: BorderSide(width: top, color: Colors.grey[300]!),
            bottom: BorderSide(width: bottom, color: Colors.grey[300]!),
          ),
        );
    } else if (right == 0.0) {
      if (top == 0.0)
        return BoxDecoration(
          border: Border(
            left: BorderSide(width: left, color: Colors.grey[300]!),
            bottom: BorderSide(width: bottom, color: Colors.grey[300]!),
          ),
        );
      else if (bottom == 0.0)
        return BoxDecoration(
          border: Border(
            left: BorderSide(width: left, color: Colors.grey[300]!),
            top: BorderSide(width: top, color: Colors.grey[300]!),
          ),
        );
      else
        return BoxDecoration(
          border: Border(
            left: BorderSide(width: left, color: Colors.grey[300]!),
            top: BorderSide(width: top, color: Colors.grey[300]!),
            bottom: BorderSide(width: bottom, color: Colors.grey[300]!),
          ),
        );
    } else if (top == 0.0)
      return BoxDecoration(
        border: Border(
          left: BorderSide(width: left, color: Colors.grey[300]!),
          right: BorderSide(width: right, color: Colors.grey[300]!),
          bottom: BorderSide(width: bottom, color: Colors.grey[300]!),
        ),
      );
    else if (bottom == 0.0)
      return BoxDecoration(
        border: Border(
          left: BorderSide(width: left, color: Colors.grey[300]!),
          top: BorderSide(width: top, color: Colors.grey[300]!),
          right: BorderSide(width: right, color: Colors.grey[300]!),
        ),
      );
    return BoxDecoration(
      border: Border(
        left: BorderSide(width: left, color: Colors.grey[300]!),
        top: BorderSide(width: top, color: Colors.grey[300]!),
        right: BorderSide(width: right, color: Colors.grey[300]!),
        bottom: BorderSide(width: bottom, color: Colors.grey[300]!),
      ),
    );
  }

  bool isFinished() {
    assert(round == 0);

    for (var pl = 0; pl < names.length; pl++) {
      for (var hole = 0; hole < 18; hole++) {
        if (scores[pl][hole] == 0) return false;
      }
    }
    return true;
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

    if (round == 0)
      return [getTimelineButton(), shareB];
    else
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

  void exportCsv() {
    print("exportCsv");
    Data.getDate(round).then((date) => generateCsvSingleRound(
        context, date, names, scores, totalScores, date));
  }

  void exportPdf() {
    Data.getDate(round)
        .then((date) => generatePdfSingleRound(context, round, date));
  }

  List<List<String>> getCsvData(String date) {
    return getCsvDataSingleRound(date, names, scores, totalScores);
  }

  getTimelineButton() {
    return TimelineButton(() {
      RoundTimelineDialog dialog =
          RoundTimelineDialog(loc, names, scores, pars);
      showDialog(context: context, builder: (BuildContext context) => dialog);
    });
  }
}
