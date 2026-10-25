import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../utils/data.dart';
import './dropdown.dart' show dropdownChipColor;
import './space.dart';
import './toast.dart';

/// Kontaktdaten einer Anlage.
class VenueContact {
  VenueContact(this.name, this.address, this.phone, this.mail, this.web);

  final String name;
  final String address;
  final String phone;
  final String mail;
  final String web;

  static VenueContact of(BuildContext context, Locality loc) {
    final l = AppLocalizations.of(context)!;
    if (loc == Locality.SALZBURG) {
      return VenueContact(l.copyright, l.location, l.phone, l.mail, l.home);
    }
    if (loc == Locality.WAGRAIN) {
      return VenueContact(l.copyright_wagrain, l.location_wagrain,
          l.phone_wagrain, l.mail_wagrain, l.home_wagrain);
    }
    return VenueContact(l.copyright_goldberg, l.location_goldberg,
        l.phone_goldberg, l.mail_goldberg, l.home_goldberg);
  }
}

/// Kontaktkarte der gewählten Anlage mit Aktionen zum Anrufen, für die
/// Route, per E-Mail und zur Website. Steht am Ende des Hauptmenüs.
class ContactCard extends StatelessWidget {
  const ContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = VenueContact.of(context, App.of(context).getLocality());

    return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.name,
              style: GoogleFonts.lato(
                  color: maincolor, fontSize: 16, fontWeight: FontWeight.bold)),
          Space(2),
          Text(c.address,
              style: GoogleFonts.lato(color: Colors.grey[700], fontSize: 13)),
          Space(10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ContactChip(Icons.phone, loc.contact_call,
                () => open(context, 'tel:' + c.phone.replaceAll(RegExp(r'[^0-9+]'), '').replaceFirst('+430', '+43'))),
            ContactChip(Icons.directions, loc.contact_route,
                () => open(context, 'https://www.google.com/maps/search/?api=1&query=' + Uri.encodeComponent(c.address))),
            ContactChip(Icons.mail_outline, loc.contact_mail,
                () => open(context, 'mailto:' + c.mail)),
            ContactChip(Icons.public, loc.contact_web,
                () => open(context, 'https://' + c.web.replaceFirst(RegExp(r'^https?://'), ''))),
          ]),
        ]));
  }

  static Future<void> open(BuildContext context, String url) async {
    bool ok = false;
    try {
      ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      CustomToast.showToast(context, AppLocalizations.of(context)!.url_error);
    }
  }
}

/// Hellgrüner Aktions-Chip mit Icon.
class ContactChip extends StatelessWidget {
  const ContactChip(this.icon, this.label, this.onTap, {super.key});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: dropdownChipColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 18, color: maincolor),
                  SpaceH(6),
                  Text(label,
                      style: GoogleFonts.lato(
                          color: maincolor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ]))));
  }
}
