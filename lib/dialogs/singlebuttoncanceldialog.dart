import 'package:flutter/material.dart';
import 'package:soccerpark/dialogs/twobuttondialog.dart';
import 'package:soccerpark/generated/app_localizations.dart';

class SingleButtonCancelDialog extends TwoButtonDialog {
  SingleButtonCancelDialog(BuildContext context, String title, String text,
      String buttonText, void Function() func)
      : super(title, text, AppLocalizations.of(context)!.cancel, buttonText,
            () {
          Navigator.of(context).pop();
        }, func) {}
}
