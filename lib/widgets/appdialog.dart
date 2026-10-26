import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

/// Gemeinsamer Rahmen aller Dialoge: abgerundet, Titel in Grün,
/// Schließen-Kreuz, Inhalt und Knöpfe unten rechts.
class AppDialog extends StatelessWidget {
  const AppDialog(
      {required this.title,
      required this.child,
      this.actions = const [],
      this.showClose = true,
      super.key});

  final String title;
  final Widget child;
  final List<Widget> actions;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        clipBehavior: Clip.antiAlias,
        backgroundColor: bgcolor,
        insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 8, 16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(title,
                                style: GoogleFonts.lato(
                                    color: maincolor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)))),
                    if (showClose)
                      IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[700]),
                          onPressed: () => Navigator.of(context).pop()),
                  ]),
                  SizedBox(height: 8),
                  Padding(padding: EdgeInsets.only(right: 12), child: child),
                  if (actions.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 8,
                            children: actions)),
                  ],
                ])));
  }
}

/// Hauptknopf eines Dialogs (grün, bei [destructive] rot).
Widget dialogPrimaryButton(String text, VoidCallback onPressed,
    {bool destructive = false, IconData? icon}) {
  final style = FilledButton.styleFrom(
      backgroundColor: destructive ? mainred : maincolor,
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
  final label = Text(text,
      style: GoogleFonts.lato(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold));
  return icon == null
      ? FilledButton(style: style, onPressed: onPressed, child: label)
      : FilledButton.icon(
          style: style,
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 20),
          label: label);
}

/// Zweitknopf eines Dialogs (Text, z. B. "Abbrechen").
Widget dialogSecondaryButton(String text, VoidCallback onPressed,
    {IconData? icon}) {
  final style = TextButton.styleFrom(
      foregroundColor: Colors.grey[800],
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12));
  final label = Text(text,
      style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold));
  return icon == null
      ? TextButton(style: style, onPressed: onPressed, child: label)
      : TextButton.icon(
          style: style,
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: label);
}

/// Fließtext in Dialogen.
Widget dialogText(String text) => Text(text,
    style: GoogleFonts.lato(color: Colors.grey[850], fontSize: 16, height: 1.4));
