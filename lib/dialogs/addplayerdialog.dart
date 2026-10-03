import 'package:flutter/material.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';
import '../widgets/toast.dart';

class AddPlayerDialog extends StatefulWidget {
  AddPlayerDialog(this.func);

  final bool Function(String text) func;

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final TextEditingController textController = new TextEditingController();

  bool emptyError = false;
  bool duplError = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                color: mainred,
                padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Row(children: [
                  TitleText(
                      text: AppLocalizations.of(context)!.addPlayer,
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

class NewPlayerTextField extends StatelessWidget {
  NewPlayerTextField(this.textController);

  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 250,
        height: 45,
        child: TextField(
            controller: textController,
            scrollPadding: EdgeInsets.all(40),
            maxLines: 1,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                filled: true,
                focusColor: maincolor,
                border: OutlineInputBorder(),
                hintText: 'Name')));
  }
}
