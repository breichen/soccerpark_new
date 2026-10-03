import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class FloatText extends StatelessWidget {
  final String text;
  final double left;

  FloatText(this.text, {this.left = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(left, 0, 14, 0),
        alignment: Alignment.topLeft,
        //padding: itemEdges,
        child: Text(
          text,
          style:
              GoogleFonts.lato(color: Colors.black, fontSize: 16, height: 1.3),
        ));
  }
}

class BoldFloatText extends StatelessWidget {
  final String text;

  BoldFloatText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.topLeft,
        //padding: itemEdges,
        child: Text(
          text,
          style: GoogleFonts.lato(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.3),
        ));
  }
}

class TitleText extends StatelessWidget {
  final String text;
  final double indent;
  final Color color;

  TitleText({required this.text, this.indent = 0, this.color = maincolor});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(indent, 0, 0, 0),
        alignment: Alignment.topLeft,
        //padding: itemEdges,
        child: Text(
          text,
          style: GoogleFonts.lato(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3),
        ));
  }
}
