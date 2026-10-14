import 'package:flutter/material.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';
import '../widgets/toast.dart';
import './addplayerdialog.dart';

class EditPlayerDialog extends StatefulWidget {
  EditPlayerDialog(this.name, this.func);

  final String name;
  final bool Function(String text) func;

  @override
  State<EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<EditPlayerDialog> {
  final TextEditingController textController = new TextEditingController();

  bool emptyError = false;
  bool duplError = false;

  @override
  Widget build(BuildContext context) {
    textController.text = widget.name;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                color: mainred,
                padding: EdgeInsets.fromLTRB(0, 8, 10, 8),
                child: Row(children: [
                  TitleText(
                      text: AppLocalizations.of(context)!.edit,
                      indent: 16,
                      color: Colors.white),
                  Spacer(),
                ])),
            Space(30),
            Row(
              children: [
                Spacer(),
                NewPlayerTextField(textController),
                Spacer(),
              ],
            ),
            Space(10),
            Visibility(
                child: Text(
                    duplError
                        ? AppLocalizations.of(context)!.duplicate_name_error
                        : AppLocalizations.of(context)!.empty_name_error,
                    style: GoogleFonts.lato(
                      color: mainred,
                      fontSize: 14,
                    )),
                visible: emptyError || duplError,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true),
            Space(5),
            Row(children: [
              Spacer(),
              DialogButton(AppLocalizations.of(context)!.cancel, () {
                Navigator.of(context).pop();
              }),
              SpaceH(20),
              DialogButton(AppLocalizations.of(context)!.ok, () {
                if (textController.text == "") {
                  setState(() {
                    emptyError = true;
                  });
                  Future.delayed(
                      const Duration(seconds: 2),
                      () => {
                            setState(() {
                              emptyError = false;
                            })
                          });
                } else if (widget.func(textController.text)) {
                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    duplError = true;
                  });
                  Future.delayed(
                      const Duration(seconds: 2),
                      () => {
                            setState(() {
                              duplError = false;
                            })
                          });
                }
              }),
              SpaceH(20)
            ]),
            Space(10),
          ],
        ),
      ),
    );
  }
}
