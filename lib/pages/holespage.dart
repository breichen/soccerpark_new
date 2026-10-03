import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../widgets/appbar.dart';
import '../widgets/space.dart';
import '../dialogs/holedialog.dart';

class HolesPage extends StatefulWidget {
  const HolesPage({super.key});

  @override
  State<HolesPage> createState() => _HolesPageState();
}

class _HolesPageState extends State<HolesPage> {
  GlobalKey _globalKey = new GlobalKey();

  bool showPlan = true;

  @override
  void initState() {
    super.initState();

    setState(() {
      showPlan = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(context, AppLocalizations.of(context)!.holes,
            MenuItemE.COUNT, [getShareButton()]),
        body: Column(children: [
          getMenuRow(),
          Expanded(child: ListView(children: [Space(20), getContent(context)]))
        ]));
  }

  Widget getShareButton() {
    return ShareButton(() {
      share(
          _globalKey,
          AppLocalizations.of(context)!.share_text_holes +
              " " +
              Data.getLocalityStringImm(App.of(context).getLocality()) +
              AppLocalizations.of(context)!.share_text2 +
              Data.getWebsiteStringImm(context, App.of(context).getLocality()));
    });
  }

  Widget getMenuRow() {
    return Row(children: [
      Expanded(
          child: Clickable(AppLocalizations.of(context)!.plan, () {
        setState(() {
          showPlan = true;
        });
      }, !showPlan)),
      Expanded(
          child: Clickable(AppLocalizations.of(context)!.holes, () {
        setState(() {
          showPlan = false;
        });
      }, showPlan))
    ]);
  }

  Widget getContent(BuildContext context) {
    return showPlan ? getPlan(context) : getHolePics(context);
  }

  Widget getPlan(BuildContext context) {
    if (App.of(context).getLocality() == Locality.WAGRAIN)
      return RotatedBox(quarterTurns: 1, child: getImage());
    return getImage();
  }

  Widget getImage() {
    return Center(
        child: InteractiveViewer(
            scaleEnabled: true,
            panEnabled: false,
            minScale: 0.5,
            maxScale: 2,
            child: RepaintBoundary(
                key: _globalKey,
                child: Container(
                    color: bgcolor,
                    child: Image.asset(Data.getHolesPicStrImm(
                        App.of(context).getLocality()))))));
  }
}

Widget getHolePics(BuildContext context) {
  List<Widget> pics = [];
  for (var i = 1; i <= 18; i++) pics.add(getHolePic(context, i));

  return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.all(10),
      child: Wrap(
        children: pics,
      ));
}

Widget getHolePic(BuildContext context, int holeId) {
  return GestureDetector(
      onTap: () {
        HoleDialog dialog = HoleDialog(App.of(context).getLocality(), holeId);
        showDialog(context: context, builder: (BuildContext context) => dialog);
      },
      child: Container(
          margin: EdgeInsets.all(3),
          color: mainred,
          child: Container(
              margin: EdgeInsets.all(4),
              //color: Colors.lightGreen,
              alignment: Alignment.center,
              //height: 100,
              width: 100,
              child: Column(children: [
                getHoleHeader(context, holeId),
                getHoleImage(context, holeId)
              ]))));
}

Widget getHoleHeader(BuildContext context, int holeId) {
  return Container(
      color: mainred,
      padding: EdgeInsets.fromLTRB(4, 0, 4, 2),
      child: Row(children: [
        Text(
          AppLocalizations.of(context)!.hole.toUpperCase() +
              " " +
              holeId.toString(),
          style: GoogleFonts.lato(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Spacer(),
      ]));
}

Widget getHoleImage(BuildContext context, int holeId) {
  return Image.asset(
      Data.getHolePicStrImm(App.of(context).getLocality(), holeId));
}

class Clickable extends StatelessWidget {
  final String text;
  final void Function() func;
  final bool disable;

  Clickable(this.text, this.func, this.disable);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          alignment: Alignment.center,
          color: disable ? maingrey : mainred,
          child: new Text(text.toUpperCase(),
              style: GoogleFonts.lato(
                fontSize: 15,
                color: Colors.white,
              ))),
      onTap: () {
        if (disable) func();
      },
    );
  }
}
