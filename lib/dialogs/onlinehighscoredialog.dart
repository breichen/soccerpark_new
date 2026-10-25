import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:soccerpark/widgets/button.dart';

import '../main.dart';
import '../utils/online_highscores.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';

/// Fragt nach einer Top-10-Runde, ob und unter welchem Namen sie in die
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
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                color: maincolor,
                padding: EdgeInsets.fromLTRB(0, 8, 10, 8),
                child: Row(children: [
                  TitleText(
                      text: loc.online_hs_title,
                      indent: 16,
                      color: Colors.white),
                  Spacer(),
                  Icon(Icons.emoji_events, color: mainyellow),
                ])),
            Space(24),
            FloatText(loc.online_hs_text(widget.playerName, widget.score,
                widget.rank, widget.localityName)),
            Space(16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _controller,
                autofocus: true,
                maxLength: OnlineHighscores.maxNameLength,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                style: GoogleFonts.lato(fontSize: 16),
                decoration: InputDecoration(
                  labelText: loc.online_hs_name_label,
                  errorText: _showError ? loc.online_hs_name_invalid : null,
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (_showError) setState(() => _showError = false);
                },
                onSubmitted: (_) => _submit(),
              ),
            ),
            Space(8),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Wrap(spacing: 6, children: [
                  DialogButton(loc.online_hs_skip, () {
                    Navigator.of(context).pop(null);
                  }),
                  DialogButton(loc.online_hs_submit, _submit),
                ])),
            Space(10),
          ],
        ),
      ),
    );
  }
}
