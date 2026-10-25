import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import './languagesplashpage.dart' show SplashChoice;
import './mainpage.dart';
import '../utils/data.dart';
import '../widgets/footer.dart' show VenueContact;
import '../widgets/header.dart';
import '../widgets/space.dart';

/// Erster Start, Schritt 2: Anlage wählen. Danach geht es ins Hauptmenü.
class LocalitySplashPage extends StatelessWidget {
  const LocalitySplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
        backgroundColor: bgcolor,
        body: SafeArea(
            top: false,
            child: ListView(children: [
              Header(),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(children: [
                    Text(l.choose_park,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            color: maincolor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Space(6),
                    Text(l.choose_park_hint,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            color: Colors.grey[700], fontSize: 15)),
                    Space(20),
                    for (final loc in Locality.values) ...[
                      SplashChoice(
                          leading: Image.asset(Data.getLocalityImageString(loc),
                              fit: BoxFit.contain),
                          title: Data.getLocalityStringImm(loc),
                          subtitle: VenueContact.of(context, loc).address,
                          onTap: () {
                            App.of(context).setLocality(loc);
                            Data.setInitChosen();
                            goToMainPage(context);
                          }),
                      Space(10),
                    ],
                    Space(14),
                  ])),
            ])));
  }
}
