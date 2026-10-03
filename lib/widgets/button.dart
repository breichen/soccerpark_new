import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/space.dart';

class FullWidthButton extends StatelessWidget {
  final String text;
  final void Function() func;
  final double padding;
  final bool disable;

  FullWidthButton(this.text, this.func,
      {this.padding = 20, this.disable = false});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: padding),
        child: TextButton(
          style: TextButton.styleFrom(
              textStyle: GoogleFonts.lato(
                fontSize: 15,
                color: mainred,
              ),
              minimumSize: const Size.fromHeight(30),
              backgroundColor: disable ? Colors.grey[100] : Colors.grey[200],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                      width: 1,
                      color: disable ? Colors.grey[200]! : Colors.grey[400]!)),
              foregroundColor: disable ? Colors.grey[400] : mainred,
              surfaceTintColor: mainred,
              shadowColor: mainred),
          onPressed: () {
            if (!disable) func();
          },
          child: Text(text.toUpperCase()),
        ));
  }
}

class RedFullWidthButton extends StatelessWidget {
  final String text;
  final void Function() func;
  final double padding;
  final bool disable;

  RedFullWidthButton(this.text, this.func,
      {this.padding = 20, this.disable = false});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: padding),
        child: TextButton(
          style: TextButton.styleFrom(
              textStyle: GoogleFonts.lato(
                fontSize: 15,
                color: mainred,
              ),
              minimumSize: const Size.fromHeight(30),
              backgroundColor: disable ? Colors.grey[100] : mainred,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              foregroundColor: Colors.white,
              surfaceTintColor: mainred,
              shadowColor: mainred),
          onPressed: () {
            if (!disable) func();
          },
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ));
  }
}

class Button extends StatelessWidget {
  final String text;
  final void Function() func;
  final bool disable;

  Button(this.text, this.func, {this.disable = false});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 30.0,
      minWidth: 70.0,
      color: mainred,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: new Text(text.toUpperCase(),
          style: GoogleFonts.lato(
            fontSize: 15,
            color: Colors.white,
          )),
      onPressed: () {
        if (!disable) func();
      },
    );
  }
}

class DialogButton extends StatelessWidget {
  final String text;
  final void Function() func;

  DialogButton(this.text, this.func);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 15,
        ),
        backgroundColor: Colors.white,
        foregroundColor: mainred,
      ),
      onPressed: func,
      child: Text(text.toUpperCase()),
    );
  }
}

class DialogButtonWithIcon extends StatelessWidget {
  final String text;
  final String imgStr;
  final void Function() func;

  DialogButtonWithIcon(this.text, this.imgStr, this.func);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 15,
          ),
          backgroundColor: Colors.white,
          foregroundColor: mainred,
        ),
        onPressed: func,
        child: Row(
          children: [
            Image.asset(imgStr, color: mainred, width: 24),
            SpaceH(4),
            Text(text.toUpperCase(),
                style: GoogleFonts.lato(color: Color(mainredValue)))
          ],
        ));
  }
}

class FakeButton extends StatelessWidget {
  final String text;
  final void Function() func;

  FakeButton(this.text, this.func);

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
      text: text,
      style: const TextStyle(
          height: 1.3,
          fontSize: 15,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
          color: Color(mainredValue)),
      recognizer: TapGestureRecognizer()..onTap = func,
    ));
  }
}

class FlActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function() func;

  FlActionButton(this.text, this.icon, this.func);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: func,
      label: Text(text),
      icon: Icon(icon),
      backgroundColor: mainred,
      foregroundColor: Colors.white,
    );
  }
}
