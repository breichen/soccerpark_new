import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:path_drawing/path_drawing.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../widgets/appbar.dart';
import '../widgets/space.dart';
import '../dialogs/holedialog.dart';

class HolesPage extends StatefulWidget {
  const HolesPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HolesPage> createState() => _HolesPageState();
}

class _HolesPageState extends State<HolesPage> {
  GlobalKey _globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double basewidth = 411.42857142857144;
    final double width = MediaQuery.of(context).size.width;
    final double factor = width / basewidth;
    final double origWidth = getOrigWidth(context);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: CustomAppBar(context, AppLocalizations.of(context)!.holes,
            MenuItemE.COUNT, [getShareButton()]),
        body: ListView(children: [
          getContent(basewidth * factor, origWidth),
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

  double getOrigWidth(BuildContext context) {
    var loc = App.of(context).getLocality();
    if (loc == Locality.SALZBURG) return 388.0;
    if (loc == Locality.WAGRAIN) return 671.0;
    return 1000; // TODO
  }

  Widget getContent(double width, double origWidth) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[Space(40), getImagesBox(width, origWidth)]);
  }

  Widget getImagesBox(double width, double origWidth) {
    return Row(children: [
      //FittedBox(
      //   fit: BoxFit.fill,
      //child:
      getImages(width, origWidth),
      //)
    ]);
  }

  Widget getImages(double width, double origWidth) {
    if (App.of(context).getLocality() == Locality.WAGRAIN)
      return RotatedBox(
          quarterTurns: 1,
          child:
              Stack(children: [getImage(width), getClipped(width, origWidth)]));
    //return Stack(children: [getImage(width), getClipped(width, origWidth)]);
    return Stack(children: [getImage(width)]);
  }

  Widget getImage(double width) {
    return RepaintBoundary(
        key: _globalKey,
        child: Container(
            color: bgcolor,
            child: Image.asset(
                Data.getHolesPicStrImm(App.of(context).getLocality()),
                width: width,
                height: 643 / 388 * width)));
  }

  Stack getClipped(double width, double origWidth) {
    Locality loc = App.of(context).getLocality();
    if (loc == Locality.SALZBURG) return getClippedSbg(width, origWidth);
    if (loc == Locality.WAGRAIN) return getClippedWagrain(width, origWidth);
    return getClippedGoldberg(width, origWidth);
  }

