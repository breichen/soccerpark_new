import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/toast.dart';

class VenuePage extends StatefulWidget {
  const VenuePage({super.key});

  @override
  State<VenuePage> createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  GlobalKey _globalKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Locality loc = App.of(context).getLocality();

    return Scaffold(
        appBar: CustomAppBar(context, AppLocalizations.of(context)!.venue,
            MenuItemE.VENUE, [getShareButton()]),
        body: Stack(children: [
          ListView(children: <Widget>[Header(), Space(0), getBody(loc)]),
          Column(children: [Spacer(), Footer()])
        ]));
  }

  Widget getShareButton() {
    return ShareButton(() {
      share(
          _globalKey,
          AppLocalizations.of(context)!.share_text_venue +
              " " +
              Data.getLocalityStringImm(App.of(context).getLocality()) +
              AppLocalizations.of(context)!.share_text2 +
              Data.getWebsiteStringImm(context, App.of(context).getLocality()));
    });
  }

  Widget getBody(Locality loc) {
    if (loc == Locality.SALZBURG) return getBodySbg();
    if (loc == Locality.WAGRAIN) return getBodyWag();
    return getBodyGold();
  }

  Widget getBodySbg() {
    return Column(children: [
      RepaintBoundary(
          key: _globalKey,
          child: Container(
              color: bgcolor, child: Image.asset("assets/pics/anfahrt.png"))),
      Space(13),
      Container(
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: FakeButton(AppLocalizations.of(context)!.description, () {
            launch("https://www.soccerpark.at/anfahrt.html");
          })),
      Space(4),
      Container(
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: FakeButton(AppLocalizations.of(context)!.map, () {
            launch("https://goo.gl/maps/JvmEtJ2md8DiG97p6");
          })),
      Space(4),
      Container(
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: FakeButton(AppLocalizations.of(context)!.bus, () {
            launch("https://fahrplan.salzburg-verkehr.at/");
          })),
    ]);
  }

  Widget getBodyWag() {
    return Column(children: [
      Image.asset("assets/pics/anfahrt_wagrain.jpg"),
      Space(13),
      Container(
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: FakeButton(AppLocalizations.of(context)!.description, () {
            launch("https://www.soccerpark-wagrain.at/anfahrt.html");
          })),
      Space(4),
      Container(
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: FakeButton(AppLocalizations.of(context)!.map, () {
            launch("https://goo.gl/maps/PgS2o6qghzMpFEav7");
          })),
      Space(4),
      Container(
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: FakeButton(AppLocalizations.of(context)!.bus, () {
            launch("https://fahrplan.salzburg-verkehr.at/");
          })),
    ]);
  }

  Widget getBodyGold() {
    return Column(children: [
      Image.asset("assets/pics/anfahrt_goldberg.png"),
      Space(13),
      Container(
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: FakeButton(AppLocalizations.of(context)!.map, () {
            launch(
                "https://www.ooevv.at/?seite=fahrplan-preisauskunft&sprache=DE");
          })),
      Space(4),
      Container(
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: FakeButton(AppLocalizations.of(context)!.bus, () {
            launch("https://goo.gl/maps/oCBF2TcFxRLVjhAz8");
          })),
    ]);
  }

  void launch(String url) async {
    Uri uri = Uri.parse(url);
    if (/*await canLaunchUrl(uri)*/ true) {
      await launchUrl(uri);
    } else {
      CustomToast.showToast(
        context,
        AppLocalizations.of(context)!.url_error,
      );
    }
  }
}
