import 'package:flutter/material.dart';
import 'package:soccerpark/widgets/button.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/csv.dart';
import '../utils/pdf.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';
import '../widgets/checkbox.dart';

class ExportDialog extends StatefulWidget {
  ExportDialog();

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  List<String> dates = [];
  List<List<String>> names = [];
  List<bool> checked = [];

  bool error = false;

  @override
  void initState() {
    super.initState();

    Data.getValidDates().then((d) => {
          setState(() {
            dates = d;

            checked = [];
            for (var i = 0; i < dates.length; i++) checked.add(false);
          })
        });

    Data.getAllRoundNames().then((l) => {
          setState(() {
            print("names len " + names.length.toString());
            names = l;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                color: mainred,
                padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Row(children: [
                  TitleText(
                      text: AppLocalizations.of(context)!.export_rounds,
                      indent: 16,
                      color: Colors.white),
                  Spacer(),
                ])),
            Space(10),
            getRows(),
            Space(10),
            Visibility(
                child: Text(AppLocalizations.of(context)!.none_chosen_error,
                    style: GoogleFonts.lato(
                      color: mainred,
                      fontSize: 14,
                    )),
                visible: error,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true),
            Space(5),
            csvButtonRow(),
            pdfButtonRow(),
            Row(children: [
              Spacer(),
              DialogButton(AppLocalizations.of(context)!.cancel, () {
                Navigator.of(context).pop();
              }),
              SpaceH(20)
            ]),
            Space(10),
          ],
        ),
      ),
    );
  }

  Widget csvButtonRow() {
    return Row(children: [
      Spacer(),
      DialogButtonWithIcon(
          AppLocalizations.of(context)!.export_csv, 'assets/pics/csv.png',
          () async {
        List<int> indices = getChosenIndices();
        if (indices.isEmpty) {
          setState(() {
            error = true;
          });
          Future.delayed(
              const Duration(seconds: 2),
              () => {
                    setState(() {
                      error = false;
                    })
                  });
        } else {
          await exportCsv(indices);
          Navigator.of(context).pop();
        }
      }),
      SpaceH(20),
    ]);
  }

  Widget pdfButtonRow() {
    return Row(children: [
      Spacer(),
      DialogButtonWithIcon(AppLocalizations.of(context)!.export_pdf,
          'assets/pics/pdf_icon_2.png', () async {
        List<int> indices = getChosenIndices();
        if (indices.isEmpty) {
          setState(() {
            error = true;
          });
          Future.delayed(
              const Duration(seconds: 2),
              () => {
                    setState(() {
                      error = false;
                    })
                  });
        } else {
          await exportPdf(indices);
          Navigator.of(context).pop();
        }
      }),
      SpaceH(20)
    ]);
  }

  List<int> getChosenIndices() {
    List<int> chosen = [];
    for (var i = 0; i < checked.length; i++) {
      if (checked[i]) chosen.add(i);
    }
    return chosen;
  }

  Widget getRows() {
    List<Widget> rows = [];
    for (var i = 0; i < dates.length; i++) {
      rows.add(getRow(i));
      rows.add(Space(5));
    }
    return Column(children: rows);
  }

  Widget getRow(int i) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpaceH(20),
        getCheckBox(i),
        SpaceH(4),
        Expanded(child: getTextColumn(i)),
        SpaceH(20),
      ],
      mainAxisAlignment: MainAxisAlignment.start,
    );
  }

  Widget getCheckBox(int i) {
    return CustomCheckbox(checked[i], (bool? ch) {
      setState(() {
        checked[i] = ch!;
      });
    });
  }

  Widget getTextColumn(int i) {
    return Column(
        children: [getDateText(i), getNamesText(i)],
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget getDateText(int i) {
    return Text(dates[i],
        style: GoogleFonts.lato(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget getNamesText(int i) {
    if (names.length <= i) {
      return Text("");
    }

    String str = "";
    if (names[i].isEmpty)
      assert(false);
    else
      str = names[i][0];

    for (var j = 1; j < names[i].length; j++) str += ", " + names[i][j];

    return Row(children: [
      Expanded(
          child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
        alignment: Alignment.topLeft,
        child: Text(
          str,
          style: GoogleFonts.lato(color: Colors.black, fontSize: 14),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
      )),
    ]);
  }

  Future<bool> exportPdf(List<int> indices) async {
    if (indices.length == 1)
      await generatePdfSingleRound(context, indices[0] + 1, dates[indices[0]]);
    else {
      await generatePdfMultipleRounds(context, indices, getRandomFilename());
    }
    return true;
  }

  Future<bool> exportCsv(List<int> indices) async {
    if (indices.length == 1) {
      generateCsvSingleRound(
          context,
          dates[indices[0]],
          names[indices[0]],
          await Data.getScoresInRound(indices[0] + 1),
          await Data.getTotalScoresInRound(indices[0] + 1),
          dates[indices[0]]);
    } else {
      List<String> selDates = [];
      List<List<String>> selNames = [];
      for (var i = 0; i < indices.length; i++) selDates.add(dates[indices[i]]);
      for (var i = 0; i < indices.length; i++) selNames.add(names[indices[i]]);

      generateCsvMultipleRounds(
          context,
          selDates,
          selNames,
          await Data.getScoresInRounds(indices),
          await Data.getTotalScoresInRounds(indices),
          getRandomFilename());
    }
    return true;
  }

  String getRandomFilename() {
    var ms = (new DateTime.now()).millisecondsSinceEpoch;
    var s = (ms / 1000).round().toInt();
    return s.toString();
  }
}