  Stack getClippedSbg(double width, double origWidth) {
    return Stack(children: <Widget>[
      _getClippedImage(
          _Clipper(298, 471, 332, 634, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(291, 511, 298, 560, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(258, 441, 291, 634, width, origWidth), 2, width),
      _getClippedImage(
          _Clipper(255, 441, 258, 480, width, origWidth), 2, width),
      _getClippedImage(
          _Clipper(291, 433, 317, 463, width, origWidth), 2, width),
      _getClippedImage(
          _Clipper(220, 480, 256, 634, width, origWidth), 3, width),
      _getClippedImage(
          _Clipper(241, 426, 255, 445, width, origWidth), 4, width),
      _getClippedImage(
          _Clipper(255, 420, 270, 441, width, origWidth), 4, width),
      _getClippedImage(
          _Clipper(270, 362, 325, 436, width, origWidth), 4, width),
      _getClippedImage(
          _Clipper(233, 354, 270, 398, width, origWidth), 4, width),
      _getClippedImage(
          _Clipper(284, 284, 330, 354, width, origWidth), 5, width),
      _getClippedImage(_Clipper(286, 94, 330, 284, width, origWidth), 5, width),
      _getClippedImage(_Clipper(283, 48, 330, 94, width, origWidth), 5, width),
      _getClippedImage(_Clipper(85, 0, 122, 62, width, origWidth), 6, width),
      _getClippedImage(_Clipper(122, 0, 220, 55, width, origWidth), 6, width),
      _getClippedImage(_Clipper(220, 0, 255, 65, width, origWidth), 6, width),
      _getClippedImage(_Clipper(255, 68, 283, 270, width, origWidth), 7, width),
      _getClippedImage(_Clipper(233, 68, 255, 94, width, origWidth), 7, width),
      _getClippedImage(_Clipper(219, 65, 233, 88, width, origWidth), 7, width),
      _getClippedImage(_Clipper(209, 62, 219, 84, width, origWidth), 7, width),
      _getClippedImage(_Clipper(200, 58, 209, 81, width, origWidth), 7, width),
      _getClippedImage(_Clipper(143, 55, 200, 79, width, origWidth), 7, width),
      _getClippedImage(
          _Clipper(230, 234, 267, 334, width, origWidth), 8, width),
      _getClippedImage(
          _Clipper(230, 199, 254, 234, width, origWidth), 8, width),
      _getClippedImage(
          _Clipper(191, 400, 240, 429, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(188, 364, 222, 400, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(190, 361, 224, 364, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(192, 359, 225, 361, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(195, 353, 225, 359, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(202, 345, 230, 353, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(230, 337, 272, 354, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(171, 480, 212, 634, width, origWidth), 10, width),
      _getClippedImage(
          _Clipper(178, 442, 226, 480, width, origWidth), 10, width),
      _getClippedImage(
          _Clipper(129, 469, 166, 637, width, origWidth), 11, width),
      _getClippedImage(
          _Clipper(141, 439, 177, 469, width, origWidth), 11, width),
      _getClippedImage(
          _Clipper(150, 364, 186, 433, width, origWidth), 12, width),
      _getClippedImage(
          _Clipper(160, 341, 188, 364, width, origWidth), 12, width),
      _getClippedImage(
          _Clipper(188, 341, 200, 348, width, origWidth), 12, width),
      _getClippedImage(
          _Clipper(173, 295, 211, 341, width, origWidth), 12, width),
      _getClippedImage(
          _Clipper(184, 239, 215, 295, width, origWidth), 12, width),
      _getClippedImage(
          _Clipper(186, 224, 215, 239, width, origWidth), 12, width),
      _getClippedImage(
          _Clipper(195, 90, 224, 218, width, origWidth), 13, width),
      _getClippedImage(
          _Clipper(173, 81, 195, 112, width, origWidth), 13, width),
      _getClippedImage(_Clipper(195, 82, 200, 90, width, origWidth), 13, width),
      _getClippedImage(_Clipper(83, 64, 130, 83, width, origWidth), 14, width),
      _getClippedImage(_Clipper(83, 83, 139, 176, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(83, 176, 134, 186, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(83, 186, 131, 192, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(83, 192, 125, 198, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(83, 198, 115, 210, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(83, 212, 117, 243, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(117, 204, 124, 232, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(124, 199, 130, 232, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(130, 194, 133, 229, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(133, 190, 137, 227, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(137, 169, 164, 223, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(142, 112, 167, 169, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(167, 113, 189, 152, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(70, 255, 112, 282, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(112, 259, 132, 285, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(132, 262, 177, 288, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(156, 244, 180, 262, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(161, 232, 182, 244, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(161, 224, 184, 232, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(168, 208, 187, 224, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(171, 167, 193, 208, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(85, 285, 111, 439, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(111, 288, 129, 468, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(129, 291, 140, 468, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(140, 291, 169, 347, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(85, 469, 128, 634, width, origWidth), 18, width),
      _getClippedImage(
          _Clipper(85, 447, 105, 469, width, origWidth), 18, width),
    ]);
  }

  Stack getClippedWagrain(double width, double origWidth) {
    return Stack(children: <Widget>[
      _getClippedImage(
          _Clipper(279, 205, 307, 226, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(307, 197, 320, 226, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(320, 191, 329, 226, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(329, 184, 333, 226, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(333, 180, 339, 226, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(339, 176, 355, 226, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(355, 171, 360, 214, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(360, 168, 364, 214, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(364, 165, 368, 214, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(368, 147, 395, 214, width, origWidth), 1, width),
      _getClippedImage(
          _Clipper(403, 147, 563, 180, width, origWidth), 2, width),
      _getClippedImage(
          _Clipper(576, 100, 652, 126, width, origWidth), 3, width),
      _getClippedImage(
          _Clipper(608, 126, 652, 187, width, origWidth), 3, width),
      _getClippedImage(
          _Clipper(591, 155, 608, 187, width, origWidth), 3, width),
      _getClippedImage(
          _Clipper(585, 153, 591, 175, width, origWidth), 3, width),
      _getClippedImage(
          _Clipper(580, 150, 585, 171, width, origWidth), 3, width),
      _getClippedImage(
          _Clipper(578, 149, 580, 168, width, origWidth), 3, width),
      _getClippedImage(
          _Clipper(564, 145, 578, 164, width, origWidth), 3, width),
      _getClippedImage(
          _Clipper(476, 101, 571, 141, width, origWidth), 4, width),
      _getClippedImage(
          _Clipper(571, 126, 575, 144, width, origWidth), 4, width),
      _getClippedImage(
          _Clipper(575, 129, 584, 145, width, origWidth), 4, width),
      _getClippedImage(
          _Clipper(584, 132, 599, 149, width, origWidth), 4, width),
      _getClippedImage(
          _Clipper(344, 112, 471, 138, width, origWidth), 5, width),
      _getClippedImage(_Clipper(325, 53, 373, 88, width, origWidth), 6, width),
      _getClippedImage(_Clipper(296, 61, 325, 131, width, origWidth), 6, width),
      _getClippedImage(
          _Clipper(325, 102, 340, 124, width, origWidth), 6, width),
      _getClippedImage(_Clipper(283, 69, 296, 127, width, origWidth), 6, width),
      _getClippedImage(_Clipper(277, 24, 348, 54, width, origWidth), 7, width),
      _getClippedImage(_Clipper(348, 24, 405, 50, width, origWidth), 7, width),
      _getClippedImage(_Clipper(376, 50, 405, 100, width, origWidth), 7, width),
      _getClippedImage(_Clipper(255, 56, 275, 72, width, origWidth), 8, width),
      _getClippedImage(_Clipper(251, 72, 271, 96, width, origWidth), 8, width),
      _getClippedImage(_Clipper(249, 96, 268, 102, width, origWidth), 8, width),
      _getClippedImage(
          _Clipper(247, 102, 270, 146, width, origWidth), 8, width),
      _getClippedImage(
          _Clipper(270, 121, 277, 150, width, origWidth), 8, width),
      _getClippedImage(
          _Clipper(277, 129, 285, 154, width, origWidth), 8, width),
      _getClippedImage(
          _Clipper(285, 135, 325, 159, width, origWidth), 8, width),
      _getClippedImage(
          _Clipper(325, 135, 336, 153, width, origWidth), 8, width),
      _getClippedImage(
          _Clipper(232, 190, 263, 222, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(263, 174, 274, 206, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(274, 170, 298, 201, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(298, 167, 312, 192, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(312, 163, 322, 184, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(322, 162, 325, 179, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(325, 161, 329, 177, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(329, 160, 331, 176, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(331, 159, 335, 175, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(335, 155, 340, 173, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(340, 148, 351, 170, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(351, 148, 362, 165, width, origWidth), 9, width),
      _getClippedImage(
          _Clipper(146, 227, 154, 249, width, origWidth), 10, width),
      _getClippedImage(
          _Clipper(154, 223, 267, 252, width, origWidth), 10, width),
      _getClippedImage(
          _Clipper(111, 252, 153, 273, width, origWidth), 11, width),
      _getClippedImage(
          _Clipper(100, 240, 111, 273, width, origWidth), 11, width),
      _getClippedImage(
          _Clipper(91, 226, 100, 269, width, origWidth), 11, width),
      _getClippedImage(_Clipper(82, 213, 91, 269, width, origWidth), 11, width),
      _getClippedImage(_Clipper(79, 207, 82, 269, width, origWidth), 11, width),
      _getClippedImage(_Clipper(77, 206, 79, 269, width, origWidth), 11, width),
      _getClippedImage(_Clipper(75, 204, 77, 269, width, origWidth), 11, width),
      _getClippedImage(_Clipper(51, 201, 75, 269, width, origWidth), 11, width),
      _getClippedImage(_Clipper(21, 63, 44, 149, width, origWidth), 12, width),
      _getClippedImage(_Clipper(44, 44, 66, 188, width, origWidth), 12, width),
      _getClippedImage(_Clipper(66, 24, 75, 81, width, origWidth), 12, width),
      _getClippedImage(_Clipper(75, 24, 84, 69, width, origWidth), 12, width),
      _getClippedImage(_Clipper(84, 24, 99, 58, width, origWidth), 12, width),
      _getClippedImage(_Clipper(66, 133, 69, 188, width, origWidth), 12, width),
      _getClippedImage(_Clipper(69, 149, 73, 188, width, origWidth), 12, width),
      _getClippedImage(_Clipper(112, 18, 182, 42, width, origWidth), 13, width),
      _getClippedImage(_Clipper(182, 18, 275, 44, width, origWidth), 13, width),
      _getClippedImage(_Clipper(222, 48, 248, 67, width, origWidth), 14, width),
      _getClippedImage(_Clipper(198, 51, 222, 84, width, origWidth), 14, width),
      _getClippedImage(_Clipper(192, 55, 198, 89, width, origWidth), 14, width),
      _getClippedImage(_Clipper(181, 61, 192, 96, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(167, 79, 181, 110, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(161, 91, 167, 120, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(153, 96, 161, 125, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(148, 102, 153, 125, width, origWidth), 14, width),
      _getClippedImage(
          _Clipper(141, 107, 148, 125, width, origWidth), 14, width),
      _getClippedImage(_Clipper(135, 64, 156, 66, width, origWidth), 15, width),
      _getClippedImage(_Clipper(133, 66, 156, 78, width, origWidth), 15, width),
      _getClippedImage(_Clipper(126, 78, 156, 86, width, origWidth), 15, width),
      _getClippedImage(_Clipper(122, 86, 149, 97, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(116, 97, 142, 102, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(112, 102, 139, 106, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(111, 106, 138, 126, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(108, 126, 131, 196, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(131, 151, 149, 196, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(149, 137, 155, 187, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(155, 128, 161, 177, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(161, 128, 166, 164, width, origWidth), 15, width),
      _getClippedImage(
          _Clipper(166, 128, 175, 155, width, origWidth), 15, width),
      _getClippedImage(_Clipper(75, 143, 98, 202, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(71, 117, 100, 143, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(78, 101, 100, 117, width, origWidth), 16, width),
      _getClippedImage(_Clipper(82, 89, 107, 101, width, origWidth), 16, width),
      _getClippedImage(_Clipper(84, 80, 118, 89, width, origWidth), 16, width),
      _getClippedImage(_Clipper(84, 72, 122, 80, width, origWidth), 16, width),
      _getClippedImage(_Clipper(90, 66, 127, 72, width, origWidth), 16, width),
      _getClippedImage(_Clipper(99, 62, 132, 66, width, origWidth), 16, width),
      _getClippedImage(_Clipper(104, 60, 136, 62, width, origWidth), 16, width),
      _getClippedImage(_Clipper(109, 44, 146, 60, width, origWidth), 16, width),
      _getClippedImage(
          _Clipper(114, 209, 143, 231, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(143, 206, 147, 225, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(147, 203, 152, 223, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(152, 196, 158, 220, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(158, 187, 163, 217, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(163, 176, 167, 212, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(167, 165, 172, 209, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(172, 157, 179, 203, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(179, 147, 186, 185, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(186, 128, 191, 166, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(191, 117, 199, 157, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(199, 91, 207, 139, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(207, 89, 214, 123, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(214, 89, 222, 118, width, origWidth), 17, width),
      _getClippedImage(
          _Clipper(189, 189, 226, 222, width, origWidth), 18, width),
      _getClippedImage(
          _Clipper(203, 154, 233, 189, width, origWidth), 18, width),
      _getClippedImage(
          _Clipper(209, 142, 237, 154, width, origWidth), 18, width),
      _getClippedImage(
          _Clipper(216, 129, 237, 142, width, origWidth), 18, width),
      _getClippedImage(
          _Clipper(223, 119, 238, 129, width, origWidth), 18, width),
      _getClippedImage(
          _Clipper(226, 111, 241, 119, width, origWidth), 18, width),
      _getClippedImage(
          _Clipper(228, 103, 242, 111, width, origWidth), 18, width),
      _getClippedImage(
          _Clipper(230, 85, 245, 103, width, origWidth), 18, width),
    ]);
  }

  Stack getClippedGoldberg(double width, double origWidth) {
    return Stack(children: <Widget>[
      _getClippedImage(
          _Clipper(449, 53, 644, 602, width, origWidth), 12, width),
      _getClippedImage(_Clipper(0, 0, 500, 500, width, origWidth), 12, width),
    ]);
  }

  Widget _getClippedImage(_Clipper clipper, int holeId, double width) {
    return ClipPath(
      clipper: clipper,
      child: GestureDetector(
        onTap: () {
          HoleDialog dialog = HoleDialog(App.of(context).getLocality(), holeId);
          showDialog(
              context: context, builder: (BuildContext context) => dialog);
        },
        child: Image.asset(
            Data.getHolesPicStrImm(App.of(context).getLocality()),
            width: width),
      ),
    );
  }
}

class _Clipper extends CustomClipper<Path> {
  _Clipper(this.ixs, this.iys, this.ixe, this.iye, this.width, this.origWidth);

  final double ixs;
  final double iys;
  final double ixe;
  final double iye;

  final double width;
  final double origWidth;

  @override
  Path getClip(Size size) {
    double xs = 388 - ixe;
    double xe = 388 - ixs;
    double ys = 643 - iye;
    double ye = 643 - iys;

    xs = ixs / origWidth * width;
    xe = ixe / origWidth * width;
    ys = iys / origWidth * width;
    ye = iye / origWidth * width;

    var path = parseSvgPathData('M' +
        xs.toString() +
        ' ' +
        ys.toString() +
        ' ' +
        xe.toString() +
        ' ' +
        ys.toString() +
        ' ' +
        xe.toString() +
        ' ' +
        ye.toString() +
        ' ' +
        xs.toString() +
        ' ' +
        ye.toString() +
        ' ' +
        xs.toString() +
        ' ' +
        ys.toString());

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}

class _TmpClipper extends CustomClipper<Path> {
  _TmpClipper(
      {required this.fac,
      required this.x0,
      required this.y0,
      required this.w,
      required this.h});

  final double fac;
  final int x0;
  final int y0;
  final int w;
  final int h;

  @override
  Path getClip(Size size) {
    final double xs = x0.toDouble();
    final double ys = y0.toDouble();
    final double xe = xs + w.toDouble();
    final double ye = ys + h.toDouble();

    var path = parseSvgPathData('M' +
        xs.toString() +
        ' ' +
        ys.toString() +
        ' ' +
        xe.toString() +
        ' ' +
        ys.toString() +
        ' ' +
        xe.toString() +
        ' ' +
        ye.toString() +
        ' ' +
        xs.toString() +
        ' ' +
        ye.toString() +
        ' ' +
        xs.toString() +
        ' ' +
        ys.toString());

    return path.shift(Offset.zero);
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
