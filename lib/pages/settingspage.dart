import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/appbar.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/checkbox.dart';
import '../utils/data.dart';
import '../utils/flags.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locality loc = Locality.SALZBURG;
  bool comp = true;
  bool interm = true;
  bool english = true;

  final double rowheight = 40;
  final double hsep = 8;
  final double sep = 12;
  final double height_flags = 25;
  final double height_socc = 30;
  final double linewidth = 1;

  TextStyle style =
      GoogleFonts.lato(color: Colors.black, fontSize: 18, height: 1.3);

  @override
  void initState() {
    super.initState();
    setState(() {
      english = App.of(context).isEnglish();
    });
    setState(() {
      loc = App.of(context).getLocality();
    });
    setState(() {
      comp = App.of(context).isCompare();
    });
    setState(() {
      interm = App.of(context).isIntermediate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(context, AppLocalizations.of(context)!.settings,
            MenuItemE.SETTINGS, [ShareButton(() {})]),
        body: Stack(children: [
          ListView(children: <Widget>[
            Header(),
            Space(4),
            getLanguageRow(),
            getDivider(),
            getSoccerparkRow(),
            getDivider(),
            //getCompRow(),
            //getDivider(),
            //getIntermediateRow(),
            //getDivider()
          ]),
        ]));
  }

  Widget getDivider() {
    return Column(children: [
      Space(sep),
      Container(
          child: SizedBox(height: linewidth, width: double.infinity),
          color: maincolor),
      Space(sep),
    ]);
  }

  Widget getLanguageRow() {
    return Row(
      children: [
        SpaceH(16),
        Text(AppLocalizations.of(context)!.language, style: style),
        Spacer(),
        GestureDetector(
            child: getGermanFlag(),
            onTap: () {
              setState(() {
                english = false;
                App.of(context).setLocale(false);
              });
            }),
        SpaceH(hsep),
        GestureDetector(
            child: getEnglishFlag(),
            onTap: () {
              setState(() {
                english = true;

                App.of(context).setLocale(true);
              });
            }),
        SpaceH(16)
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget getGermanFlag() {
    if (english)
      return ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.grey,
            BlendMode.saturation,
          ),
          child: flag_de_sized(height_flags));
    return flag_de_sized(height_flags);
  }

  Widget getEnglishFlag() {
    if (!english)
      return ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.grey,
            BlendMode.saturation,
          ),
          child: flag_uk_sized(height_flags));
    return flag_uk_sized(height_flags);
  }

  Widget getSoccerparkRow() {
    return Row(
      children: [
        SpaceH(16),
        Text("Soccerpark", style: style),
        Spacer(),
        getSoccerparkImage(Locality.SALZBURG),
        SpaceH(hsep),
        getSoccerparkImage(Locality.WAGRAIN),
        SpaceH(hsep),
        getSoccerparkImage(Locality.GOLDBERG),
        SpaceH(16)
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget getSoccerparkImage(Locality l) {
    return GestureDetector(
        child: getSoccerparkImageImpl(Data.getLocalityImageString(l),
            Data.getLocalityGreyString(l), l == loc),
        onTap: () {
          setState(() {
            loc = l;
            App.of(context).setLocality(l);
          });
        });
  }

  Widget getSoccerparkImageImpl(
      String source, String sourceGrey, bool enabled) {
    if (enabled)
      return Image.asset(
        source,
        height: height_socc,
      );
    return Image.asset(
      sourceGrey,
      height: height_socc,
    );
  }

  Widget getCompRow() {
    return Row(
      children: [
        SpaceH(16),
        Text(AppLocalizations.of(context)!.compare, style: style),
        Spacer(),
        CustomCheckbox(comp, (bool? checked) {
          setState(() {
            comp = checked!;
          });
          App.of(context).setCompare(comp);
        }),
        SpaceH(16)
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget getIntermediateRow() {
    return Row(
      children: [
        SpaceH(16),
        Expanded(
            child:
                Text(AppLocalizations.of(context)!.intermediate, style: style)),
        //Spacer(),
        CustomCheckbox(interm, (bool? checked) {
          setState(() {
            interm = checked!;
          });
          App.of(context).setIntermediate(interm);
        }),
        SpaceH(16)
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }
}
