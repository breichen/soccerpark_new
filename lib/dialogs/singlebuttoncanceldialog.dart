import 'package:flutter/material.dart';
import 'package:soccerpark/dialogs/twobuttondialog.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';
import './twobuttondialog.dart';

class SingleButtonCancelDialog extends TwoButtonDialog {
  SingleButtonCancelDialog(BuildContext context, String title, String text,
      String buttonText, void Function() func)
      : super(title, text, AppLocalizations.of(context)!.cancel, buttonText,
            () {
          Navigator.of(context).pop();
        }, func) {}
}
