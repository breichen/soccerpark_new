import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/appbar.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/header.dart';
import '../widgets/space.dart';
import './rules_video.dart';

/// Eine Spielregel: kurze Überschrift und Originaltext.
class RuleItem {
  RuleItem(this.title, this.text, {this.hint});

  final String title;
  final String text;

  /// Optionaler Merkkasten unter dem Text.
  final String? hint;
}

/// Ein Hinweis zur Anlage: Icon, Überschrift und Originaltext.
class InfoItem {
  InfoItem(this.icon, this.title, this.text);

  final IconData icon;
  final String title;
  final String text;
}

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  /// Aufgeklappter Hinweis unter "Gut zu wissen" (nur einer gleichzeitig).
  int? openInfo;

  String getVideoId() {
    var loc = App.of(context).getLocality();
    if (loc == Locality.WAGRAIN) return 'WHompKs4410';
    return 'Xi9x7aQrEp8';
  }

  @override
  Widget build(BuildContext context) {
    return RulesVideoBuilder(
        videoId: getVideoId(),
        builder: (context, player) {
          final loc = AppLocalizations.of(context)!;
          final locality = App.of(context).getLocality();
          final rules = getRules(loc, locality);
          final infos = getInfos(loc, locality);

          return Scaffold(
              appBar: CustomAppBar(context, loc.rules, MenuItemE.COUNT, []),
              body: ListView(children: <Widget>[
                Header(),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Video gibt es (noch) nicht für Goldberg.
                          if (locality != Locality.GOLDBERG) ...[
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: player),
                            Space(20),
                          ],
                          Text(getTitleText(loc, locality),
                              style: GoogleFonts.lato(
                                  color: maincolor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3)),
                          Space(16),
                          sectionTitle(loc.rules_section_game),
                          Space(8),
                          getRuleList(rules),
                          if (infos.isNotEmpty) ...[
                            Space(20),
                            sectionTitle(loc.rules_section_info),
                            Space(8),
                            getInfoList(infos),
                          ],
                        ])),
                Space(24),
              ]));
        });
  }

  String getTitleText(AppLocalizations loc, Locality locality) {
    if (locality == Locality.SALZBURG) return loc.rules_title;
    if (locality == Locality.WAGRAIN) return loc.rules_wagrain_title;
    return loc.rules_goldberg_title;
  }

  /// Spielregeln je Anlage. Für Goldberg nur die allgemeinen Regeln, die
  /// nicht von Ausstattung oder Bahnen einer bestimmten Anlage abhängen.
  List<RuleItem> getRules(AppLocalizations loc, Locality locality) {
    final r1 = RuleItem(loc.rules_t1, loc.rules1);
    final r2 = RuleItem(loc.rules_t2, loc.rules2);
    final r3 = RuleItem(loc.rules_t3, loc.rules3);
    final r4 = RuleItem(loc.rules_t4, loc.rules4);
    final r5 = RuleItem(loc.rules_t5, loc.rules5);
    final r6 = RuleItem(loc.rules_t6, loc.rules6);
    final r7 = RuleItem(loc.rules_t7, loc.rules7);
    final r8 = RuleItem(loc.rules_t8, loc.rules8, hint: loc.rules_max_hint);
    final r8wag =
        RuleItem(loc.rules_t8, loc.rules_wagrain_8, hint: loc.rules_max_hint);
    final r9 = RuleItem(loc.rules_t9, loc.rules9);

    if (locality == Locality.SALZBURG) {
      return [r1, r2, r3, r4, r5, r6, r7, r8, r9];
    }
    if (locality == Locality.WAGRAIN) {
      return [r1, r2, r3, r4, r5, r6, r7, r8wag];
    }
    return [r1, r5, r6, r7, r8];
  }

  /// Hinweise zur Anlage ("Gut zu wissen"); für Goldberg noch keine.
  List<InfoItem> getInfos(AppLocalizations loc, Locality locality) {
    if (locality == Locality.SALZBURG) {
      return [
        InfoItem(Icons.wc, loc.rules_t10, loc.rules10),
        InfoItem(Icons.volunteer_activism_outlined, loc.rules_t11, loc.rules11),
        InfoItem(Icons.directions_run, loc.rules_t12, loc.rules12),
        InfoItem(Icons.cake_outlined, loc.rules_t13, loc.rules13),
        InfoItem(Icons.sports_soccer, loc.rules_t14, loc.rules14),
        InfoItem(Icons.icecream_outlined, loc.rules_t15, loc.rules15),
        InfoItem(Icons.wifi, loc.rules_t16, loc.rules16),
        InfoItem(Icons.card_giftcard, loc.rules_t17, loc.rules17),
      ];
    }
    if (locality == Locality.WAGRAIN) {
      return [
        InfoItem(Icons.wc, loc.rules_t10, loc.rules_wagrain_10),
        InfoItem(Icons.volunteer_activism_outlined, loc.rules_t11, loc.rules11),
        InfoItem(Icons.directions_run, loc.rules_t12, loc.rules12),
        InfoItem(Icons.sports_soccer, loc.rules_t14, loc.rules14),
        InfoItem(Icons.icecream_outlined, loc.rules_t15, loc.rules15),
        InfoItem(Icons.wifi, loc.rules_t16, loc.rules16),
        InfoItem(Icons.card_giftcard, loc.rules_t17, loc.rules17),
      ];
    }
    return [];
  }

  Widget sectionTitle(String text) {
    return Text(text,
        style: GoogleFonts.lato(
            color: maincolor, fontSize: 17, fontWeight: FontWeight.bold));
  }

  BoxDecoration cardDecoration() => BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(12));

  /// Nummerierte Spielregeln, immer aufgeklappt.
  Widget getRuleList(List<RuleItem> rules) {
    final children = <Widget>[];
    for (var i = 0; i < rules.length; i++) {
      if (i > 0) {
        children.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      final rule = rules[i];
      children.add(Padding(
          padding: EdgeInsets.fromLTRB(10, 12, 12, 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: maincolor, shape: BoxShape.circle),
                child: Text((i + 1).toString(),
                    style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold))),
            SpaceH(10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(rule.title,
                      style: GoogleFonts.lato(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.3)),
                  Space(4),
                  Text(rule.text.trim(),
                      style: GoogleFonts.lato(
                          color: Colors.grey[800], fontSize: 15, height: 1.4)),
                  if (rule.hint != null) ...[
                    Space(8),
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: dropdownChipColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(rule.hint!,
                            style: GoogleFonts.lato(
                                color: maincolor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold))),
                  ],
                ])),
          ])));
    }
    return Container(
        decoration: cardDecoration(), child: Column(children: children));
  }

  /// Hinweise zur Anlage mit Icon, zum Aufklappen.
  Widget getInfoList(List<InfoItem> infos) {
    final children = <Widget>[];
    for (var i = 0; i < infos.length; i++) {
      if (i > 0) {
        children.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      final info = infos[i];
      final open = openInfo == i;
      children.add(Material(
          color: Colors.white,
          child: InkWell(
              onTap: () => setState(() => openInfo = open ? null : i),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 8, 10),
                  child: Column(children: [
                    Row(children: [
                      Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                              color: dropdownChipColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(info.icon, color: maincolor, size: 20)),
                      SpaceH(12),
                      Expanded(
                          child: Text(info.title,
                              style: GoogleFonts.lato(
                                  color: open ? maincolor : Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold))),
                      Icon(open ? Icons.expand_less : Icons.expand_more,
                          color: open ? maincolor : Colors.grey[500]),
                    ]),
                    AnimatedSize(
                        duration: Duration(milliseconds: 180),
                        alignment: Alignment.topCenter,
                        child: open
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(46, 8, 24, 0),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(info.text.trim(),
                                        style: GoogleFonts.lato(
                                            color: Colors.grey[800],
                                            fontSize: 15,
                                            height: 1.4))))
                            : SizedBox(width: double.infinity)),
                  ])))));
    }
    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: cardDecoration(),
        child: Column(children: children));
  }
}
