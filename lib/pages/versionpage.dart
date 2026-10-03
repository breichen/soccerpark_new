import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';
import '../utils/data.dart';

class VersionPage extends StatefulWidget {
  const VersionPage({super.key});

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final double sep = 8;

    return Scaffold(
        appBar: CustomAppBar(context, AppLocalizations.of(context)!.version,
            MenuItemE.VERSION, []),
        body: Stack(children: [
          ListView(children: <Widget>[
            Header(),
            Space(20),
            TitleText(
                text: AppLocalizations.of(context)!.currversion, indent: 16),
            Space(10),
            FloatText("1.3.0")
          ]),
          Column(children: [Spacer(), Footer()])
        ]));
  }
}
