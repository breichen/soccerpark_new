import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/sharebutton.dart';
import '../widgets/space.dart';
import '../widgets/toast.dart';

class PlayHoleDialog extends StatefulWidget {
  PlayHoleDialog(this.loc, this.holeId, this.names, this.scores, this.funcMin,
      this.funcPlus);

  final Locality loc;
  final int holeId;
  final List<String> names;
  final List<int> scores;
  final void Function(int i) funcMin;
  final void Function(int i) funcPlus;

  @override
  State<PlayHoleDialog> createState() => _PlayHoleDialogState();
}

class _PlayHoleDialogState extends State<PlayHoleDialog> {
  final double size = 35;
  final double sizeScore = 40;
  List<String> scoreTexts = [];

  GlobalKey _globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    scoreTexts = [];
    for (var i = 0; i < widget.scores.length; i++)
      scoreTexts.add(widget.scores[i].toString());

    final int par = Data.getParWithLoc(widget.loc, widget.holeId);
    final int maxi = 2 * par + 1;

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
                                  widget.holeId.toString(),
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              Data.getLengthWithLoc(widget.loc, widget.holeId)
                                      .toString() +
                                  "m",
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "Par " +
                                  Data.getParWithLoc(widget.loc, widget.holeId)
                                      .toString(),
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            Spacer(),
                            DialogShareButton(
                                _globalKey,
                                AppLocalizations.of(context)!
                                        .share_text_playhole +
                                    " " +
                                    widget.holeId.toString() +
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
                      Space(10),
                      Column(
                          children:
                              List.generate(widget.names.length, (k) => k + 1)
                                  .map((idx) => Column(children: [
                                        getRow(idx - 1, maxi),
                                        Space(4),
                                      ]))
                                  .toList()),
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

  Widget getImage() {
    return Center(
        child: InteractiveViewer(
            scaleEnabled: true,
            panEnabled: false,
            minScale: 0.5,
            maxScale: 2,
            child:
                Image.asset(Data.getHolePicStrImm(widget.loc, widget.holeId))));
  }

  Row getRow(int i, int maxi) {
    return Row(
      children: [
        SpaceH(32),
        GestureDetector(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                color: mainred,
                child: Text(
                  "-",
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            onTap: () {
              if (widget.scores[i] > 0) {
                setState(() {
                  widget.scores[i] -= 1;
                  scoreTexts[i] = widget.scores[i].toString();
                  widget.funcMin(i + 1);
                });
              } else {
                CustomToast.showToast(context,
                    AppLocalizations.of(context)!.negative_score_error);
              }
            }),
        SpaceH(4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: sizeScore,
            height: sizeScore,
            alignment: Alignment.center,
            color: maincolor,
            child: Text(
              scoreTexts[i],
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SpaceH(4),
        GestureDetector(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                color: mainred,
                child: Text(
                  "+",
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            onTap: () {
              if (widget.scores[i] < maxi) {
                setState(() {
                  widget.scores[i] += 1;
                  scoreTexts[i] = widget.scores[i].toString();
                  widget.funcPlus(i + 1);
                });
              } else {
                CustomToast.showToast(
                    context, AppLocalizations.of(context)!.max_score_error);
              }
            }),
        SpaceH(8),
        Text(
          widget.names[i],
          style: GoogleFonts.lato(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
