import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';
import '../widgets/appbar.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final double sep = 4;
  final double sepTitle = 10;
  final double sepLarge = 10;
  final double sepHuge = 20;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Locality loc = App.of(context).getLocality();

    return Scaffold(
        appBar: CustomAppBar(context, AppLocalizations.of(context)!.contact,
            MenuItemE.CONTACT, []),
        body: Stack(children: [
          ListView(children: <Widget>[
            Header(),
            Space(0),
            getBody(loc),
            Visibility(
                child: Footer(),
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true)
          ]),
          Column(children: [Spacer(), Footer()])
        ]));
  }

  Widget getBody(Locality loc) {
    if (loc == Locality.SALZBURG) return getBodySbg();
    if (loc == Locality.WAGRAIN) return getBodyWag();
    return getBodyGold();
  }

  Widget getBodySbg() {
    return Column(children: [
      TitleText(text: "Soccerpark Salzburg", indent: 16),
      Space(sepTitle),
      FloatText("Hans Klegraefe"),
      Space(sep),
      BoldFloatText("Soccerpark Salzburg"),
      Space(sep),
      FloatText(AppLocalizations.of(context)!.location1),
      Space(sep),
      FloatText(AppLocalizations.of(context)!.location2),
      Space(sepLarge),
      IconTextPair(Icons.phone, AppLocalizations.of(context)!.phone),
      Space(sep),
      IconTextPair(Icons.mail, AppLocalizations.of(context)!.mail),
      Space(sep),
      IconTextPair(Icons.home, AppLocalizations.of(context)!.home),
      Space(sepHuge),
      TitleText(text: "Social Media", indent: 16),
      Space(sepTitle),
      FaIconTextPair(FontAwesomeIcons.facebook, "Soccerpark.Salzburg"),
    ]);
  }

  Widget getBodyWag() {
    return Column(children: [
      TitleText(text: "Soccerpark Wagrain-Kleinarl", indent: 16),
      Space(sepTitle),
      FloatText("Hans Klegraefe"),
      Space(sep),
      BoldFloatText("Soccerpark Wagrain-Kleinarl"),
      Space(sep),
      FloatText(AppLocalizations.of(context)!.location1_wagrain),
      Space(sep),
      FloatText(AppLocalizations.of(context)!.location2_wagrain),
      Space(sepLarge),
      IconTextPair(Icons.phone, AppLocalizations.of(context)!.phone_wagrain),
      Space(sep),
      IconTextPair(Icons.mail, AppLocalizations.of(context)!.mail_wagrain),
      Space(sep),
      IconTextPair(Icons.home, AppLocalizations.of(context)!.home_wagrain),
      Space(sepHuge),
      TitleText(text: "Social Media", indent: 16),
      Space(sepTitle),
      FaIconTextPair(FontAwesomeIcons.facebook, "Soccerpark.Wagrain"),
    ]);
  }

  Widget getBodyGold() {
    return Column(children: [
      TitleText(text: "Soccerpark Goldberg", indent: 16),
      Space(sepTitle),
      BoldFloatText("Soccerpark Goldberg"),
      Space(sep),
      FloatText(AppLocalizations.of(context)!.location1_goldberg),
      Space(sep),
      FloatText(AppLocalizations.of(context)!.location2_goldberg),
      Space(sepLarge),
      IconTextPair(Icons.phone, AppLocalizations.of(context)!.phone_goldberg),
      Space(sep),
      IconTextPair(Icons.mail, AppLocalizations.of(context)!.mail_goldberg),
      Space(sep),
      IconTextPair(Icons.home, AppLocalizations.of(context)!.home_goldberg),
      Space(sepHuge),
      TitleText(text: "Social Media", indent: 16),
      Space(sepTitle),
      FaIconTextPair(FontAwesomeIcons.facebook, "Soccerpark.Goldberg"),
    ]);
  }
}

abstract class WidgetTextPair extends StatelessWidget {
  final String text;

  const WidgetTextPair(this.text, {super.key});

  /// Jede Subklasse liefert das Widget für das Icon
  Widget buildIcon(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SpaceH(16),
      buildIcon(context),
      SpaceH(8),
      Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 16,
          height: 1.3,
        ),
      ),
    ]);
  }
}

/// Subklasse für normales Flutter Icon
class IconTextPair extends WidgetTextPair {
  final IconData icon;

  IconTextPair(this.icon, String text, {super.key}) : super(text);

  @override
  Widget buildIcon(BuildContext context) {
    // Farblogik optional, z. B. Facebook als Beispiel
    final color = icon == Icons.facebook ? Colors.blue[800] : Colors.black;

    return Icon(
      icon,
      color: color,
      size: 16,
    );
  }
}

/// Subklasse für FontAwesome Icons
class FaIconTextPair extends WidgetTextPair {
  final FaIconData icon;

  FaIconTextPair(this.icon, String text, {super.key}) : super(text);

  @override
  Widget buildIcon(BuildContext context) {
    final color =
        icon == FontAwesomeIcons.facebook ? Colors.blue[800] : Colors.black;

    return FaIcon(
      icon,
      color: color,
      size: 16,
    );
  }
}
