import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import './mainpage.dart';
import './localitysplashpage.dart';
import '../utils/data.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';

class LocalitySplashPage extends StatelessWidget {
  const LocalitySplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    double sep = 20;

    return Scaffold(
        appBar: null,
        body: ListView(children: [
          Space(128),
          Image.asset(Data.getSoccerPicString(App.of(context).getLocality())),
          Space(64),
          Row(children: [
            Spacer(),
            Text(AppLocalizations.of(context)!.choose_park,
                style: GoogleFonts.lato(color: maincolor, fontSize: 18)),
            Spacer()
          ]),
          Space(40),
          getImageRow(context, Locality.SALZBURG),
          Space(sep),
          getImageRow(context, Locality.WAGRAIN),
          Space(sep),
          getImageRow(context, Locality.GOLDBERG),
          Space(sep),
          Space(40)
        ]));
  }

  Widget getImageRow(BuildContext context, Locality loc) {
    return Row(children: [
      Expanded(flex: 1, child: Container()),
      Expanded(flex: 2, child: getImage(context, loc)),
      Expanded(flex: 1, child: Container()),
    ]);
  }

  Widget getImage(BuildContext context, Locality loc) {
    return GestureDetector(
        child: Image.asset(
          Data.getLocalityImageString(loc),
        ),
        onTap: () {
          App.of(context).setLocality(loc);
          Data.setInitChosen();
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        });
  }
}
