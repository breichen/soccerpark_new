import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double sep = 8;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: CustomAppBar(
            context, AppLocalizations.of(context)!.info, MenuItemE.COUNT, []),
        body: Stack(children: [
          ListView(children: <Widget>[
            Header(),
            FloatText(AppLocalizations.of(context)!.info1),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info2),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info3),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info4),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info5),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info6),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info7),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info8),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info9),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info10),
            Space(sep),
            FloatText(AppLocalizations.of(context)!.info11),
            Space(10),
            Visibility(
                child: Footer(),
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true)
          ]),
          Column(children: [Spacer(), Footer()])
        ]));
  }
}
