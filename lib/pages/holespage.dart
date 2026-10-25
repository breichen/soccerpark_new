import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../widgets/appbar.dart';
import '../widgets/space.dart';
import './holedetailpage.dart';

/// Bahnen: Umschalter zwischen Platzplan und Raster aller 18 Bahnen.
class HolesPage extends StatefulWidget {
  const HolesPage({super.key});

  @override
  State<HolesPage> createState() => _HolesPageState();
}

class _HolesPageState extends State<HolesPage> {
  final GlobalKey _globalKey = GlobalKey();

  bool showPlan = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: CustomAppBar(context, loc.holes, MenuItemE.COUNT, [
          ShareButton(() {
            share(
                _globalKey,
                loc.share_text_holes +
                    " " +
                    Data.getLocalityStringImm(App.of(context).getLocality()) +
                    loc.share_text2 +
                    Data.getWebsiteStringImm(
                        context, App.of(context).getLocality()));
          })
        ]),
        body: Column(children: [
          Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      foregroundColor: maincolor,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: maincolor,
                      side: BorderSide(color: maincolor),
                      textStyle: GoogleFonts.lato(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    segments: [
                      ButtonSegment(
                          value: true,
                          icon: Icon(Icons.map_outlined),
                          label: Text(loc.plan)),
                      ButtonSegment(
                          value: false,
                          icon: Icon(Icons.flag_outlined),
                          label: Text(loc.holes)),
                    ],
                    selected: {showPlan},
                    onSelectionChanged: (s) =>
                        setState(() => showPlan = s.first),
                  ))),
          Expanded(child: showPlan ? getPlan() : getGrid()),
        ]));
  }

  /// Platzplan, zoom- und verschiebbar.
  Widget getPlan() {
    final locality = App.of(context).getLocality();
    Widget image = Image.asset(Data.getHolesPicStrImm(locality));
    // Der Wagrainer Plan ist quer; hochkant passt er besser aufs Handy.
    if (locality == Locality.WAGRAIN) {
      image = RotatedBox(quarterTurns: 1, child: image);
    }
    // Plan in voller Breite; Verschieben ersetzt das Scrollen.
    return LayoutBuilder(
        builder: (context, constraints) => InteractiveViewer(
            constrained: false,
            minScale: 1,
            maxScale: 4,
            child: SizedBox(
                width: constraints.maxWidth,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 16),
                    child: RepaintBoundary(
                        key: _globalKey,
                        child: Container(color: bgcolor, child: image))))));
  }

  /// Alle 18 Bahnen als Kacheln mit Bild, Par und Länge.
  Widget getGrid() {
    final locality = App.of(context).getLocality();
    return LayoutBuilder(builder: (context, constraints) {
      final columns = (constraints.maxWidth / 140).floor().clamp(3, 6);
      return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                  color: bgcolor,
                  child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 18,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.62),
                      itemBuilder: (context, i) =>
                          HoleTile(locality, i + 1, () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HoleDetailPage(initialHole: i + 1)));
                          })))));
    });
  }
}

/// Kachel einer Bahn: Bild (Format der Bahntafeln, ca. 4:5), Name,
/// Par und Länge.
class HoleTile extends StatelessWidget {
  const HoleTile(this.locality, this.hole, this.onTap, {super.key});

  final Locality locality;
  final int hole;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey[300]!)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onTap,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Image.asset(Data.getHolePicStrImm(locality, hole),
                      fit: BoxFit.cover, width: double.infinity)),
              Padding(
                  padding: EdgeInsets.fromLTRB(7, 5, 6, 6),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.hole + " " + hole.toString(),
                            style: GoogleFonts.lato(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        Space(1),
                        Text(
                            "Par " +
                                Data.getParWithLoc(locality, hole).toString() +
                                " · " +
                                Data.getLengthWithLoc(locality, hole)
                                    .toString() +
                                " m",
                            style: GoogleFonts.lato(
                                color: Colors.grey[700], fontSize: 11)),
                      ])),
            ])));
  }
}
