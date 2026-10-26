import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart' show VenueContact;
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../utils/data.dart';
import '../utils/flags.dart';
import '../utils/webpush_stub.dart'
    if (dart.library.js_interop) '../utils/webpush_web.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/toast.dart';

/// Einstellungen: Anlage, Sprache und (im Web) Mitteilungen.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Web-Mitteilungen (Android/iOS fragen beim Start, siehe main.dart).
  bool pushSupported = false;
  String pushPermission = 'unsupported';
  bool pushBusy = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      webPushSupported().then((ok) {
        if (!mounted) return;
        setState(() {
          pushSupported = ok;
          pushPermission = webPushPermission();
        });
      });
    }
  }

  Future<void> enablePush() async {
    setState(() => pushBusy = true);
    final token = await enableWebPush();
    if (!mounted) return;
    setState(() {
      pushBusy = false;
      pushPermission = webPushPermission();
    });
    if (token.isEmpty && pushPermission == 'granted') {
      CustomToast.showToast(
          context, AppLocalizations.of(context)!.notif_failed);
    }
  }

  /// Zum Testen: Token kopieren (für "Testnachricht senden" in Firebase).
  Future<void> copyPushToken() async {
    final token = await storedWebPushToken();
    if (token.isEmpty || !mounted) return;
    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;
    CustomToast.showToastIcon(
        context, AppLocalizations.of(context)!.copied, Icons.copy);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final app = App.of(context);
    final current = App.localityOf(context);
    final english = app.isEnglish();

    return Scaffold(
        appBar: CustomAppBar(context, l.settings, MenuItemE.SETTINGS, []),
        body: ListView(children: <Widget>[
          Header(),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle(l.settings_venue),
                    Space(8),
                    card([
                      for (final loc in Locality.values)
                        OptionRow(
                          leading: SizedBox(
                              width: 56,
                              height: 36,
                              child: Image.asset(
                                  Data.getLocalityImageString(loc),
                                  fit: BoxFit.contain)),
                          title: Data.getLocalityStringImm(loc),
                          subtitle: VenueContact.of(context, loc).address,
                          selected: loc == current,
                          onTap: () {
                            if (loc != current) app.setLocality(loc);
                          },
                        ),
                    ]),
                    Space(20),
                    sectionTitle(l.language),
                    Space(8),
                    card([
                      OptionRow(
                        leading: flagBox(flag_de_sized(22)),
                        title: "Deutsch",
                        selected: !english,
                        onTap: () {
                          if (english) app.setLocale(false);
                          setState(() {});
                        },
                      ),
                      OptionRow(
                        leading: flagBox(flag_uk_sized(22)),
                        title: "English",
                        selected: english,
                        onTap: () {
                          if (!english) app.setLocale(true);
                          setState(() {});
                        },
                      ),
                    ]),
                    if (kIsWeb) ...[
                      Space(20),
                      sectionTitle(l.settings_notifications),
                      Space(8),
                      card([getPushRow(l)]),
                    ],
                  ])),
          Space(24),
        ]));
  }

  /// Mitteilungen im Web: Status und ggf. "Aktivieren".
  Widget getPushRow(AppLocalizations l) {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    final String subtitle;
    Widget? trailing;
    IconData icon = Icons.notifications_outlined;

    if (!pushSupported) {
      icon = Icons.notifications_off_outlined;
      subtitle = ios ? l.notif_ios_hint : l.notif_unsupported;
    } else if (pushPermission == 'granted') {
      icon = Icons.notifications_active_outlined;
      subtitle = l.notif_info;
      trailing = Icon(Icons.check_circle, color: maincolor, size: 24);
    } else if (pushPermission == 'denied') {
      icon = Icons.notifications_off_outlined;
      subtitle = l.notif_denied;
    } else {
      subtitle = l.notif_info;
      trailing = pushBusy
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2))
          : FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: maincolor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: enablePush,
              child: Text(l.notif_enable,
                  style: GoogleFonts.lato(
                      color: Colors.white, fontWeight: FontWeight.bold)));
    }

    return Material(
        color: Colors.white,
        child: InkWell(
            // Versteckt zum Testen: langes Drücken kopiert den Token.
            onLongPress: pushPermission == 'granted' ? copyPushToken : null,
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
                        Text(
                            pushPermission == 'granted' && pushSupported
                                ? l.notif_on
                                : l.settings_notifications,
                            style: GoogleFonts.lato(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(subtitle,
                            style: GoogleFonts.lato(
                                color: Colors.grey[600], fontSize: 12)),
                      ])),
                  if (trailing != null) ...[SpaceH(8), trailing],
                ]))));
  }

  Widget flagBox(Widget flag) => SizedBox(
      width: 56,
      height: 36,
      child: Center(
          child: ClipRRect(borderRadius: BorderRadius.circular(3), child: flag)));

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
}

/// Auswahlzeile: Bild, Titel (optional Untertitel) und ein Häkchen-Kreis.
/// Die gewählte Zeile ist hellgrün hinterlegt.
class OptionRow extends StatelessWidget {
  const OptionRow(
      {required this.leading,
      required this.title,
      required this.selected,
      required this.onTap,
      this.subtitle,
      super.key});

  final Widget leading;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: selected ? Color(0xFFF1F7F1) : Colors.white,
        child: InkWell(
            onTap: onTap,
            child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 12, 10),
                child: Row(children: [
                  leading,
                  SpaceH(12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: GoogleFonts.lato(
                                color: selected ? maincolor : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        if (subtitle != null)
                          Text(subtitle!,
                              style: GoogleFonts.lato(
                                  color: Colors.grey[600], fontSize: 12)),
                      ])),
                  SpaceH(8),
                  Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: selected ? maincolor : Colors.grey[400],
                      size: 24),
                ]))));
  }
}
