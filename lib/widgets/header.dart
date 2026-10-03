import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/data.dart';
import './space.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Space(10),
      HeaderLogo(),
      Space(10),
      Image.asset(Data.getSoccerPicString(App.of(context).getLocality())),
      Space(20),
    ]);
  }
}

class HeaderLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      //padding: itemEdges,
      child: Image.asset(
          Data.getLocalityImageString(App.of(context).getLocality())),
    );
  }
}
