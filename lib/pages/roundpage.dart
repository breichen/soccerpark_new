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
import '../widgets/space.dart';
import './mainpage.dart';
import './finishpage.dart';

double tableOuter = 10;
double tableInner = 10;
double linewidth = 1;
double dlinewidth = 2;
double holeWidth = 80;
double parwidth = 40;
double fontsize = 17;
double vpad = 8;
final fontheight = 1.3;

TextStyle styleBold = GoogleFonts.lato(
    color: Colors.black,
    fontSize: fontsize,
    //fontWeight: FontWeight.bold,
    height: fontheight);
TextStyle styleBoldGreen = GoogleFonts.lato(
    color: maincolor,
    fontSize: fontsize,
    //fontWeight: FontWeight.bold,
    height: fontheight);
TextStyle styleBoldRed = GoogleFonts.lato(
    color: mainred,
    fontSize: fontsize,
    //fontWeight: FontWeight.bold,
    height: fontheight);
TextStyle styleGen = GoogleFonts.lato(
    color: Colors.black, fontSize: fontsize, height: fontheight);
TextStyle styleGenGreen =
    GoogleFonts.lato(color: maincolor, fontSize: fontsize, height: fontheight);
TextStyle styleGenRed =
    GoogleFonts.lato(color: mainred, fontSize: fontsize, height: fontheight);
