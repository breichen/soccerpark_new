import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../widgets/appbar.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/space.dart';

/// Detailansicht der Bahnen: wischen von Bahn zu Bahn.
class HoleDetailPage extends StatefulWidget {
  const HoleDetailPage({required this.initialHole, super.key});

  final int initialHole;

  @override
  State<HoleDetailPage> createState() => _HoleDetailPageState();
}

class _HoleDetailPageState extends State<HoleDetailPage> {
  late final PageController _controller =
      PageController(initialPage: widget.initialHole - 1);
  late int hole = widget.initialHole;
  final List<GlobalKey> _keys = List.generate(18, (_) => GlobalKey());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void goTo(int h) {
    if (h < 1 || h > 18) return;
    _controller.animateToPage(h - 1,
        duration: Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locality = App.of(context).getLocality();

    return Scaffold(
        appBar: CustomAppBar(context, loc.holes, MenuItemE.COUNT, [
          ShareButton(() {
            share(
                _keys[hole - 1],
                loc.share_text_hole1 +
                    " " +
                    hole.toString() +
                    " " +
                    loc.share_text_hole2 +
                    " " +
                    Data.getLocalityStringImm(locality) +
                    loc.share_text2 +
                    Data.getWebsiteStringImm(context, locality));
          })
        ]),
        body: Column(children: [
          // Kopf: Pfeile und Bahnnummer
          Padding(
              padding: EdgeInsets.fromLTRB(4, 6, 4, 0),
              child: Row(children: [
                IconButton(
                    onPressed: hole > 1 ? () => goTo(hole - 1) : null,
                    icon: Icon(Icons.chevron_left),
                    color: maincolor,
                    disabledColor: Colors.grey[300]),
                Expanded(
                    child: Text(loc.hole + " " + hole.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            color: maincolor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold))),
                IconButton(
                    onPressed: hole < 18 ? () => goTo(hole + 1) : null,
                    icon: Icon(Icons.chevron_right),
                    color: maincolor,
                    disabledColor: Colors.grey[300]),
              ])),
          Expanded(
              child: PageView.builder(
                  controller: _controller,
                  itemCount: 18,
                  onPageChanged: (i) => setState(() => hole = i + 1),
                  itemBuilder: (context, i) =>
                      HoleDetail(locality, i + 1, _keys[i]))),
          getDots(),
          Space(12),
        ]));
  }

  /// Fortschrittspunkte; die aktuelle Bahn als längerer grüner Strich.
  Widget getDots() {
    return Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        children: List.generate(18, (i) {
          final active = i == hole - 1;
          return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: active ? 14 : 6,
              height: 6,
              decoration: BoxDecoration(
                  color: active ? maincolor : Colors.grey[350],
                  borderRadius: BorderRadius.circular(3)));
        }));
  }
}

/// Inhalt einer Bahn: Kennzahlen, Bild, Hindernisse.
class HoleDetail extends StatelessWidget {
  const HoleDetail(this.locality, this.hole, this.shareKey, {super.key});

  final Locality locality;
  final int hole;
  final GlobalKey shareKey;

  @override
  Widget build(BuildContext context) {
    final par = Data.getParWithLoc(locality, hole);
    final length = Data.getLengthWithLoc(locality, hole);
    final obstacles = <String>[];
    for (var i = 1; i <= 5; i++) {
      final text = Data.getHoleAdd(locality, context, hole, i);
      if (text == "") break;
      obstacles.add(text);
    }

    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: RepaintBoundary(
            key: shareKey,
            child: Container(
                color: bgcolor,
                child: Column(children: [
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    chip("Par " + par.toString()),
                    chip(length.toString() + " m"),
                    chip("Max. " + (2 * par).toString(), warning: true),
                  ]),
                  Space(12),
                  // Antippen öffnet das Bild zum Zoomen (im Wischbereich
                  // würde Zoomen mit dem Blättern kollidieren).
                  GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HoleImagePage(
                                  Data.getHolePicStrImm(locality, hole)))),
                      child: Stack(children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                                Data.getHolePicStrImm(locality, hole),
                                width: double.infinity,
                                fit: BoxFit.contain)),
                        Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle),
                                child: Icon(Icons.zoom_in,
                                    color: Colors.white, size: 20))),
                      ])),
                  if (obstacles.isNotEmpty) ...[
                    Space(12),
                    Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(children: [
                          for (var i = 0; i < obstacles.length; i++) ...[
                            if (i > 0)
                              Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey[200]),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 9),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                        ])),
                  ],
                ]))));
  }

  Widget chip(String text, {bool warning = false}) {
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
}

/// Bahnbild bildschirmfüllend zum Zoomen und Verschieben.
class HoleImagePage extends StatelessWidget {
  const HoleImagePage(this.asset, {super.key});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(child: Image.asset(asset, fit: BoxFit.contain))));
  }
}
