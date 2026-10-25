import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../utils/online_highscores.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/space.dart';
import '../widgets/dropdown.dart';

/// Bestenlisten: Highscores, persönliche Rekorde, Durchschnitt und die
/// monatliche Online-Bestenliste der gewählten Anlage.
class HighscorePage extends StatefulWidget {
  const HighscorePage({super.key});

  @override
  State<HighscorePage> createState() => _HighscorePageState();
}

class _HighscorePageState extends State<HighscorePage> {
  GlobalKey _globalKey = new GlobalKey();

  List<NamedHighscore> highscores = [];
  List<Average> averages = [];

  int highscoreType = 0;
  int highscoreDetail = 0;

  // Online-Bestenliste (highscoreType == onlineType)
  static const int onlineType = 3;
  List<OnlineHighscore> onlineHighscores = [];
  List<String> onlineMonths = [];
  int onlineMonthIdx = 0;
  bool onlineLoading = false;
  bool onlineError = false;
  int? expandedOnlineId;
  int? expandedLocalIdx;

  @override
  void initState() {
    super.initState();
    setListData();
  }

  @override
  Widget build(BuildContext context) {
    List<String> holes = [AppLocalizations.of(context)!.total];
    for (var i = 1; i <= 18; i++)
      holes.add(AppLocalizations.of(context)!.hole + " " + i.toString());
    List<String> highscoreTypes = [
      "Highscores",
      AppLocalizations.of(context)!.personal_records,
      AppLocalizations.of(context)!.average
    ];
    if (OnlineHighscores.isConfigured) {
      highscoreTypes.add(AppLocalizations.of(context)!.online_highscores);
    }
    final loc = App.of(context).getLocality();

    return Scaffold(
        appBar: CustomAppBar(context,
            AppLocalizations.of(context)!.leaderboards, MenuItemE.COUNT, [
          getShareButton(),
        ]),
        body: Stack(children: [
          RepaintBoundary(
              key: _globalKey,
              child: Container(
                  color: bgcolor,
                  child: ListView(children: <Widget>[
                    Space(16),
                    Center(
                        child: ConstrainedBox(
                            constraints:
                                BoxConstraints(maxHeight: 90, maxWidth: 260),
                            child: Image.asset(
                                Data.getLocalityImageString(loc),
                                fit: BoxFit.contain))),
                    Space(20),
                    getListDropdown(highscoreTypes, holes),
                    Space(10),
                    getList(),
                    Space(10),
                    Visibility(
                        child: Footer(),
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true)
                  ]))),
          Column(children: [Spacer(), Footer()])
        ]));
  }

  void setListData() {
    expandedLocalIdx = null;
    if (highscoreType == onlineType) {
      loadOnlineHighscores();
      return;
    }
    if (highscoreType != 2) {
      loadHighscores().then((d) {
        if (mounted) setState(() => highscores = d);
      });
    } else {
      loadAverages().then((d) {
        if (mounted) setState(() => averages = d);
      });
    }
  }

  Future<List<NamedHighscore>> loadHighscores() async {
    if (highscoreType == 0) {
      return Data.getOverallHighscores(highscoreDetail);
    }
    return Data.getPersonalHighscores(highscoreDetail);
  }

  Future<void> loadOnlineHighscores() async {
    final loc = App.of(context).getLocality();
    setState(() {
      onlineLoading = true;
      onlineError = false;
      expandedOnlineId = null;
    });
    try {
      if (onlineMonths.isEmpty) {
        onlineMonths = await OnlineHighscores.fetchMonths(loc);
        onlineMonthIdx = 0;
      }
      final month = onlineMonths[onlineMonthIdx];
      final list = await OnlineHighscores.fetch(loc, month);
      if (!mounted) return;
      setState(() {
        onlineHighscores = list;
        onlineLoading = false;
      });
    } catch (e) {
      debugPrint('Loading online highscores failed: $e');
      if (!mounted) return;
      setState(() {
        onlineHighscores = [];
        onlineLoading = false;
        onlineError = true;
      });
    }
  }

