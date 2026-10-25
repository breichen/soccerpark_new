import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/appbar.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  /// Geöffnete Frage (nur eine gleichzeitig), null = alle zu.
  int? openIndex;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final faqs = [
      [loc.question1, loc.answer1],
      [loc.question2, loc.answer2],
      [loc.question3, loc.answer3],
      [loc.question4, loc.answer4],
      [loc.question5, loc.answer5],
      [loc.question6, loc.answer6],
      [loc.question7, loc.answer7],
      [loc.question8, loc.answer8],
      [loc.question9, loc.answer9],
      [loc.question10, loc.answer10],
      [loc.question11, loc.answer11],
      [loc.question12, loc.answer12],
      [loc.question13, loc.answer13],
      [loc.question14, loc.answer14],
    ];

    final items = <Widget>[];
    for (var i = 0; i < faqs.length; i++) {
      if (i > 0) {
        items.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      items.add(getFaq(i, faqs[i][0], faqs[i][1]));
    }

    return Scaffold(
        appBar: CustomAppBar(context, loc.faqs, MenuItemE.COUNT, []),
        body: Stack(children: [
          ListView(children: <Widget>[
            Header(),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.faq_title,
                          style: GoogleFonts.lato(
                              color: maincolor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.3)),
                      Space(10),
                      Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(children: items)),
                    ])),
            Space(16)
          ])
        ]));
  }

  /// Eine Frage; Antippen klappt die Antwort auf bzw. zu.
  Widget getFaq(int index, String question, String answer) {
    final open = openIndex == index;
    return Material(
        color: Colors.white,
        child: InkWell(
            onTap: () => setState(() => openIndex = open ? null : index),
            child: Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                            child: Text(question,
                                style: GoogleFonts.lato(
                                    color: open ? maincolor : Colors.black87,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3))),
                        SpaceH(8),
                        Icon(open ? Icons.expand_less : Icons.expand_more,
                            color: open ? maincolor : Colors.grey[500]),
                      ]),
                      AnimatedSize(
                          duration: Duration(milliseconds: 180),
                          alignment: Alignment.topCenter,
                          child: open
                              ? Padding(
                                  padding: EdgeInsets.only(top: 8, right: 24),
                                  child: Text(answer,
                                      style: GoogleFonts.lato(
                                          color: Colors.grey[800],
                                          fontSize: 15,
                                          height: 1.4)))
                              : SizedBox(width: double.infinity)),
                    ]))));
  }
}
