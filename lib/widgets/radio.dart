import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class RadioButton extends StatelessWidget {
  final String text;
  final void Function() func;
  final bool disabled;
  final int type; // 0: left / 1: center / 2: right

  final double radius = 40;
  final bool small;

  RadioButton(this.type, this.text, this.func, this.disabled,
      {this.small = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: ClipRRect(
            borderRadius: type == 0
                ? BorderRadius.only(
                    topLeft: Radius.circular(radius),
                    bottomLeft: Radius.circular(radius))
                : (type == 2
                    ? BorderRadius.only(
                        topRight: Radius.circular(radius),
                        bottomRight: Radius.circular(radius))
                    : BorderRadius.only()),
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: small ? 8 : 9, vertical: small ? 4 : 4),
                color: disabled ? Colors.grey[300] : mainred,
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: small ? 13 : 15,
                      height: 1.0),
                ))),
        onTap: func);
  }
}
