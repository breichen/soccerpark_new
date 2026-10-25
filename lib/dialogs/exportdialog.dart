import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../utils/data.dart';
import '../utils/csv.dart';
import '../utils/pdf.dart';
import '../widgets/appdialog.dart';

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
    final l = AppLocalizations.of(context)!;
    return AppDialog(
        title: l.export_rounds,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12)),
              child: getRows()),
          if (error) ...[
            SizedBox(height: 8),
            Text(l.none_chosen_error,
                style: GoogleFonts.lato(color: mainred, fontSize: 14)),
          ],
        ]),
        actions: [
          dialogSecondaryButton(l.export_csv, () => run(exportCsv),
              icon: Icons.table_chart_outlined),
          dialogPrimaryButton(l.export_pdf, () => run(exportPdf),
              icon: Icons.picture_as_pdf_outlined),
        ]);
  }

  /// Export starten, wenn mindestens eine Runde gewählt ist.
  Future<void> run(Future<bool> Function(List<int>) export) async {
    final indices = getChosenIndices();
    if (indices.isEmpty) {
      setState(() => error = true);
      return;
    }
    await export(indices);
    if (mounted) Navigator.of(context).pop();
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
      if (i > 0) {
        rows.add(Divider(height: 1, thickness: 1, color: Colors.grey[200]));
      }
      rows.add(getRow(i));
    }
    return Column(children: rows);
  }

  Widget getRow(int i) {
    return Material(
        color: checked[i] ? Color(0xFFF1F7F1) : Colors.white,
        child: InkWell(
            onTap: () => setState(() {
                  checked[i] = !checked[i];
                  error = false;
                }),
            child: Padding(
                padding: EdgeInsets.fromLTRB(4, 6, 12, 6),
                child: Row(children: [
                  Checkbox(
                      value: checked[i],
                      activeColor: maincolor,
                      onChanged: (ch) => setState(() {
                            checked[i] = ch ?? false;
                            error = false;
                          })),
                  Expanded(child: getTextColumn(i)),
                ]))));
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
            color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold));
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
          style: GoogleFonts.lato(color: Colors.grey[700], fontSize: 13),
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