  Future<List<Average>> loadAverages() async {
    return Data.getPersonalAverages(highscoreDetail);
  }

  /// Chips nebeneinander; bricht auf schmalen Bildschirmen um.
  Widget dropdownRow(List<Widget> children) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(spacing: 10, runSpacing: 8, children: children));
  }

  Widget getListDropdown(List<String> highscoreTypes, List<String> holes) {
    return dropdownRow([
      CustomDropdownButton(highscoreTypes, highscoreType, (int v) {
        setState(() {
          highscoreType = v;
          setListData();
        });
      }, icon: Icons.emoji_events),
      highscoreType == onlineType
          ? getOnlineMonthDropdown()
          : CustomDropdownButton(holes, highscoreDetail, (int v) {
              setState(
                () {
                  highscoreDetail = v;
                  setListData();
                },
              );
            }, icon: Icons.flag)
    ]);
  }

  Widget getOnlineMonthDropdown() {
    final months =
        onlineMonths.isEmpty ? [OnlineHighscores.currentMonth()] : onlineMonths;
    final lang = Localizations.localeOf(context).languageCode;
    return CustomDropdownButton(
        months.map((m) => OnlineHighscores.monthLabel(m, lang)).toList(),
        onlineMonths.isEmpty ? 0 : onlineMonthIdx, (int v) {
      if (onlineMonths.isEmpty) return;
      setState(() {
        onlineMonthIdx = v;
      });
      loadOnlineHighscores();
    }, icon: Icons.calendar_month);
  }

  Widget getList() {
    if (highscoreType == onlineType) return getOnlineList();
    final empty = highscoreType == 2 ? averages.isEmpty : highscores.isEmpty;
    if (empty) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(AppLocalizations.of(context)!.no_entries,
              style: styleHist));
    }
    if (highscoreType == 2) return getAverageList();
    return getHighscoreList();
  }

  Widget getHighscoreList() {
    final pars = Data.getPars(App.of(context).getLocality());
    final List<Widget> cards = [];
    for (var i = 0; i < highscores.length; i++) {
      final entry = highscores[i];
      // Lochdetails gibt es nur beim Gesamt-Highscore und nur für Runden,
      // die nach der Erweiterung gespeichert wurden.
      final holes = highscoreDetail == 0 ? entry.holes : null;
      final expanded = holes != null && expandedLocalIdx == i;
      cards.add(Card(
          color: Colors.grey[300],
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
              onTap: holes == null
                  ? null
                  : () => setState(() {
                        expandedLocalIdx = expanded ? null : i;
                      }),
              child: Column(children: [
                Space(4),
                Row(children: [
                  SpaceH(10),
                  Expanded(
                      child: Text(entry.name,
                          style: styleBoldHist,
                          overflow: TextOverflow.ellipsis)),
                  Icon(Icons.sports_soccer, size: 16, color: Colors.black),
                  SpaceH(4),
                  Text(
                    entry.score.toString(),
                    style: styleBoldHist,
                  ),
                  SpaceH(10),
                ]),
                Space(4),
                Row(children: [
                  SpaceH(10),
                  Icon(Icons.date_range, size: 16, color: Colors.black),
                  SpaceH(4),
                  Text(entry.date, style: styleHist),
                  Spacer(),
                  if (holes != null)
                    Icon(expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20, color: Colors.black),
                  SpaceH(8),
                ]),
                if (expanded && holes != null) getHoleTable(holes, pars),
                Space(4),
              ]))));
    }
    return Column(children: cards);
  }

  Widget getOnlineList() {
    if (onlineLoading) {
      return Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()));
    }
    if (onlineError || onlineHighscores.isEmpty) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
              onlineError
                  ? AppLocalizations.of(context)!.online_hs_load_error
                  : AppLocalizations.of(context)!.online_hs_empty,
              style: styleHist));
    }

    final ranks = OnlineHighscores.displayRanks(onlineHighscores);
    final pars = Data.getPars(App.of(context).getLocality());
    final dateFormat = DateFormat('dd.MM.yyyy');
    final List<Widget> cards = [];
    for (var i = 0; i < onlineHighscores.length; i++) {
      final entry = onlineHighscores[i];
      final expanded = expandedOnlineId == entry.id;
      cards.add(Card(
          color: Colors.grey[300],
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
              onTap: () => setState(() {
                    expandedOnlineId = expanded ? null : entry.id;
                  }),
              child: Column(children: [
                Space(4),
                Row(children: [
                  SpaceH(10),
                  SizedBox(
                      width: 28,
                      child: Text(ranks[i].toString() + ".",
                          style: styleBoldHist)),
                  Expanded(
                      child: Text(entry.name,
                          style: styleBoldHist,
                          overflow: TextOverflow.ellipsis)),
                  Icon(Icons.sports_soccer, size: 16, color: Colors.black),
                  SpaceH(4),
                  Text(entry.total.toString(), style: styleBoldHist),
                  SpaceH(10),
                ]),
                Space(4),
                Row(children: [
                  SpaceH(38),
                  Icon(Icons.date_range, size: 16, color: Colors.black),
                  SpaceH(4),
                  Text(dateFormat.format(entry.createdAt), style: styleHist),
                  Spacer(),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more,
                      size: 20, color: Colors.black),
                  SpaceH(8),
                ]),
                if (expanded) getHoleTable(entry.holes, pars),
                Space(4),
              ]))));
    }
    return Column(children: cards);
  }

  /// Schläge pro Loch in zwei Zeilen à 9 Löcher; unter Par grün,
  /// über Par rot.
  Widget getHoleTable(List<int> holes, List<int> pars) {
    final styleHole = GoogleFonts.lato(color: Colors.grey[700], fontSize: 11);
    TextStyle styleScore(int hole) {
      final diff = holes[hole] - pars[hole];
      return GoogleFonts.lato(
          color: diff < 0 ? maincolor : (diff > 0 ? mainred : Colors.black),
          fontSize: 14,
          fontWeight: FontWeight.bold);
    }

    TableRow numbers(int start) => TableRow(
        children: List.generate(
            9,
            (i) => Center(
                child: Text((start + i + 1).toString(), style: styleHole))));
    TableRow scores(int start) => TableRow(
        children: List.generate(
            9,
            (i) => Padding(
                padding: EdgeInsets.only(top: 2, bottom: 6),
                child: Center(
                    child: Text(holes[start + i].toString(),
                        style: styleScore(start + i))))));

    return Padding(
        padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: Table(children: [
          numbers(0),
          scores(0),
          numbers(9),
          scores(9),
        ]));
  }

  Widget getAverageList() {
    return Column(
        children: averages
            .map((entry) => Card(
                color: Colors.grey[300],
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  Space(4),
                  Row(children: [
                    SpaceH(10),
                    Text(entry.name, style: styleBoldHist),
                    Spacer(),
                    Icon(Icons.sports_soccer, size: 16, color: Colors.black),
                    SpaceH(4),
                    Text(
                      entry.avg.toStringAsFixed(2),
                      style: styleBoldHist,
                    ),
                    SpaceH(10),
                  ]),
                  Space(4),
                  Row(children: [
                    SpaceH(10),
                    Icon(Icons.timeline, size: 16, color: Colors.black),
                    SpaceH(4),
                    Text(
                        entry.games.toString() +
                            " " +
                            (entry.games == 1
                                ? AppLocalizations.of(context)!.game
                                : AppLocalizations.of(context)!.games),
                        style: styleHist)
                  ]),
                  Space(4),
                ])))
            .toList());
  }

  TextStyle styleBoldHist = GoogleFonts.lato(
      color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);
  TextStyle styleHist = GoogleFonts.lato(color: Colors.black, fontSize: 14);

  Widget getShareButton() {
    return ShareButton(() {
      share(
          _globalKey,
          AppLocalizations.of(context)!.share_text_history +
              " " +
              Data.getLocalityStringImm(App.of(context).getLocality()) +
              AppLocalizations.of(context)!.share_text2 +
              Data.getWebsiteStringImm(context, App.of(context).getLocality()));
    });
  }
}
