import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/share.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double sep = 12;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: CustomAppBar(
            context, AppLocalizations.of(context)!.faqs, MenuItemE.COUNT, []),
        body: Stack(children: [
          ListView(children: <Widget>[
            Header(),
            getTitle(),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question1,
                AppLocalizations.of(context)!.answer1),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question2,
                AppLocalizations.of(context)!.answer2),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question3,
                AppLocalizations.of(context)!.answer3),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question4,
                AppLocalizations.of(context)!.answer4),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question5,
                AppLocalizations.of(context)!.answer5),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question6,
                AppLocalizations.of(context)!.answer6),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question7,
                AppLocalizations.of(context)!.answer7),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question8,
                AppLocalizations.of(context)!.answer8),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question9,
                AppLocalizations.of(context)!.answer9),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question10,
                AppLocalizations.of(context)!.answer10),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question11,
                AppLocalizations.of(context)!.answer11),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question12,
                AppLocalizations.of(context)!.answer12),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question13,
                AppLocalizations.of(context)!.answer13),
            Space(sep),
            getFaq(AppLocalizations.of(context)!.question14,
                AppLocalizations.of(context)!.answer14),
            Space(sep),
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

  Widget getTitle() {
    return Container(
      child: Text(AppLocalizations.of(context)!.faq_title,
          style: GoogleFonts.lato(
              color: maincolor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3)),
      padding: EdgeInsets.fromLTRB(16, 0, 0, 6),
    );
  }

  Widget getFaq(String question, String answer) {
    return Container(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.help, color: maincolor, size: 24),
          SpaceH(4),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                QuestionText(question),
                Space(4),
                FloatText(answer, left: 6)
              ])),
        ]),
      ),
    );
  }
}

class QuestionText extends StatelessWidget {
  final String text;

  QuestionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(6, 0, 14, 0),
        alignment: Alignment.topLeft,
        //padding: itemEdges,
        child: Text(
          text,
          style: GoogleFonts.lato(
              color: maincolor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.3),
        ));
  }
}
