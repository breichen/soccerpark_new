import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../widgets/sharebutton.dart';
import '../widgets/space.dart';

class HoleDialog extends StatelessWidget {
  HoleDialog(this.loc, this.holeId);

  final Locality loc;
  final int holeId;

  GlobalKey _globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RepaintBoundary(
                key: _globalKey,
                child: Container(
                    color: Colors.white,
                    child: Column(children: [
                      Container(
                          color: mainred,
                          padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child: Row(children: [
                            Text(
                              AppLocalizations.of(context)!.hole.toUpperCase() +
                                  " " +
                                  holeId.toString(),
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              Data.getLengthWithLoc(loc, holeId).toString() +
                                  "m",
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "Par " +
                                  Data.getParWithLoc(loc, holeId).toString(),
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            Spacer(),
                            DialogShareButton(
                                _globalKey,
                                AppLocalizations.of(context)!.share_text_hole1 +
                                    " " +
                                    holeId.toString() +
                                    " " +
                                    AppLocalizations.of(context)!
                                        .share_text_hole2 +
                                    " " +
                                    Data.getLocalityStringImm(
                                        App.of(context).getLocality()) +
                                    AppLocalizations.of(context)!.share_text2 +
                                    Data.getWebsiteStringImm(
                                        context, App.of(context).getLocality()))
                          ])),
                      Space(16),
                      getImage(),
                      Space(24),
                      getAddRows(context),
                      Space(10),
                    ]))),
            Space(10),
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

  Widget getAddRows(BuildContext context) {
    List<Widget> rows = [];
    for (var i = 1; i <= 5; i++) {
      String text = Data.getHoleAdd(loc, context, holeId, i);
      if (text == "") break;
      rows.add(getAddRow(text));
      rows.add(Space(4));
    }

    return Column(children: rows);
  }

  Widget getAddRow(String text) {
    return Row(
      children: [
        SpaceH(32),
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget getImage() {
    return Center(
        child: InteractiveViewer(
            scaleEnabled: true,
            panEnabled: false,
            minScale: 0.5,
            maxScale: 2,
            child: Image.asset(Data.getHolePicStrImm(loc, holeId))));
  }
}
