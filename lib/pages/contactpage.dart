import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/appbar.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/footer.dart' show ContactCard, VenueContact;
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/toast.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  /// Ansprechpartner je Anlage (leer = keiner angegeben).
  String contactPerson(Locality loc) =>
      loc == Locality.GOLDBERG ? "" : "Hans Klegraefe";

  /// Facebook-Seite je Anlage.
  String facebookHandle(Locality loc) {
    if (loc == Locality.SALZBURG) return "Soccerpark.Salzburg";
    if (loc == Locality.WAGRAIN) return "Soccerpark.Wagrain";
    return "Soccerpark.Goldberg";
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locality = App.of(context).getLocality();
    final c = VenueContact.of(context, locality);
    final person = contactPerson(locality);
    final fb = facebookHandle(locality);

    return Scaffold(
        appBar: CustomAppBar(context, l.contact, MenuItemE.CONTACT, []),
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
                    if (person.isNotEmpty)
                      Text(person,
                          style: GoogleFonts.lato(
                              color: Colors.grey[700], fontSize: 15)),
                    Space(14),
                    card([
                      ContactRow(
                          icon: Icon(Icons.place_outlined,
                              color: maincolor, size: 20),
                          label: l.contact_address_label,
                          value: c.address,
                          action: Icons.directions,
                          onTap: () => ContactCard.open(
                              context,
                              'https://www.google.com/maps/search/?api=1&query=' +
                                  Uri.encodeComponent(c.address))),
                      ContactRow(
                          icon: Icon(Icons.phone_outlined,
                              color: maincolor, size: 20),
                          label: l.contact_phone_label,
                          value: c.phone,
                          action: Icons.call,
                          onTap: () => ContactCard.open(
                              context,
                              'tel:' +
                                  c.phone
                                      .replaceAll(RegExp(r'[^0-9+]'), '')
                                      .replaceFirst('+430', '+43'))),
                      ContactRow(
                          icon: Icon(Icons.mail_outline,
                              color: maincolor, size: 20),
                          label: l.contact_mail,
                          value: c.mail,
                          action: Icons.send_outlined,
                          onTap: () =>
                              ContactCard.open(context, 'mailto:' + c.mail)),
                      ContactRow(
                          icon: Icon(Icons.public, color: maincolor, size: 20),
                          label: l.contact_web,
                          value: c.web,
                          action: Icons.open_in_new,
                          onTap: () => ContactCard.open(
                              context,
                              'https://' +
                                  c.web.replaceFirst(RegExp(r'^https?://'), ''))),
                    ]),
                    Space(20),
                    Text("Social Media",
                        style: GoogleFonts.lato(
                            color: maincolor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    Space(8),
                    card([
                      ContactRow(
                          icon: FaIcon(FontAwesomeIcons.facebook,
                              color: Color(0xFF1877F2), size: 20),
                          iconBackground: Color(0xFFE7F0FD),
                          label: "Facebook",
                          value: fb,
                          action: Icons.open_in_new,
                          onTap: () => ContactCard.open(
                              context, 'https://www.facebook.com/' + fb)),
                    ]),
                    Space(10),
                    Text(l.contact_copy_hint,
                        style: GoogleFonts.lato(
                            color: Colors.grey[600], fontSize: 12)),
                  ])),
          Space(24),
        ]));
  }

  /// Weiße Karte mit Trennlinien zwischen den Zeilen.
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
}

/// Eine Kontaktzeile: Icon, Bezeichnung, Wert und Aktions-Symbol.
/// Antippen führt die Aktion aus, langes Drücken kopiert den Wert.
class ContactRow extends StatelessWidget {
  const ContactRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.action,
      required this.onTap,
      this.iconBackground,
      super.key});

  final Widget icon;
  final String label;
  final String value;
  final IconData action;
  final VoidCallback onTap;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: InkWell(
            onTap: onTap,
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: value));
              CustomToast.showToastIcon(context,
                  AppLocalizations.of(context)!.copied, Icons.copy);
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 12, 10),
                child: Row(children: [
                  Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: iconBackground ?? dropdownChipColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: icon),
                  SpaceH(12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(label,
                            style: GoogleFonts.lato(
                                color: Colors.grey[600], fontSize: 12)),
                        Text(value,
                            style: GoogleFonts.lato(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ])),
                  SpaceH(8),
                  Icon(action, color: maincolor, size: 20),
                ]))));
  }
}
