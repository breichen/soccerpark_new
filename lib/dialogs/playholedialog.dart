import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/space.dart';
import '../widgets/toast.dart';
import './holedialogparts.dart';

/// Bahn während einer laufenden Runde: Kennzahlen, Bild und die Schläge
/// aller Spieler. Mit "‹ Bahn 6" / "Bahn 8 ›" blättert man durch die
/// Runde, ohne den Dialog zu schließen.
///
/// [scores] ist die Schläge-Tabelle der Rundenansicht ([Spieler][Bahn-1]);
/// Änderungen gehen über [onChange] an die Rundenansicht, die speichert.
class PlayHoleDialog extends StatefulWidget {
  const PlayHoleDialog(
      this.loc, this.initialHole, this.names, this.scores, this.onChange,
      {super.key});

  final Locality loc;
  final int initialHole;
  final List<String> names;
  final List<List<int>> scores;

  /// (Spielerindex ab 0, Bahn 1-18, neue Schlagzahl)
  final void Function(int player, int hole, int score) onChange;

  @override
  State<PlayHoleDialog> createState() => _PlayHoleDialogState();
}

class _PlayHoleDialogState extends State<PlayHoleDialog> {
  final GlobalKey _globalKey = new GlobalKey();
  late int hole = widget.initialHole;

  void change(int player, int delta) {
    final par = Data.getParWithLoc(widget.loc, hole);
    // Höchstens 2 × Par, plus 1 Strafpunkt wenn der Ball nicht im Loch ist.
    final maxi = 2 * par + 1;
    final current = widget.scores[player][hole - 1];
    final next = current + delta;
    final l = AppLocalizations.of(context)!;
    if (next < 0) {
      CustomToast.showToast(context, l.negative_score_error);
      return;
    }
    if (next > maxi) {
      CustomToast.showToast(context, l.max_score_error);
      return;
    }
    widget.onChange(player, hole, next);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final int par = Data.getParWithLoc(widget.loc, hole);
    final shareText = l.share_text_playhole +
        " " +
        hole.toString() +
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
      rows.add(getRow(i, par));
    }

    return holeDialogFrame(context, [
      RepaintBoundary(
          key: _globalKey,
          child: Container(
              color: bgcolor,
              child: Column(children: [
                HoleDialogHeader(widget.loc, hole, _globalKey, shareText),
                Space(12),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(children: [
                      // Bild begrenzt, damit die Schläge sichtbar bleiben;
                      // Antippen zeigt es groß.
                      HoleDialogImage(widget.loc, hole, maxHeight: 220),
                      Space(12),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(children: rows)),
                    ])),
              ]))),
      Space(12),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            if (hole > 1) ...[
              Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: maincolor,
                          side: BorderSide(color: maincolor),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () => setState(() => hole -= 1),
                      icon: Icon(Icons.chevron_left),
                      label: Text(l.hole + " " + (hole - 1).toString(),
                          style: GoogleFonts.lato(
                              fontSize: 14, fontWeight: FontWeight.bold)))),
              SpaceH(8),
            ],
            Expanded(
                flex: 3,
                child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: maincolor,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (hole < 18) {
                        setState(() => hole += 1);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              hole < 18
                                  ? l.hole + " " + (hole + 1).toString()
                                  : l.hole_done,
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          if (hole < 18)
                            Icon(Icons.chevron_right, color: Colors.white),
                        ]))),
          ])),
    ]);
  }

  /// Spielername links, rechts Minus, Schläge (grün unter / rot über Par)
  /// und Plus.
  Widget getRow(int i, int par) {
    final score = widget.scores[i][hole - 1];
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
          stepButton(Icons.remove, () => change(i, -1)),
          SizedBox(
              width: 44,
              child: Text(score == 0 ? "–" : score.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold))),
          stepButton(Icons.add, () => change(i, 1)),
        ]));
  }

  /// Runder Knopf mit 44 px Trefferfläche.
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
