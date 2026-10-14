import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';

class ScoreDialog extends StatelessWidget {
  const ScoreDialog(this.loc, this.holeId, this.name, this.func);

  final Locality loc;
  final int holeId;
  final String name;
  final void Function(int i) func;

  final double size = 70;

  @override
  Widget build(BuildContext context) {
    final int par = Data.getParWithLoc(loc, holeId);
    final int maxi = 2 * par + 1;

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
                      text: AppLocalizations.of(context)!.hole +
                          " " +
                          holeId.toString(),
                      indent: 8,
                      color: Colors.white),
                  Spacer(),
                  Text(
                    name,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ])),
            Space(16),
            Column(children: [getCells(maxi, context)]),
            Space(20),
            Row(children: [
              Spacer(),
              DialogButton(AppLocalizations.of(context)!.clear_hole_score, () {
                func(0);
                Navigator.of(context).pop();
              }),
              SpaceH(20),
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

  Widget getCells(int maxi, BuildContext context) {
    List<Widget> widgets = [];
    for (var j = 1; j <= maxi; j++) {
      widgets.add(getCell(j, context));
    }

    double space = 8;

    return Wrap(
        spacing: space,
        runSpacing: space,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        children: widgets);
  }

  Widget getCell(int i, BuildContext context) {
    return GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            color: mainred,
            child: Text(
              i.toString(),
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        onTap: () {
          func(i);
          Navigator.of(context).pop();
        });
  }
}
