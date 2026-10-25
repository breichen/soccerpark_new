import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/data.dart';
import './space.dart';

/// Kopfbereich der Seiten: Foto der Anlage mit dem Logo als weiße
/// Plakette an der Unterkante. Enthält darunter bereits den nötigen
/// Abstand, damit das überstehende Logo nichts verdeckt.
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final locality = App.of(context).getLocality();
    return Column(children: [
      Stack(clipBehavior: Clip.none, children: [
        SizedBox(
            height: 150,
            width: double.infinity,
            child: Image.asset(Data.getSoccerPicString(locality),
                fit: BoxFit.cover)),
        Positioned(left: 0, right: 0, bottom: -24, child: Center(child: HeaderLogo())),
      ]),
      Space(40),
    ]);
  }
}

/// Logo der Anlage als weiße Plakette.
class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 52,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!)),
        child: Image.asset(
            Data.getLocalityImageString(App.of(context).getLocality()),
            fit: BoxFit.contain));
  }
}
