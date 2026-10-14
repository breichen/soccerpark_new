import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import './space.dart';
import '../utils/data.dart';

class Footer extends StatelessWidget {
  final double sep = 4;
  final double vsep = 2;

  Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xFF005005),
        width: double.infinity,
        child: getFooter(context));
  }

  Widget getFooter(BuildContext context) {
    Locality loc = App.of(context).getLocality();
    if (loc == Locality.SALZBURG) return getFooterSbg(context);
    if (loc == Locality.WAGRAIN) return getFooterWag(context);
    return getFooterGold(context);
  }

  Widget getFooterSbg(BuildContext context) {
    return Column(children: <Widget>[
      Space(8),
      Container(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(children: [
            Icon(Icons.location_on, color: Colors.white, size: 20),
            SpaceH(sep),
            FooterText(AppLocalizations.of(context)!.location),
          ]),
        ),
      ),
      Space(vsep),
      Row(
        children: <Widget>[
          Expanded(
            flex: 5, // 20%
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(children: [
                Icon(Icons.phone, color: Colors.white, size: 20),
                SpaceH(sep),
                FooterText(AppLocalizations.of(context)!.phone),
              ]),
            ),
          ),
          Expanded(
            flex: 5, // 20%
            child: Row(children: [
              Icon(Icons.mail, color: Colors.white, size: 20),
              SpaceH(sep),
              FooterText(AppLocalizations.of(context)!.mail),
            ]),
          )
        ],
      ),
      Space(vsep),
      Row(
        children: <Widget>[
          Expanded(
            flex: 5, // 20%
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(children: [
                Icon(Icons.home, color: Colors.white, size: 20),
                SpaceH(sep),
                FooterText(AppLocalizations.of(context)!.home),
              ]),
            ),
          ),
          Expanded(
            flex: 5, // 20%
            child: Row(children: [
              Icon(Icons.copyright, color: Colors.white, size: 20),
              SpaceH(sep),
              FooterText(AppLocalizations.of(context)!.copyright),
            ]),
          )
        ],
      ),
      Space(4),
    ]);
  }

  Widget getFooterWag(BuildContext context) {
    return Column(children: <Widget>[
      Space(8),
      Container(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(children: [
            Icon(Icons.location_on, color: Colors.white, size: 20),
            SpaceH(sep),
            FooterText(AppLocalizations.of(context)!.location_wagrain),
          ]),
        ),
      ),
      Space(vsep),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: [
          Icon(Icons.phone, color: Colors.white, size: 20),
          SpaceH(sep),
          FooterText(AppLocalizations.of(context)!.phone_wagrain),
        ]),
      ),
      Space(vsep),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: [
          Icon(Icons.home, color: Colors.white, size: 20),
          SpaceH(sep),
          FooterText(AppLocalizations.of(context)!.home_wagrain),
        ]),
      ),
      Space(4),
    ]);
  }

  Widget getFooterGold(BuildContext context) {
    return Column(children: <Widget>[
      Space(8),
      Container(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(children: [
            Icon(Icons.location_on, color: Colors.white, size: 20),
            SpaceH(sep),
            FooterText(AppLocalizations.of(context)!.location_goldberg),
          ]),
        ),
      ),
      Space(vsep),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: [
          Icon(Icons.phone, color: Colors.white, size: 20),
          SpaceH(sep),
          FooterText(AppLocalizations.of(context)!.phone_goldberg),
        ]),
      ),
      Space(vsep),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: [
          Icon(Icons.home, color: Colors.white, size: 20),
          SpaceH(sep),
          FooterText(AppLocalizations.of(context)!.home_goldberg),
        ]),
      ),
      Space(4),
    ]);
  }
}

class FooterText extends StatelessWidget {
  final String text;

  FooterText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lato(color: Colors.white, fontSize: 12),
    );
  }
}
