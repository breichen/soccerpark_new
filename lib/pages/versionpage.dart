import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/about_texts.dart';
import '../utils/data.dart';
import '../widgets/appbar.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/footer.dart' show ContactCard;
import '../widgets/space.dart';
import './privacypage.dart';

/// Adresse für Fehlermeldungen und Feedback zur App.
const String feedbackMail = 'soccerpark.salzburg@gmail.com';

/// Eintrag im Google Play Store.
const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.soccerpark.austria';

/// "Über die App": Version, Neuerungen, Feedback, Datenschutz, Lizenzen.
class VersionPage extends StatefulWidget {
  const VersionPage({super.key});

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  String version = '';
  String build = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() {
          version = info.version;
          build = info.buildNumber;
        });
      }
    });
  }

  String get versionText =>
      build.isEmpty ? version : version + " (" + build + ")";

  String get platformName {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      default:
        return defaultTargetPlatform.name;
    }
  }

  /// "App bewerten" nur in der Android-App (nicht in der PWA).
  bool get showRating => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void reportProblem() {
    final locality =
        Data.getLocalityStringImm(App.of(context).getLocality());
    final subject = 'Soccerpark App ' + versionText;
    final body = '\n\n---\nVersion: ' +
        versionText +
        '\nPlattform: ' +
        platformName +
        '\nAnlage: ' +
        locality;
    ContactCard.open(
        context,
        'mailto:' +
            feedbackMail +
            '?subject=' +
            Uri.encodeComponent(subject) +
            '&body=' +
            Uri.encodeComponent(body));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
        appBar: CustomAppBar(context, l.about, MenuItemE.VERSION, []),
        body: ListView(padding: EdgeInsets.all(16), children: [
          // App-Name und Version
          Row(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/pics/ball.jpg',
                    width: 56, height: 56, fit: BoxFit.cover)),
            SpaceH(14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Soccerpark',
                      style: GoogleFonts.lato(
                          color: maincolor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text(
                      l.currversion +
                          ": " +
                          (versionText.isEmpty ? "…" : versionText),
                      style: GoogleFonts.lato(
                          color: Colors.grey[700], fontSize: 14)),
                ])),
          ]),
          Space(20),
          sectionTitle(l.whats_new),
          Space(8),
          card([
            Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(children: [
                  for (final item in whatsNew(lang))
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.check_circle,
                                      color: maincolor, size: 16)),
                              SpaceH(8),
                              Expanded(
                                  child: Text(item,
                                      style: GoogleFonts.lato(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          height: 1.35))),
                            ])),
                ])),
          ]),
          Space(20),
          sectionTitle(l.feedback_title),
          Space(8),
          card([
            if (showRating)
              linkRow(Icons.star_outline, l.rate_app,
                  () => ContactCard.open(context, playStoreUrl)),
            linkRow(Icons.bug_report_outlined, l.report_bug, reportProblem),
          ]),
          Space(20),
          sectionTitle(l.legal_title),
          Space(8),
          card([
            linkRow(Icons.privacy_tip_outlined, l.privacy, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PrivacyPage()));
            }, external: false),
            linkRow(Icons.description_outlined, l.licenses, () {
              showLicensePage(
                  context: context,
                  applicationName: 'Soccerpark',
                  applicationVersion: versionText,
                  applicationIcon: Padding(
                      padding: EdgeInsets.all(8),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset('assets/pics/ball.jpg',
                              width: 48, height: 48, fit: BoxFit.cover))));
            }, external: false),
          ]),
          Space(24),
        ]));
  }

  Widget sectionTitle(String text) => Text(text,
      style: GoogleFonts.lato(
          color: maincolor, fontSize: 17, fontWeight: FontWeight.bold));

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

  Widget linkRow(IconData icon, String title, VoidCallback onTap,
      {bool external = true}) {
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
                      child: Text(title,
                          style: GoogleFonts.lato(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.bold))),
                  Icon(external ? Icons.open_in_new : Icons.chevron_right,
                      color: maincolor, size: 20),
                ]))));
  }
}
