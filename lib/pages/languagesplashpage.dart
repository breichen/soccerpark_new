import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import './localitysplashpage.dart';
import '../utils/data.dart';
import '../utils/flags.dart';
import '../widgets/space.dart';

class LanguageSplashPage extends StatelessWidget {
  const LanguageSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: ListView(children: [
          Space(128),
          Image.asset(Data.getSoccerPicString(App.of(context).getLocality())),
          Space(64),
          Row(children: [
            Spacer(),
            Text(
              "Bitte Sprache wählen!",
              style: GoogleFonts.lato(color: maincolor, fontSize: 18),
            ),
            Spacer(),
          ]),
          Space(4),
          Row(children: [
            Spacer(),
            Text("Please choose a language!",
                style: GoogleFonts.lato(color: maincolor, fontSize: 18)),
            Spacer(),
          ]),
          Space(64),
          Row(children: [
            Expanded(flex: 2, child: Container()),
            Expanded(
                flex: 3,
                child: GestureDetector(
                    child: flag_de(),
                    onTap: () {
                      App.of(context).setLocale(false);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LocalitySplashPage()),
                      );
                    })),
            Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 3,
                child: GestureDetector(
                    child: flag_uk(),
                    onTap: () {
                      App.of(context).setLocale(true);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LocalitySplashPage()),
                      );
                    })),
            Expanded(flex: 2, child: Container()),
          ]),
          Space(40)
        ]));
  }
}
