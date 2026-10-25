import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/space.dart';
import './holedialogparts.dart' show holeChip;

/// Schlagzahl eines Spielers auf einer Bahn direkt wählen
/// (Antippen einer Zelle in der Rundenansicht).
class ScoreDialog extends StatelessWidget {
  const ScoreDialog(this.loc, this.holeId, this.name, this.func,
      {this.current = 0, super.key});

  final Locality loc;
  final int holeId;
  final String name;
  final void Function(int score) func;

  /// Bisher eingetragene Schläge (0 = noch nichts).
  final int current;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final int par = Data.getParWithLoc(loc, holeId);
    // Höchstens 2 × Par, plus 1 Strafpunkt wenn der Ball nicht im Loch ist.
    final int maxi = 2 * par + 1;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: bgcolor,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 8, 4, 12),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                                color: maincolor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text(l.hole + " " + holeId.toString(),
                            style: GoogleFonts.lato(
                                color: Colors.grey[700], fontSize: 14)),
                      ])),
                  IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[700]),
                      onPressed: () => Navigator.of(context).pop()),
                ]),
                Space(6),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  holeChip("Par " + par.toString()),
                  holeChip("Max. " + (2 * par).toString(), warning: true),
                ]),
                Space(16),
                Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (var i = 1; i <= maxi; i++)
                            scoreButton(context, i, par),
                        ])),
                Space(12),
                if (current > 0)
                  Center(
                      child: TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: mainred),
                          icon: Icon(Icons.backspace_outlined, size: 18),
                          label: Text(l.clear_hole_score,
                              style: GoogleFonts.lato(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            func(0);
                            Navigator.of(context).pop();
                          })),
              ])),
    );
  }

  /// Zahlenknopf: unter Par grün, Par neutral, über Par rot getönt;
  /// der aktuelle Wert ist voll eingefärbt.
  Widget scoreButton(BuildContext context, int value, int par) {
    final selected = value == current;
    final Color fg;
    final Color bg;
    if (value < par) {
      fg = maincolor;
      bg = Color(0xFFE3EFE3);
    } else if (value > par) {
      fg = mainred;
      bg = Color(0xFFFBE9E9);
    } else {
      fg = Colors.black87;
      bg = Colors.white;
    }
    return Material(
        color: selected ? fg : bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: selected ? fg : Colors.grey[300]!)),
        child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              func(value);
              Navigator.of(context).pop();
            },
            child: SizedBox(
                width: 56,
                height: 56,
                child: Center(
                    child: Text(value.toString(),
                        style: GoogleFonts.lato(
                            color: selected ? Colors.white : fg,
                            fontSize: 24,
                            fontWeight: FontWeight.bold))))));
  }
}
