import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/space.dart';
import '../widgets/toast.dart';
import './holedialogparts.dart';

/// Bahn während einer laufenden Runde: Kennzahlen, Bild und die Schläge
/// aller Spieler zum Eintragen.
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
  final GlobalKey _globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final int par = Data.getParWithLoc(widget.loc, widget.holeId);
    // Höchstens 2 × Par, plus 1 Strafpunkt wenn der Ball nicht im Loch ist.
    final int maxi = 2 * par + 1;
    final shareText = l.share_text_playhole +
        " " +
        widget.holeId.toString() +
        " " +
        l.share_text_hole2 +
        " " +
        Data.getLocalityStringImm(App.of(context).getLocality()) +
        l.share_text2 +
        Data.getWebsiteStringImm(context, App.of(context).getLocality());

    final rows = <Widget>[];
    for (var i = 0; i < widget.names.length; i++) {
      if (i > 0) {
        rows.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      rows.add(getRow(i, par, maxi));
    }

    return holeDialogFrame(context, [
      RepaintBoundary(
          key: _globalKey,
          child: Container(
              color: bgcolor,
              child: Column(children: [
                HoleDialogHeader(widget.loc, widget.holeId, _globalKey,
                    shareText),
                Space(12),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(children: [
                      // Bild etwas begrenzt, damit die Schläge sichtbar
                      // bleiben; Antippen zeigt es groß.
                      HoleDialogImage(widget.loc, widget.holeId,
                          maxHeight: 260),
                      Space(12),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(children: rows)),
                    ])),
              ]))),
    ]);
  }

  /// Spielername links, rechts Minus, Schläge (grün unter / rot über Par)
  /// und Plus.
  Widget getRow(int i, int par, int maxi) {
    final score = widget.scores[i];
    final color = score == 0
        ? Colors.grey[500]!
        : (score < par ? maincolor : (score > par ? mainred : Colors.black87));

    return Padding(
        padding: EdgeInsets.fromLTRB(12, 6, 6, 6),
        child: Row(children: [
          Expanded(
              child: Text(widget.names[i],
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))),
          stepButton(Icons.remove, () {
            if (widget.scores[i] > 0) {
              setState(() {
                widget.scores[i] -= 1;
                widget.funcMin(i + 1);
              });
            } else {
              CustomToast.showToast(context,
                  AppLocalizations.of(context)!.negative_score_error);
            }
          }),
          SizedBox(
              width: 44,
              child: Text(score == 0 ? "–" : score.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold))),
          stepButton(Icons.add, () {
            if (widget.scores[i] < maxi) {
              setState(() {
                widget.scores[i] += 1;
                widget.funcPlus(i + 1);
              });
            } else {
              CustomToast.showToast(
                  context, AppLocalizations.of(context)!.max_score_error);
            }
          }),
        ]));
  }

  /// Runder Knopf mit 44 px Trefferfläche (gut auch mit Handschuhen).
  Widget stepButton(IconData icon, VoidCallback onTap) {
    return Material(
        color: Color(0xFFE3EFE3),
        shape: CircleBorder(),
        child: InkWell(
            customBorder: CircleBorder(),
            onTap: onTap,
            child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, color: maincolor, size: 22))));
  }
}
