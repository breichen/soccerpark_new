import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../widgets/appbar.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/footer.dart' show ContactCard, VenueContact;
import '../widgets/header.dart';
import '../widgets/space.dart';
import './holedetailpage.dart' show HoleImagePage;

/// Anfahrt: Route starten, Anfahrtsplan, Öffis und Wegbeschreibung.
class VenuePage extends StatefulWidget {
  const VenuePage({super.key});

  @override
  State<VenuePage> createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  final GlobalKey _globalKey = GlobalKey();

  String mapImage(Locality loc) {
    if (loc == Locality.SALZBURG) return "assets/pics/anfahrt.png";
    if (loc == Locality.WAGRAIN) return "assets/pics/anfahrt_wagrain.jpg";
    return "assets/pics/anfahrt_goldberg.png";
  }

  /// Wegbeschreibung auf der Website (für Goldberg noch keine).
  String? descriptionUrl(Locality loc) {
    if (loc == Locality.SALZBURG) return "https://www.soccerpark.at/anfahrt.html";
    if (loc == Locality.WAGRAIN) {
      return "https://www.soccerpark-wagrain.at/anfahrt.html";
    }
    return null;
  }

  /// Fahrplanauskunft des jeweiligen Verkehrsverbunds.
  String transitUrl(Locality loc) {
    if (loc == Locality.GOLDBERG) {
      return "https://www.ooevv.at/?seite=fahrplan-preisauskunft&sprache=DE";
    }
    return "https://fahrplan.salzburg-verkehr.at/";
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locality = App.of(context).getLocality();
    final c = VenueContact.of(context, locality);
    final description = descriptionUrl(locality);
    final image = mapImage(locality);

    return Scaffold(
        appBar: CustomAppBar(context, l.venue, MenuItemE.VENUE, [
          ShareButton(() {
            share(
                _globalKey,
                l.share_text_venue +
                    " " +
                    Data.getLocalityStringImm(locality) +
                    l.share_text2 +
                    Data.getWebsiteStringImm(context, locality));
          })
        ]),
        body: ListView(children: <Widget>[
          Header(),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style: GoogleFonts.lato(
                            color: maincolor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text(c.address,
                        style: GoogleFonts.lato(
                            color: Colors.grey[700], fontSize: 15)),
                    Space(14),
                    // Hauptaktion: Navigation starten
                    Material(
                        color: maincolor,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => ContactCard.open(
                                context,
                                'https://www.google.com/maps/dir/?api=1&destination=' +
                                    Uri.encodeComponent(c.address)),
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Row(children: [
                                  Icon(Icons.directions,
                                      color: Colors.white, size: 28),
                                  SpaceH(10),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(l.venue_route,
                                            style: GoogleFonts.lato(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold)),
                                        Text(l.venue_route_sub,
                                            style: GoogleFonts.lato(
                                                color: Color(0xFFCFE5CF),
                                                fontSize: 13)),
                                      ])),
                                  Icon(Icons.open_in_new,
                                      color: Colors.white, size: 20),
                                ])))),
                    Space(20),
                    Text(l.venue_map_title,
                        style: GoogleFonts.lato(
                            color: maincolor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    Space(8),
                    // Anfahrtsplan; Antippen öffnet ihn zum Zoomen.
                    GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HoleImagePage(image))),
                        child: Stack(children: [
                          RepaintBoundary(
                              key: _globalKey,
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(12)),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(image,
                                      width: double.infinity,
                                      fit: BoxFit.contain))),
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
                    Space(20),
                    card([
                      linkRow(Icons.directions_bus_outlined, l.venue_transit,
                          l.venue_transit_sub,
                          () => ContactCard.open(context, transitUrl(locality))),
                      if (description != null)
                        linkRow(Icons.article_outlined, l.venue_description,
                            l.venue_description_sub,
                            () => ContactCard.open(context, description)),
                    ]),
                  ])),
          Space(24),
        ]));
  }

  Widget card(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      children.add(rows[i]);
    }
    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: children));
  }

  Widget linkRow(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
        color: Colors.white,
        child: InkWell(
            onTap: onTap,
            child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 12, 10),
                child: Row(children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: dropdownChipColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, color: maincolor, size: 20)),
                  SpaceH(12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: GoogleFonts.lato(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Text(subtitle,
                            style: GoogleFonts.lato(
                                color: Colors.grey[600], fontSize: 12)),
                      ])),
                  Icon(Icons.open_in_new, color: maincolor, size: 20),
                ]))));
  }
}