TextStyle styleUnderline = GoogleFonts.lato(
    color: Colors.black,
    fontSize: fontsize,
    height: fontheight,
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

  final double wbound = 350.0;

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
    return Scaffold(
      appBar: CustomAppBar(context, AppLocalizations.of(context)!.round,
          MenuItemE.COUNT, getQuickButtons(context)),
      body: Stack(children: [
        ListView(children: <Widget>[
          getTable(),
          Visibility(
              child: getFooter(),
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true)
        ]),
        Column(children: [getHeaderRow(), Spacer()]),
        Column(children: [Spacer(), getFooter()])
      ]),
    );
  }

  Widget getFooter() {
    return Column(
        children: [getLastRow(), getButtonRowVisible()]);
  }

  Widget getTable() {
    List<Widget> rows = [];
    for (var i = 1; i <= 10; i++)
      rows.add(Column(children: [
        getTableRow(i),
      ]));
    if (App.of(context).isIntermediate()) rows.add(getIntermediateRow());
    for (var i = 11; i <= 18; i++)
      rows.add(Column(children: [
        getTableRow(i),
      ]));
    if (App.of(context).isIntermediate()) rows.add(getSecondPartRow());

    return RepaintBoundary(
        key: _globalKey,
        child: Container(
            color: bgcolor,
            child: Column(children: [getHeaderRow(), Column(children: rows)])));
  }

  Widget getButtonRowVisible() {
    return Visibility(visible: round == 0, child: getButtonRow());
  }

  Widget getButtonRow() {
    return SizedBox(
        child: Container(
            child: round == 0
                ? Row(children: [
                    SpaceH(10),
                    Expanded(flex: 1, child: getCancelButton()),
                    Expanded(flex: 1, child: getFinishButton()),
                    SpaceH(10),
                  ])
                : Row(),
            color: mainred),
        height: 40);
  }

  Widget getCancelButton() {
    return RedFullWidthButton(AppLocalizations.of(context)!.cancel, () {
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
      showDialog(context: context, builder: (BuildContext context) => dialog);
    }, padding: 10);
  }

  Widget getFinishButton() {
    return isFinished()
        ? RedFullWidthButton(AppLocalizations.of(context)!.finish_round, () {
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
          }, padding: 10)
        : Container();
  }

  Widget getHeaderRow() {
    List<Widget> widgets = [
      getHeaderCellFix(AppLocalizations.of(context)!.hole, holeWidth, true, 0,
          0, linewidth, dlinewidth),
      getHeaderCellFix(
          "Par", parwidth, false, linewidth, 0, dlinewidth, dlinewidth),
    ];
    for (var i = 0; i < names.length; i++)
      widgets.add(getHeaderCell(names[i], i == 0 ? dlinewidth : linewidth, 0,
          i == names.length - 1 ? 0 : linewidth, dlinewidth));

    return Container(
        color: Colors.grey[200],
        child: Row(mainAxisSize: MainAxisSize.min, children: widgets));
  }

  Widget getLastRow() {
    List<Widget> widgets = [
      getHeaderCellFix(
          isDisplaySmall()
              ? AppLocalizations.of(context)!.sum_short
              : AppLocalizations.of(context)!.sum,
          holeWidth,
          true,
          0,
          linewidth,
          linewidth,
          0),
      getHeaderCellFix(
          "72", parwidth, false, linewidth, linewidth, dlinewidth, 0)
    ];
    for (var i = 0; i < names.length; i++)
      widgets.add(getTotalCell(i + 1, i == 0 ? dlinewidth : linewidth,
          linewidth, i == names.length - 1 ? 0 : linewidth, 0, 1, 18));

    return Container(
        color: Colors.grey[200],
        child: Row(mainAxisSize: MainAxisSize.min, children: widgets));
  }

  Widget getIntermediateRow() {
    int par = 0;
    if (pars.length >= 10) {
      for (var i = 0; i < 10; i++) par += pars[i];
    }

    List<Widget> widgets = [
      getHeaderCellFix(
          "1 - 10", holeWidth, true, 0, dlinewidth, linewidth, dlinewidth),
      getHeaderCellFix(par.toString(), parwidth, false, linewidth, dlinewidth,
          dlinewidth, dlinewidth)
    ];
    for (var i = 0; i < names.length; i++)
      widgets.add(getTotalCell(
          i + 1,
          i == 0 ? dlinewidth : linewidth,
          dlinewidth,
          i == names.length - 1 ? 0 : linewidth,
          dlinewidth,
          1,
          10));

    return Container(
        color: Colors.grey[200],
        child: Row(mainAxisSize: MainAxisSize.min, children: widgets));
  }

  Widget getSecondPartRow() {
    int par = 0;
    if (pars.length >= 18) {
      for (var i = 10; i < 18; i++) par += pars[i];
    }

    List<Widget> widgets = [
      getHeaderCellFix(
          "11 - 18", holeWidth, true, 0, dlinewidth, linewidth, dlinewidth),
      getHeaderCellFix(par.toString(), parwidth, false, linewidth, dlinewidth,
          dlinewidth, dlinewidth)
    ];
    for (var i = 0; i < names.length; i++)
      widgets.add(getTotalCell(
          i + 1,
          i == 0 ? dlinewidth : linewidth,
          dlinewidth,
          i == names.length - 1 ? 0 : linewidth,
          dlinewidth,
          11,
          18));

    return Container(
        color: Colors.grey[200],
        child: Row(mainAxisSize: MainAxisSize.min, children: widgets));
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
              (isDisplaySmall()
                      ? AppLocalizations.of(context)!.hole_short
                      : AppLocalizations.of(context)!.hole) +
                  " " +
                  holeId.toString(),
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

    return Row(mainAxisSize: MainAxisSize.min, children: widgets);
  }

  Widget getHeaderCellFix(String text, double width, bool alignleft,
      double left, double top, double right, double bottom) {
    return Container(
        decoration: getDecoration(left, top, right, bottom),
        child: Stack(
            alignment: alignleft ? Alignment.centerLeft : Alignment.center,
            children: [
              Text(text,
                  maxLines: 1,
                  textAlign: alignleft ? TextAlign.left : TextAlign.center,
                  style: styleBold),
              alignleft ? getHiddenHole() : getHiddenPar()
            ]),
        padding: EdgeInsets.fromLTRB(
            alignleft ? tableOuter : tableInner, vpad, tableInner, vpad));
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

  Widget getTotalCell(int pl, double left, double top, double right,
      double bottom, int startHole, int endHole) {
    return Expanded(
        child: getTotalCellContainer(
            pl, left, top, right, bottom, startHole, endHole));
  }

  Widget getTotalCellContainer(int pl, double left, double top, double right,
      double bottom, int startHole, int endHole) {
    return Container(
        decoration: getDecoration(left, top, right, bottom),
        child: getTotalCellContentWithCompPar(pl, startHole, endHole),
        padding: EdgeInsets.fromLTRB(0, vpad, 0, vpad));
  }

  Widget getTotalCellContentWithCompPar(int pl, int startHole, int endHole) {
    return RichText(
      text: TextSpan(children: [
        WidgetSpan(
            child: getTotalCellCompParText(pl, startHole, endHole),
            alignment: PlaceholderAlignment.top),
        WidgetSpan(child: SpaceH(2)),
        WidgetSpan(child: getTotalCellMainText(pl, startHole, endHole)),
        WidgetSpan(child: SpaceH(2)),
        WidgetSpan(
            child: getTotalCellCompDummyText(),
            alignment: PlaceholderAlignment.top),
      ]),
      textAlign: TextAlign.center,
    );
  }

  Widget getTotalCellCompDummyText() {
    final double compwidth = 10;
    return SizedBox(child: Text(""), width: compwidth);
  }

  // Used before implementing comparison with par.
  Widget getTotalCellContainerOld(int pl, double left, double top, double right,
      double bottom, int startHole, int endHole) {
    return Container(
        decoration: getDecoration(left, top, right, bottom),
        child: comp
            ? getTotalCellContentWithComp(pl, startHole, endHole)
            : getTotalCellContentNoComp(pl, startHole, endHole),
        padding: EdgeInsets.fromLTRB(0, vpad, 0, vpad));
  }

  // Used before implementing comparison with par.
  Widget getTotalCellContentWithComp(int pl, int startHole, int endHole) {
    if (prevTotalScores.length < pl || prevTotalScores[pl - 1] == 0)
      return getTotalCellContentNoComp(pl, startHole, endHole);

    return RichText(
      text: TextSpan(children: [
        WidgetSpan(
            child: getTotalCellCompText(pl, startHole, endHole),
            alignment: PlaceholderAlignment.top),
        WidgetSpan(child: SpaceH(2)),
        WidgetSpan(child: getTotalCellMainText(pl, startHole, endHole))
      ]),
      textAlign: TextAlign.center,
    );
  }

  // Used before implementing comparison with par.
  Widget getTotalCellContentNoComp(int pl, int startHole, int endHole) {
    return getTotalCellMainText(pl, startHole, endHole);
  }

  Text getTotalCellMainText(int pl, int startHole, int endHole) {
    String text = totalScoreTexts[pl - 1];
    int total = totalScores[pl - 1];
    if (startHole != 1 || endHole != 18) {
      total = getTotalScore(pl, startHole, endHole);
      text = total > 0 ? total.toString() : "";
    }

    int par = getParPlayed(pl, startHole, endHole);
    return Text(text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: total < par
            ? styleBoldGreen
            : (total > par ? styleBoldRed : styleBold));
  }

  int getParPlayed(int pl, int startHole, int endHole) {
    int par = 0;
    for (var hole = startHole; hole <= endHole; hole++) {
      if (scores[pl - 1][hole - 1] > 0) par += pars[hole - 1];
    }
    return par;
  }

  int getTotalScore(int pl, int startHole, int endHole) {
    if (startHole == 1 && endHole == 18) return totalScores[pl - 1];

    int total = 0;
    for (var i = startHole; i <= endHole; i++) total += scores[pl - 1][i - 1];
    return total;
  }

  Widget getTotalCellCompParText(int pl, int startHole, int endHole) {
    final double compwidth = 10;

    int diff = getTotalParDiff(pl, startHole, endHole);
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

  // Used before implementing comparison with par.
  Widget getTotalCellCompText(int pl, int startHole, int endHole) {
    final double compwidth = 10;

    int diff = getTotalDiff(pl, startHole, endHole);
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

  int getTotalParDiff(int pl, int startHole, int endHole) {
    int totalScore = getTotalScore(pl, startHole, endHole);
    if (totalScore == 0) return 0;

    int diff = totalScore - getParPlayed(pl, startHole, endHole);
    return diff;
  }

  int getTotalDiff(int pl, int startHole, int endHole) {
    int totalScore = getTotalScore(pl, startHole, endHole);
    if (totalScore == 0) return 0;

    int diff = 0;
    for (var hole = startHole; hole <= endHole; hole++) {
      int score = scores[pl - 1][hole - 1];
      if (score == 0) continue;

      int prev = prevScores[pl - 1][hole - 1];
      diff += score - prev;
    }

    return diff;
  }

  Widget getCellFix(String text, double width, bool alignleft, double left,
      double top, double right, double bottom, bool underline) {
    return Container(
        decoration: getDecoration(left, top, right, bottom),
        child: Stack(
            alignment: alignleft ? Alignment.centerLeft : Alignment.center,
            children: [
              Text(text,
                  maxLines: 1,
                  textAlign: alignleft ? TextAlign.left : TextAlign.center,
                  style: underline ? styleUnderline : styleGen),
              alignleft ? getHiddenHole() : getHiddenPar()
            ]),
        padding: EdgeInsets.fromLTRB(
            alignleft ? tableOuter : tableInner, vpad, tableInner, vpad));
  }

  Widget getHiddenHole() {
    return Visibility(
        child: Text(
            AppLocalizations.of(context)!.hole +
                (isDisplaySmall() ? "" : " 18"),
            style: styleGen),
        visible: false,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true);
  }

  Widget getHiddenPar() {
    return Visibility(
        child: Text("Par", style: styleGen),
        visible: false,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true);
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
        child: getCellContentNoComp(pl, hole),
        padding: EdgeInsets.fromLTRB(0, vpad, 0, vpad));
  }

  // Used before implementing comparison to par.
  Widget getCellContainerOld(
      int pl, int hole, double left, double top, double right, double bottom) {
    return Container(
        decoration: getDecoration(left, top, right, bottom),
        child: comp
            ? getCellContentWithComp(pl, hole)
            : getCellContentNoComp(pl, hole),
        padding: EdgeInsets.fromLTRB(0, vpad, 0, vpad));
  }

  // Used before implementing comparison to par.
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

  Widget getCellCompParText(int pl, int hole) {
    final double compwidth = 10;
    final TextStyle style = GoogleFonts.lato(fontSize: 10, height: 1.0);

    int score = scores[pl - 1][hole - 1];
    if (score == 0)
      return SizedBox(child: Text("", style: style), width: compwidth);

    int diff = score - pars[hole - 1];
    if (diff == 0)
      return SizedBox(child: Text("", style: style), width: compwidth);

    String prefix = diff > 0 ? "+" : "";
    Color color = diff > 0 ? mainred : maincolor;

    return Text(prefix + diff.toString(),
        maxLines: 1,
        textAlign: TextAlign.right,
        style: GoogleFonts.lato(color: color, fontSize: 10, height: 1.0));
  }

  // Used before implementing comparison to par.
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

  bool isDisplaySmall() {
    return MediaQuery.of(context).size.width < 350;
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
