import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../widgets/appbar.dart';
import '../widgets/dropdown.dart' show dropdownChipColor;
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Wichtige Hinweise (Haftung, Zutritt) – Wortlaut unverändert.
    final important = [loc.orderA1, loc.orderA2, loc.orderA3, loc.orderA4];

    // Weitere Regeln mit passendem Icon.
    final rules = <MapEntry<IconData, String>>[
      MapEntry(Icons.groups_outlined, loc.order3),
      MapEntry(Icons.directions_run, loc.order4),
      MapEntry(Icons.delete_outline, loc.order5),
      MapEntry(Icons.pets, loc.order6),
      MapEntry(Icons.door_front_door_outlined, loc.order8),
      MapEntry(Icons.volume_off_outlined, loc.order9),
      MapEntry(Icons.family_restroom, loc.order10),
      MapEntry(Icons.child_care, loc.order11),
    ];

    return Scaffold(
        appBar: CustomAppBar(context, loc.orders, MenuItemE.COUNT, []),
        body: Stack(children: [
          ListView(children: <Widget>[
            Header(),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ImportantCard(loc.order_important, important),
                      Space(20),
                      Text(loc.order_notes,
                          style: GoogleFonts.lato(
                              color: maincolor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      Space(8),
                      RuleList(rules),
                    ])),
            Space(16),
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

/// Orange hinterlegte Karte für die wichtigsten Hinweise.
class ImportantCard extends StatelessWidget {
  const ImportantCard(this.title, this.items, {super.key});

  final String title;
  final List<String> items;

  static const Color _bg = Color(0xFFFFF4E5);
  static const Color _border = Color(0xFFF5C98A);
  static const Color _title = Color(0xFF8A4B00);
  static const Color _text = Color(0xFF5C3300);

  @override
  Widget build(BuildContext context) {
    final textStyle =
        GoogleFonts.lato(color: _text, fontSize: 15, height: 1.35);
    return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
            color: _bg,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.warning_amber_rounded, color: _title, size: 22),
            SpaceH(6),
            Text(title,
                style: GoogleFonts.lato(
                    color: _title, fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          for (final item in items) ...[
            Space(6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("•  ", style: textStyle),
              Expanded(child: Text(item, style: textStyle)),
            ]),
          ],
        ]));
  }
}

/// Weiße Liste mit Trennlinien; jede Regel mit eigenem Icon.
class RuleList extends StatelessWidget {
  const RuleList(this.rules, {super.key});

  final List<MapEntry<IconData, String>> rules;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < rules.length; i++) {
      if (i > 0) {
        children.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      children.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(children: [
            Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: dropdownChipColor,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(rules[i].key, color: maincolor, size: 20)),
            SpaceH(12),
            Expanded(
                child: Text(rules[i].value,
                    style: GoogleFonts.lato(
                        color: Colors.black87, fontSize: 15, height: 1.35))),
          ])));
    }
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: children));
  }
}
