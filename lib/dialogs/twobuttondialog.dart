import 'package:flutter/material.dart';
import 'package:soccerpark/widgets/button.dart';

import '../main.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';

class TwoButtonDialog extends StatelessWidget {
  TwoButtonDialog(this.title, this.text, this.buttonText1, this.buttonText2,
      this.func1, this.func2);

  final String title;
  final String text;
  final String buttonText1;
  final String buttonText2;
  final Function() func1;
  final Function() func2;

  @override
  Widget build(BuildContext context) {
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
                  TitleText(text: title, indent: 16, color: Colors.white),
                  Spacer(),
                ])),
            Space(30),
            FloatText(text),
            Space(20),
            getButtonRow(),
            Space(10),
          ],
        ),
      ),
    );
  }

  Widget getButtonRow() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(spacing: 6, children: [
          DialogButton(buttonText1, func1),
          DialogButton(buttonText2, func2)
        ]));
  }
}
