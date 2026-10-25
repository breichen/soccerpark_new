import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../pages/holedetailpage.dart' show HoleImagePage;
import '../utils/data.dart';
import '../utils/share.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/space.dart';

/// Kopf der Bahn-Dialoge: "Bahn X", Teilen und Schließen, darunter die
/// Chips für Par, Länge und maximale Schusszahl.
class HoleDialogHeader extends StatelessWidget {
  const HoleDialogHeader(this.loc, this.holeId, this.shareKey, this.shareText,
      {super.key});

  final Locality loc;
  final int holeId;
  final GlobalKey shareKey;
  final String shareText;

  @override
  Widget build(BuildContext context) {
    final par = Data.getParWithLoc(loc, holeId);
    return Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 4, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(
                    AppLocalizations.of(context)!.hole +
                        " " +
                        holeId.toString(),
                    style: GoogleFonts.lato(
                        color: maincolor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold))),
            IconButton(
                icon: Icon(Icons.share, color: maincolor),
                onPressed: () => share(shareKey, shareText)),
            IconButton(
                icon: Icon(Icons.close, color: Colors.grey[700]),
                onPressed: () => Navigator.of(context).pop()),
          ]),
          Wrap(spacing: 8, runSpacing: 8, children: [
            holeChip("Par " + par.toString()),
            holeChip(Data.getLengthWithLoc(loc, holeId).toString() + " m"),
            holeChip("Max. " + (2 * par).toString(), warning: true),
          ]),
        ]));
  }
}

/// Chip mit Kennzahl (grün) oder Warnung (orange).
Widget holeChip(String text, {bool warning = false}) {
  return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: warning ? Color(0xFFFFF4E5) : dropdownChipColor,
          borderRadius: BorderRadius.circular(16)),
      child: Text(text,
          style: GoogleFonts.lato(
              color: warning ? Color(0xFF8A4B00) : maincolor,
              fontSize: 14,
              fontWeight: FontWeight.bold)));
}

/// Bahnbild mit abgerundeten Ecken; Antippen öffnet es zum Zoomen.
class HoleDialogImage extends StatelessWidget {
  const HoleDialogImage(this.loc, this.holeId, {this.maxHeight, super.key});

  final Locality loc;
  final int holeId;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final asset = Data.getHolePicStrImm(loc, holeId);
    return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => HoleImagePage(asset))),
        child: Stack(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxHeight: maxHeight ?? double.infinity),
                  child: Image.asset(asset,
                      width: double.infinity, fit: BoxFit.contain))),
          Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.black45, shape: BoxShape.circle),
                  child: Icon(Icons.zoom_in, color: Colors.white, size: 20))),
        ]));
  }
}

/// Liste der Hindernisse einer Bahn (bisher nur für Salzburg vorhanden).
class HoleObstacles extends StatelessWidget {
  const HoleObstacles(this.loc, this.holeId, {super.key});

  final Locality loc;
  final int holeId;

  @override
  Widget build(BuildContext context) {
    final obstacles = <String>[];
    for (var i = 1; i <= 5; i++) {
      final text = Data.getHoleAdd(loc, context, holeId, i);
      if (text == "") break;
      obstacles.add(text);
    }
    if (obstacles.isEmpty) return SizedBox.shrink();

    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          for (var i = 0; i < obstacles.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: Colors.grey[200]),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("•  ",
                          style: GoogleFonts.lato(
                              color: maincolor, fontSize: 15)),
                      Expanded(
                          child: Text(obstacles[i],
                              style: GoogleFonts.lato(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.35))),
                    ])),
          ],
        ]));
  }
}

/// Gemeinsamer Rahmen der Bahn-Dialoge.
Widget holeDialogFrame(BuildContext context, List<Widget> children) {
  return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: bgcolor,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        ...children,
        Space(16),
      ])));
}
