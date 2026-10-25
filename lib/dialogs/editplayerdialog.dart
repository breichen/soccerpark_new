import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import './addplayerdialog.dart';

/// Person umbenennen. [func] liefert false, wenn der Name schon existiert.
class EditPlayerDialog extends StatelessWidget {
  const EditPlayerDialog(this.name, this.func, {super.key});

  final String name;
  final bool Function(String text) func;

  @override
  Widget build(BuildContext context) {
    return PlayerNameDialog(
        title: AppLocalizations.of(context)!.edit, initial: name, func: func);
  }
}
