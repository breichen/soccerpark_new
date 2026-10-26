import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/webpush_stub.dart'
    if (dart.library.js_interop) '../utils/webpush_web.dart';
import './dropdown.dart' show dropdownChipColor;
import './space.dart';
import './toast.dart';

/// Einmalige Frage nach Mitteilungen in der Web-Version (Finish-Seite).
///
/// Erscheint nur im Web, nur solange noch nicht geantwortet wurde und nur,
/// wenn der Browser noch nicht gefragt hat. Auf dem iPhone ohne
/// installierte App erklärt die Karte stattdessen, wie man installiert.
/// Android/iOS-Apps fragen beim Start selbst (siehe main.dart).
class PushPromptCard extends StatefulWidget {
  const PushPromptCard({super.key});

  @override
  State<PushPromptCard> createState() => _PushPromptCardState();
}

class _PushPromptCardState extends State<PushPromptCard> {
  static const _doneKey = 'webPushPromptDone';

  bool visible = false;
  bool iosInstallHint = false;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) check();
  }

  Future<void> check() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_doneKey) ?? false) return;
    final supported = await webPushSupported();
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    if (!mounted) return;
    if (supported && webPushPermission() == 'default') {
      setState(() => visible = true);
    } else if (!supported && ios) {
      setState(() {
        visible = true;
        iosInstallHint = true;
      });
    }
  }

  Future<void> done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doneKey, true);
    if (mounted) setState(() => visible = false);
  }

  Future<void> enable() async {
    setState(() => busy = true);
    final token = await enableWebPush();
    await done();
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    if (token.isNotEmpty) {
      CustomToast.showToastIcon(context, l.notif_on, Icons.notifications_active);
    } else if (webPushPermission() == 'granted') {
      CustomToast.showToast(context, l.notif_failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return SizedBox.shrink();
    final l = AppLocalizations.of(context)!;

    return Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: EdgeInsets.fromLTRB(14, 12, 10, 8),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: dropdownChipColor,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.notifications_outlined,
                    color: maincolor, size: 20)),
            SpaceH(12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(l.notif_prompt_title,
                      style: GoogleFonts.lato(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Space(2),
                  Text(
                      iosInstallHint
                          ? l.notif_prompt_ios
                          : l.notif_prompt_text,
                      style: GoogleFonts.lato(
                          color: Colors.grey[700], fontSize: 14, height: 1.35)),
                ])),
          ]),
          Space(6),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (iosInstallHint)
              TextButton(
                  style: TextButton.styleFrom(foregroundColor: maincolor),
                  onPressed: done,
                  child: Text(l.ok,
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold)))
            else ...[
              TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[800]),
                  onPressed: busy ? null : done,
                  child: Text(l.notif_prompt_no,
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold))),
              SpaceH(4),
              busy
                  ? Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)))
                  : FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: maincolor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: enable,
                      child: Text(l.notif_enable,
                          style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
            ],
          ]),
        ]));
  }
}
