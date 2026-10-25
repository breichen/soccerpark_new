import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../utils/online_highscores.dart';
import './holespage.dart';
import './faqpage.dart';
import './newroundpage.dart';
import './orderspage.dart';
import './rulespage.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/appbar.dart';
import './roundpage.dart';
import './historypage.dart';
import './highscorepage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isCurr = false;
  bool isHist = false;

  /// Laufende Runde: Anzahl Spieler und fertig gespielte Bahnen.
  int currPlayers = 0;
  int currHolesDone = 0;

  GlobalKey _globalKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    checkIs();
  }

  void checkIs() {
    Data.isStarted().then((started) {
      if (!mounted) return;
      setState(() => isCurr = started);
      if (started) loadProgress();
    });
    Data.isHistory().then((hist) {
      if (mounted) setState(() => isHist = hist);
    });
  }

  void loadProgress() {
    Data.getRoundData(0).then((round) {
      var done = 0;
      for (var hole = 0; hole < 18; hole++) {
        if (round.scores.isNotEmpty &&
            round.scores.every((s) => s.length > hole && s[hole] > 0)) {
          done++;
        }
      }
      if (!mounted) return;
      setState(() {
        currPlayers = round.names.length;
        currHolesDone = done;
      });
    });
  }

  void open(Widget page, {bool refresh = false}) {
    final future = Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    if (refresh) future.whenComplete(() => checkIs());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // Neu aufbauen, wenn in den Einstellungen die Anlage gewechselt wird.
    App.localityOf(context);

    return Scaffold(
        appBar: CustomAppBar(
            context, "Soccerpark", MenuItemE.MAIN, [getShareButton()]),
        body: Stack(children: [
          ListView(children: <Widget>[
            RepaintBoundary(
                key: _globalKey,
                child: Container(color: bgcolor, child: Header())),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  if (isCurr) ...[
                    PrimaryMenuButton(
                      icon: Icons.play_arrow_rounded,
                      title: loc.continue_round,
                      subtitle: currPlayers > 0
                          ? loc.round_progress(currPlayers, currHolesDone)
                          : null,
                      onTap: () => open(RoundPage(0), refresh: true),
                    ),
                    Space(8),
                    SecondaryMenuButton(
                      icon: Icons.add,
                      title: loc.newRound,
                      onTap: () => open(NewRoundPage(), refresh: true),
                    ),
                  ] else
                    PrimaryMenuButton(
                      icon: Icons.add,
                      title: loc.newRound,
                      onTap: () => open(NewRoundPage(), refresh: true),
                    ),
                  Space(14),
                  getTiles(loc),
                  Space(14),
                  ContactCard(),
                ])),
            Space(16)
          ])
        ]));
  }

  Widget getTiles(AppLocalizations loc) {
    final hasHighscores = isHist || OnlineHighscores.isConfigured;
    final tiles = [
      MenuTile(
          icon: Icons.show_chart,
          title: loc.history,
          enabled: isHist,
          onTap: () => open(HistoryPage())),
      MenuTile(
          icon: Icons.emoji_events_outlined,
          title: loc.leaderboards,
          enabled: hasHighscores,
          onTap: () => open(HighscorePage())),
      MenuTile(
          icon: Icons.menu_book_outlined,
          title: loc.rules,
          onTap: () => open(RulesPage())),
      MenuTile(
          icon: Icons.flag_outlined,
          title: loc.holes,
          onTap: () => open(HolesPage())),
      MenuTile(
          icon: Icons.assignment_outlined,
          title: loc.orders,
          onTap: () => open(OrdersPage())),
      MenuTile(
          icon: Icons.help_outline,
          title: loc.faqs,
          onTap: () => open(FaqPage())),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      if (i > 0) rows.add(Space(8));
      rows.add(Row(children: [
        Expanded(child: tiles[i]),
        SpaceH(8),
        Expanded(child: i + 1 < tiles.length ? tiles[i + 1] : SizedBox()),
      ]));
    }
    return Column(children: rows);
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

/// Großer grüner Knopf für die wichtigste Aktion.
class PrimaryMenuButton extends StatelessWidget {
  const PrimaryMenuButton(
      {required this.icon,
      required this.title,
      required this.onTap,
      this.subtitle,
      super.key});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: maincolor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  Icon(icon, color: Colors.white, size: 28),
                  SpaceH(10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                        if (subtitle != null)
                          Text(subtitle!,
                              style: GoogleFonts.lato(
                                  color: Color(0xFFCFE5CF), fontSize: 13)),
                      ])),
                  Icon(Icons.chevron_right, color: Colors.white),
                ]))));
  }
}

/// Umrandeter Knopf für die zweitwichtigste Aktion.
class SecondaryMenuButton extends StatelessWidget {
  const SecondaryMenuButton(
      {required this.icon,
      required this.title,
      required this.onTap,
      super.key});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: maincolor)),
        child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  Icon(icon, color: maincolor, size: 22),
                  SpaceH(10),
                  Text(title,
                      style: GoogleFonts.lato(
                          color: maincolor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ]))));
  }
}

/// Kachel im Menüraster: Icon auf hellgrüner Fläche und Titel.
class MenuTile extends StatelessWidget {
  const MenuTile(
      {required this.icon,
      required this.title,
      required this.onTap,
      this.enabled = true,
      super.key});

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? maincolor : Colors.grey[400]!;
    return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!)),
        child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? onTap : null,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                              color: enabled
                                  ? dropdownChipColor
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(icon, color: fg, size: 20)),
                      Space(8),
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                              color: enabled
                                  ? Colors.black87
                                  : Colors.grey[400],
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ]))));
  }
}
