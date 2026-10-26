import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/online_highscores.dart';
import '../widgets/appdialog.dart';

/// Fragt nach einer Runde in den Top 50, ob und unter welchem Namen sie in die
/// monatliche Online-Bestenliste eingetragen werden soll.
///
/// Liefert über Navigator.pop den gewählten Anzeigenamen oder null.
class OnlineHighscoreDialog extends StatefulWidget {
  const OnlineHighscoreDialog(this.playerName, this.score, this.rank,
      this.localityName, this.suggestedName,
      {super.key});

  final String playerName;
  final int score;
  final int rank;
  final String localityName;
  final String suggestedName;

  @override
  State<OnlineHighscoreDialog> createState() => _OnlineHighscoreDialogState();
}

class _OnlineHighscoreDialogState extends State<OnlineHighscoreDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.suggestedName);
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!OnlineHighscores.isValidName(_controller.text)) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(OnlineHighscores.sanitizeName(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AppDialog(
        title: loc.online_hs_title,
        showClose: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.emoji_events, color: mainyellow, size: 36),
            SizedBox(width: 10),
            Expanded(
                child: dialogText(loc.online_hs_text(widget.playerName,
                    widget.score, widget.rank, widget.localityName))),
          ]),
          SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: OnlineHighscores.maxNameLength,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.lato(fontSize: 16),
            decoration: InputDecoration(
              labelText: loc.online_hs_name_label,
              errorText: _showError ? loc.online_hs_name_invalid : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (_) {
              if (_showError) setState(() => _showError = false);
            },
            onSubmitted: (_) => _submit(),
          ),
        ]),
        actions: [
          dialogSecondaryButton(
              loc.online_hs_skip, () => Navigator.of(context).pop(null)),
          dialogPrimaryButton(loc.online_hs_submit, _submit,
              icon: Icons.emoji_events_outlined),
        ]);
  }
}
