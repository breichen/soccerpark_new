import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import './holespage.dart';
import './faqpage.dart';
import './newroundpage.dart';
import './orderspage.dart';
import './rulespage.dart';
import '../widgets/button.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/appbar.dart';
import './roundpage.dart';
import './historypage.dart';
import './highscorepage.dart';
import '../utils/online_highscores.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isCurr = false;
  bool isHist = false;
  GlobalKey _globalKey = new GlobalKey();

  @override
  void initState() {
    super.initState();

    Data.isStarted().then((started) => {
          setState(() {
            isCurr = started;
          })
        });
    print("isCurr " + isCurr.toString());
    Data.isHistory().then((hist) => {
          setState(() {
            isHist = hist;
          })
        });
    print("isHist " + isHist.toString());
  }

  void checkIs() {
    Data.isStarted().then((started) => {
          setState(() {
            isCurr = started;
          }),
          print("started " + started.toString())
        });
    print("isCurr " + isCurr.toString());
    Data.isHistory().then((hist) => {
          setState(() {
            isHist = hist;
          })
        });
    print("isHist " + isHist.toString());
  }

  @override
  Widget build(BuildContext context) {
    double buttonSep = 2;
    print("build");

    return Scaffold(
        appBar: CustomAppBar(
            context, "Soccerpark", MenuItemE.MAIN, [getShareButton()]),
        body: Stack(children: [
          ListView(children: <Widget>[
            RepaintBoundary(
                key: _globalKey,
                child: Container(color: bgcolor, child: Header())),
            Space(20),
            FullWidthButton(AppLocalizations.of(context)!.newRound, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewRoundPage()),
              ).whenComplete(() => checkIs());
            }),
            Space(buttonSep),
            FullWidthButton(AppLocalizations.of(context)!.currRound, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoundPage(0)),
              ).whenComplete(() => checkIs());
            }, disable: !isCurr),
            Space(buttonSep),
            FullWidthButton(AppLocalizations.of(context)!.history, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            }, disable: !isHist),
            Space(buttonSep),
            FullWidthButton(AppLocalizations.of(context)!.leaderboards, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HighscorePage()),
              );
            }, disable: !isHist && !OnlineHighscores.isConfigured),
            /*Space(buttonSep),
            FullWidthButton(AppLocalizations.of(context)!.info, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoPage()),
              );
            }),*/
            Space(buttonSep),
            FullWidthButton(AppLocalizations.of(context)!.rules, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RulesPage()),
              );
            }),
            Space(buttonSep),
            FullWidthButton(AppLocalizations.of(context)!.holes, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HolesPage()),
              );
            }),
            Space(buttonSep),
            FullWidthButton(AppLocalizations.of(context)!.orders, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersPage()),
              );
            }),
            Space(buttonSep),
            FullWidthButton(AppLocalizations.of(context)!.faqs, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FaqPage()),
              );
            }),
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

  Widget getShareButton() {
    return ShareButton(() {
      share(
          _globalKey,
          AppLocalizations.of(context)!.share_text_main +
              " " +
              Data.getLocalityStringImm(App.of(context).getLocality()) +
              AppLocalizations.of(context)!.share_text2 +
              Data.getWebsiteStringImm(context, App.of(context).getLocality()));
    });
  }
}
