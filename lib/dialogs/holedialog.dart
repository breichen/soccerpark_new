import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/space.dart';
import './holedialogparts.dart';

/// Info zu einer Bahn (in vergangenen Runden): Kennzahlen, Bild,
/// Hindernisse.
class HoleDialog extends StatelessWidget {
  HoleDialog(this.loc, this.holeId);

  final Locality loc;
  final int holeId;

  final GlobalKey _globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final shareText = l.share_text_hole1 +
        " " +
        holeId.toString() +
        " " +
        l.share_text_hole2 +
        " " +
        Data.getLocalityStringImm(App.of(context).getLocality()) +
        l.share_text2 +
        Data.getWebsiteStringImm(context, App.of(context).getLocality());

    return holeDialogFrame(context, [
      RepaintBoundary(
          key: _globalKey,
          child: Container(
              color: bgcolor,
              child: Column(children: [
                HoleDialogHeader(loc, holeId, _globalKey, shareText),
                Space(12),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(children: [
                      HoleDialogImage(loc, holeId),
                      Space(12),
                      HoleObstacles(loc, holeId),
                    ])),
              ]))),
    ]);
  }
}
