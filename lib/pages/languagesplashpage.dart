import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import './localitysplashpage.dart';
import '../utils/flags.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';

/// Erster Start, Schritt 1: Sprache wählen (zweisprachig beschriftet).
class LanguageSplashPage extends StatelessWidget {
  const LanguageSplashPage({super.key});

  void choose(BuildContext context, bool english) {
    App.of(context).setLocale(english);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LocalitySplashPage()));
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.lato(
        color: maincolor, fontSize: 24, fontWeight: FontWeight.bold);
    final subStyle = GoogleFonts.lato(color: Colors.grey[700], fontSize: 16);

    return Scaffold(
        backgroundColor: bgcolor,
        body: SafeArea(
            top: false,
            child: ListView(children: [
              Header(),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(children: [
                    Text("Willkommen!", style: titleStyle),
                    Text("Welcome!", style: titleStyle),
                    Space(8),
                    Text("Bitte Sprache wählen",
                        textAlign: TextAlign.center, style: subStyle),
                    Text("Please choose a language",
                        textAlign: TextAlign.center, style: subStyle),
                    Space(24),
                    SplashChoice(
                        leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: flag_de_sized(32)),
                        title: "Deutsch",
                        onTap: () => choose(context, false)),
                    Space(10),
                    SplashChoice(
                        leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: flag_uk_sized(32)),
                        title: "English",
                        onTap: () => choose(context, true)),
                    Space(24),
                  ])),
            ])));
  }
}

/// Große, gut antippbare Auswahlkarte für die Startseiten.
class SplashChoice extends StatelessWidget {
  const SplashChoice(
      {required this.leading,
      required this.title,
      required this.onTap,
      this.subtitle,
      super.key});

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey[300]!)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onTap,
            child: Padding(
                padding: EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Row(children: [
                  SizedBox(
                      width: 72, height: 44, child: Center(child: leading)),
                  SpaceH(14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: GoogleFonts.lato(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        if (subtitle != null)
                          Text(subtitle!,
                              style: GoogleFonts.lato(
                                  color: Colors.grey[600], fontSize: 13)),
                      ])),
                  Icon(Icons.chevron_right, color: maincolor, size: 28),
                ]))));
  }
}
