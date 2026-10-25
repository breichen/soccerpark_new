import 'package:flutter/material.dart';

import '../widgets/appdialog.dart';

/// Bestätigungsdialog mit zwei Knöpfen: [buttonText1] als Zweitknopf
/// (z. B. "Zurück"), [buttonText2] als Hauptknopf. [destructive] färbt
/// den Hauptknopf rot (Löschen, Abbrechen einer Runde …).
class TwoButtonDialog extends StatelessWidget {
  TwoButtonDialog(this.title, this.text, this.buttonText1, this.buttonText2,
      this.func1, this.func2,
      {this.destructive = false});

  final String title;
  final String text;
  final String buttonText1;
  final String buttonText2;
  final Function() func1;
  final Function() func2;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
        title: title,
        showClose: false,
        child: dialogText(text),
        actions: [
          dialogSecondaryButton(buttonText1, () => func1()),
          dialogPrimaryButton(buttonText2, () => func2(),
              destructive: destructive),
        ]);
  }
}
