import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/about_texts.dart';
import '../widgets/appbar.dart';
import '../widgets/space.dart';

/// Datenschutzhinweise der App (Texte in utils/about_texts.dart).
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final sections = privacySections(lang);

    return Scaffold(
        appBar: CustomAppBar(context, l.privacy, MenuItemE.COUNT, []),
        body: ListView(padding: EdgeInsets.all(16), children: [
          for (final s in sections) ...[
            Text(s.title,
                style: GoogleFonts.lato(
                    color: maincolor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            Space(4),
            Text(s.body,
                style: GoogleFonts.lato(
                    color: Colors.grey[850], fontSize: 15, height: 1.45)),
            Space(18),
          ],
          Text((lang == 'de' ? 'Stand: ' : 'Last updated: ') + privacyDate,
              style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 12)),
          Space(16),
        ]));
  }
}
