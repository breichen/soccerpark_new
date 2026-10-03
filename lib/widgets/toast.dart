import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';
import './space.dart';

class CustomToast {
  static void showToast(BuildContext context, String text) {
    return showToastIcon(context, text, Icons.error);
  }

  static void showToastIcon(BuildContext context, String text, IconData icon,
      {int dur = 3}) {
    var toast = FToast();
    toast.init(context);
    return toast.showToast(
        child: Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              //border: Border.all(
              //  color: Colors.black,
              //),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(children: [
              Icon(icon, size: 30, color: Colors.black),
              SpaceH(2),
              Expanded(
                  flex: 1,
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black)))
            ])),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: dur));
  }
}
