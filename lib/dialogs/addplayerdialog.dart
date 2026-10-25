import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/appdialog.dart';

/// Neue Person anlegen. [func] liefert false, wenn der Name schon existiert.
class AddPlayerDialog extends StatelessWidget {
  const AddPlayerDialog(this.func, {super.key});

  final bool Function(String text) func;

  @override
  Widget build(BuildContext context) {
    return PlayerNameDialog(
        title: AppLocalizations.of(context)!.addPlayerTitle,
        initial: "",
        func: func);
  }
}

/// Gemeinsamer Dialog für Anlegen und Umbenennen.
class PlayerNameDialog extends StatefulWidget {
  const PlayerNameDialog(
      {required this.title,
      required this.initial,
      required this.func,
      super.key});

  final String title;
  final String initial;
  final bool Function(String text) func;

  @override
  State<PlayerNameDialog> createState() => _PlayerNameDialogState();
}

class _PlayerNameDialogState extends State<PlayerNameDialog> {
  late final TextEditingController controller =
      TextEditingController(text: widget.initial);
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    final l = AppLocalizations.of(context)!;
    final text = controller.text.trim();
    if (text.isEmpty) {
      setState(() => error = l.empty_name_error);
    } else if (widget.func(text)) {
      Navigator.of(context).pop();
    } else {
      setState(() => error = l.duplicate_name_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AppDialog(
        title: widget.title,
        child: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 1,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.lato(fontSize: 16),
            decoration: InputDecoration(
                labelText: 'Name',
                errorText: error,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
            onChanged: (_) {
              if (error != null) setState(() => error = null);
            },
            onSubmitted: (_) => submit()),
        actions: [
          dialogSecondaryButton(l.cancel, () => Navigator.of(context).pop()),
          dialogPrimaryButton(l.ok, submit),
        ]);
  }
}
