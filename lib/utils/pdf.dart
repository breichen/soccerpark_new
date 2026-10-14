import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../main.dart';
import './data.dart';
import './export.dart';

double pdfLinewidth = 1;
double pdfDlinewidth = 2;
double pdfHoleWidth = 70;
double pdfParwidth = 40;
double pdfTableFontsize = 17;
double pdfvpad = 2;
double pdfhpad = 5;
double footerSep = 8;
double pdfSummaryWidth = 120;

Future<bool> generatePdfSingleRound(
    BuildContext context, int round, String filename) async {
  pw.Document doc = await createPdfSingleRound(context, round);
  if (!context.mounted) return false;
  return savePdf(context, doc, filename);
}

// ATTENTION: Rounds have to be incremented by 1!
Future<bool> generatePdfMultipleRounds(BuildContext context,
    List<int> roundsToBeIncremented, String filename) async {
  pw.Document doc =
      await createPdfMultipleRounds(context, roundsToBeIncremented);
  if (!context.mounted) return false;
  return savePdf(context, doc, filename);
}

Future<pw.Container> getPdfHeaderLogo(BuildContext context) async {
  pw.MemoryImage img = pw.MemoryImage(
    (await rootBundle
            .load(Data.getLocalityImageString(App.of(context).getLocality())))
        .buffer
        .asUint8List(),
  );

  return pw.Container(
    width: 200,
    child: pw.Image(img),
  );
}

Future<pw.Row> getPdfHeader(BuildContext context) async {
  pw.TextStyle style = await pdfTextStyle();

  return pw.Row(children: [
    pw.Spacer(),
    await getPdfHeaderLogo(context),
    pw.Spacer(),
    pw.Column(children: [
      pw.Text(
          "Soccerpark " +
              Data.getLocalityStringImm(App.of(context).getLocality()),
          style: style),
      pw.Text(Data.getAddress1StringImm(context, App.of(context).getLocality()),
          style: style),
      pw.Text(Data.getAddress2StringImm(context, App.of(context).getLocality()),
          style: style),
      pw.Text(Data.getWebsiteStringImm(context, App.of(context).getLocality()),
          style: style)
    ], crossAxisAlignment: pw.CrossAxisAlignment.start),
    pw.Spacer()
  ]);
}

Future<pw.Widget> pdfFooterColumn(BuildContext context) async {
  return pw.Column(children: [pw.Spacer(), await pdfFooter(context)]);
}

Future<pw.Widget> pdfFooter(BuildContext context) async {
  Locality loc = App.of(context).getLocality();
  pw.TextStyle style = await pdfFooterTextStyle();

  pw.MemoryImage circle = pw.MemoryImage(
    (await rootBundle.load('assets/pics/circle.png')).buffer.asUint8List(),
  );

  pw.Row first = pw.Row(children: [
    pw.Spacer(),
    pw.Text("Soccerpark " + Data.getLocalityStringImm(loc), style: style),
    pdfSpaceH(footerSep),
    pw.Image(circle, height: 4),
    pdfSpaceH(footerSep),
    pw.Text(getLocation(context, loc), style: style),
    pw.Spacer()
  ]);
  pw.Row second = pw.Row(children: [
    pw.Spacer(),
    pdfSpaceH(footerSep),
    pw.Text(getPhone(context, loc), style: style),
    pdfSpaceH(footerSep),
    pw.Image(circle, height: 4),
    pdfSpaceH(footerSep),
    pw.Text(getHome(context, loc), style: style),
    pdfSpaceH(footerSep),
    pw.Image(circle, height: 4),
    pdfSpaceH(footerSep),
    pw.Text(getMail(context, loc), style: style),
    pw.Spacer()
  ]);

  return pw.Column(children: [first, second]);
}

String getLocation(BuildContext context, Locality loc) {
  if (loc == Locality.SALZBURG) return AppLocalizations.of(context)!.location;
  if (loc == Locality.WAGRAIN)
    return AppLocalizations.of(context)!.location_wagrain;
  return AppLocalizations.of(context)!.location_goldberg;
}

String getPhone(BuildContext context, Locality loc) {
  if (loc == Locality.SALZBURG) return AppLocalizations.of(context)!.phone;
  if (loc == Locality.WAGRAIN)
    return AppLocalizations.of(context)!.phone_wagrain;
  return AppLocalizations.of(context)!.phone_goldberg;
}

String getHome(BuildContext context, Locality loc) {
  if (loc == Locality.SALZBURG) return AppLocalizations.of(context)!.home;
  if (loc == Locality.WAGRAIN)
    return AppLocalizations.of(context)!.home_wagrain;
  return AppLocalizations.of(context)!.home_goldberg;
}

String getMail(BuildContext context, Locality loc) {
  if (loc == Locality.SALZBURG) return AppLocalizations.of(context)!.mail;
  if (loc == Locality.WAGRAIN)
    return AppLocalizations.of(context)!.mail_wagrain;
  return AppLocalizations.of(context)!.mail_goldberg;
}

Future<pw.Column> pdfRoundTable(BuildContext context, int round) async {
  List<String> names = await Data.getNamesInRound(round);
  List<List<int>> scores = await Data.getScoresInRound(round);
  List<int> totalScores = await Data.getTotalScoresInRound(round);

  List<pw.Widget> rows = [
    pdfSpace(10),
    await getDateRow(context, round),
    pdfSpace(10),
    await pdfHeaderRow(context, names)
  ];
  for (var idx = 1; idx <= 18; idx++)
    rows.add(await pdfTableRow(context, idx, scores));

  rows.add(await pdfLastRow(context, totalScores));
  rows.add(pdfSpace(10));

  return pw.Column(children: rows);
}

/// Splits "dd.mm.yyyy hh:mm" into [date, time]; tolerates a missing time.
List<String> splitDateTime(String date) {
  final idx = date.indexOf(' ');
  if (idx < 0) return [date.trim(), ''];
  return [date.substring(0, idx).trim(), date.substring(idx + 1).trim()];
}

Future<pw.Widget> getDateRow(BuildContext context, int round) async {
  String date = await Data.getDate(round);
  final parts = splitDateTime(date);

  return pw.Row(children: [
    pw.Text(
        AppLocalizations.of(context)!.started_on +
            " " +
            parts[0] +
            " " +
            AppLocalizations.of(context)!.time_at +
            " " +
            parts[1],
        style: await pdfTableTextStyle())
  ]);
}

Future<pw.Widget> pdfHeaderRow(BuildContext context, List<String> names) async {
  List<pw.Widget> widgets = [
    await pdfHeaderCellFix(AppLocalizations.of(context)!.hole, pdfHoleWidth,
        true, pdfDlinewidth, pdfDlinewidth, pdfLinewidth, pdfDlinewidth),
    await pdfHeaderCellFix("Par", pdfParwidth, false, pdfLinewidth,
        pdfDlinewidth, pdfDlinewidth, pdfDlinewidth),
  ];
  for (var i = 0; i < names.length; i++)
    widgets.add(await pdfHeaderCell(
        names[i],
        i == 0 ? pdfDlinewidth : pdfLinewidth,
        pdfDlinewidth,
        i == names.length - 1 ? pdfDlinewidth : pdfLinewidth,
        pdfDlinewidth));

  return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: widgets);
}

Future<pw.Widget> pdfLastRow(
    BuildContext context, List<int> totalScores) async {
  final int parTotal = Data.getPars(App.of(context).getLocality())
      .fold<int>(0, (a, b) => a + b);
  List<pw.Widget> widgets = [
    await pdfHeaderCellFix(AppLocalizations.of(context)!.sum, pdfHoleWidth,
        true, pdfDlinewidth, pdfLinewidth, pdfLinewidth, pdfDlinewidth),
    await pdfHeaderCellFix(parTotal.toString(), pdfParwidth, false, pdfLinewidth, pdfLinewidth,
        pdfDlinewidth, pdfDlinewidth)
  ];
  for (var i = 0; i < totalScores.length; i++)
    widgets.add(await pdfTotalCell(
        totalScores[i].toString(),
        i == 0 ? pdfDlinewidth : pdfLinewidth,
        pdfLinewidth,
        i == totalScores.length - 1 ? pdfDlinewidth : pdfLinewidth,
        pdfDlinewidth));

  return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: widgets);
}

Future<pw.Widget> pdfTableRow(
    BuildContext context, int holeId, List<List<int>> scores) async {
  final double top = holeId == 1 ? pdfDlinewidth : pdfLinewidth;
  final double bottom = holeId == 18 ? pdfDlinewidth : pdfLinewidth;

  List<pw.Widget> widgets = [
    await pdfCellFix(
        AppLocalizations.of(context)!.hole + " " + holeId.toString(),
        pdfHoleWidth,
        true,
        pdfDlinewidth,
        top,
        pdfLinewidth,
        bottom),
    await pdfCellFix(
        Data.getPars(App.of(context).getLocality())[holeId - 1].toString(),
        pdfParwidth,
        false,
        pdfLinewidth,
        top,
        pdfDlinewidth,
        bottom),
  ];
  for (var i = 0; i < scores.length; i++)
    widgets.add(await pdfCell(
        scores[i][holeId - 1].toString(),
        i == 0 ? pdfDlinewidth : pdfLinewidth,
        top,
        i == scores.length - 1 ? pdfDlinewidth : pdfLinewidth,
        bottom));

  return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: widgets);
}

Future<pw.Widget> pdfHeaderCellFix(String text, double width, bool alignleft,
    double left, double top, double right, double bottom) async {
  return pw.Container(
    decoration: pdfDecoration(left, top, right, bottom),
    child: pw.Text(text,
        maxLines: 1,
        textAlign: alignleft ? pw.TextAlign.left : pw.TextAlign.center,
        style: await pdfTableTextStyleBold()),
    width: width,
    padding:
        pw.EdgeInsets.fromLTRB(alignleft ? pdfhpad : 0, pdfvpad, 0, pdfvpad),
  );
}

Future<pw.Widget> pdfHeaderCell(
    String text, double left, double top, double right, double bottom) async {
  return pw.Expanded(
      child: pw.Container(
          decoration: pdfDecoration(left, top, right, bottom),
          child: pw.Text(text,
              maxLines: 1,
              textAlign: pw.TextAlign.center,
              style: await pdfTableTextStyleBold()),
          padding: pw.EdgeInsets.fromLTRB(0, pdfvpad, 0, pdfvpad)));
}

Future<pw.Widget> pdfTotalCell(
    String text, double left, double top, double right, double bottom) async {
  return pw.Expanded(
      child: await pdfTotalCellContainer(text, left, top, right, bottom));
}

Future<pw.Widget> pdfTotalCellContainer(
    String text, double left, double top, double right, double bottom) async {
  return pw.Container(
      decoration: pdfDecoration(left, top, right, bottom),
      child: await pdfTotalCellText(text),
      padding: pw.EdgeInsets.fromLTRB(0, pdfvpad, 0, pdfvpad));
}

Future<pw.Text> pdfTotalCellText(String text) async {
  return pw.Text(text,
      maxLines: 1,
      textAlign: pw.TextAlign.center,
      style: await pdfTableTextStyleBold());
}

Future<pw.Widget> pdfCellFix(
    String text,
    double width,
    bool alignleft,
    double left,
    double top,
    double right,
    double bottom) async {
  return pw.Container(
      decoration: pdfDecoration(left, top, right, bottom),
      child: pw.Text(text,
          maxLines: 1,
          textAlign: alignleft ? pw.TextAlign.left : pw.TextAlign.center,
          style: await pdfTableTextStyle()),
      width: width,
      padding:
          pw.EdgeInsets.fromLTRB(alignleft ? pdfhpad : 0, pdfvpad, 0, pdfvpad));
}

Future<pw.Widget> pdfCell(
    String text, double left, double top, double right, double bottom,
    {bool empty = false}) async {
  return pw.Expanded(
      child:
          await pdfCellContainer(text, left, top, right, bottom, empty: empty));
}

Future<pw.Widget> pdfCellContainer(
    String text, double left, double top, double right, double bottom,
    {bool empty = false}) async {
  return pw.Container(
      decoration: pdfDecoration(left, top, right, bottom),
      child: await pdfCellText(text, empty: empty),
      padding: pw.EdgeInsets.fromLTRB(0, pdfvpad, 0, pdfvpad));
}

Future<pw.Text> pdfCellText(String text, {bool empty = false}) async {
  return pw.Text(text,
      maxLines: 1,
      textAlign: pw.TextAlign.center,
      style: empty ? await pdfEmptyTextStyle() : await pdfTableTextStyle());
}

Future<pw.TextStyle> pdfTextStyle() async {
  final font = await PdfGoogleFonts.nunitoExtraLight();
  return pw.TextStyle(font: font, fontSize: 14);
}

Future<pw.TextStyle> pdfTitleTextStyle() async {
  final font = await PdfGoogleFonts.nunitoBold();
  return pw.TextStyle(font: font, fontSize: 16);
}

Future<pw.TextStyle> pdfFooterTextStyle() async {
  final font = await PdfGoogleFonts.nunitoExtraLight();
  return pw.TextStyle(font: font, fontSize: 11);
}

Future<pw.TextStyle> pdfTableTextStyle() async {
  final font = await PdfGoogleFonts.nunitoExtraLight();
  return pw.TextStyle(font: font, fontSize: 12);
}

Future<pw.TextStyle> pdfEmptyTextStyle() async {
  final font = await PdfGoogleFonts.nunitoExtraLight();
  return pw.TextStyle(
      font: font, fontSize: 12, color: PdfColor.fromHex("#FFFFFF"));
}

Future<pw.TextStyle> pdfTableTextStyleBold() async {
  final font = await PdfGoogleFonts.nunitoBold();
  return pw.TextStyle(font: font, fontSize: 12);
}

pw.BoxDecoration pdfDecoration(
    double left, double top, double right, double bottom) {
  return pw.BoxDecoration(
    border: pw.Border(
      left: pw.BorderSide(width: left, color: pdfTableColor),
      top: pw.BorderSide(width: top, color: pdfTableColor),
      right: pw.BorderSide(width: right, color: pdfTableColor),
      bottom: pw.BorderSide(width: bottom, color: pdfTableColor),
    ),
  );
}

PdfColor pdfTableColor = PdfColor.fromHex("#757575");

Future<pw.Document> createPdfSingleRound(
    BuildContext context, int round) async {
  final pdf = pw.Document();
  pw.Widget footerCol = await pdfFooterColumn(context);

  pdf.addPage(await pdfRoundPage(context, footerCol, round, true, 0));
  return pdf;
}

Future<pw.Document> createPdfMultipleRounds(
    BuildContext context, List<int> roundsToBeIncremented) async {
  assert(roundsToBeIncremented.length > 0);

  final pdf = pw.Document();
  pw.Widget footerCol = await pdfFooterColumn(context);

  pdf.addPage(await pdfSummaryPage(context, footerCol, roundsToBeIncremented));

  int l = roundsToBeIncremented.length;
  for (var i = 0; i < l; i++)
    pdf.addPage(await pdfRoundPage(context, footerCol,
        roundsToBeIncremented[l - i - 1] + 1, false, i + 1));
  return pdf;
}

Future<pw.Page> pdfRoundPage(BuildContext context, pw.Widget footerCol,
    int round, bool withHeader, int titleId) async {
  List<pw.Widget> widgets = [];
  if (withHeader) {
    widgets.add(await getPdfHeader(context));
    widgets.add(pdfSpace(40));
  }

  if (titleId > 0) {
    widgets.add(pw.Row(children: [
      pw.Text(AppLocalizations.of(context)!.round + " " + titleId.toString(),
          style: await pdfTitleTextStyle()),
      pw.Spacer()
    ]));
    widgets.add(pdfSpace(10));
  }

  widgets.add(await pdfRoundTable(context, round));

  return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Stack(children: [pw.Column(children: widgets), footerCol]);
      });
}

Future<pw.Page> pdfSummaryPage(BuildContext context, pw.Widget footerCol,
    List<int> roundsToBeIncremented) async {
  List<pw.Widget> widgets = [];

  widgets.add(await getPdfHeader(context));
  widgets.add(pdfSpace(40));

  widgets.add(pw.Row(children: [
    pw.Text(AppLocalizations.of(context)!.summary,
        style: await pdfTitleTextStyle()),
    pw.Spacer()
  ]));
  widgets.add(pdfSpace(10));

  widgets.add(await pdfSummaryTable(context, roundsToBeIncremented));

  return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Stack(children: [pw.Column(children: widgets), footerCol]);
      });
}

class IndexNamePair {
  int index;
  String name;

  IndexNamePair(this.index, this.name);
}

Future<pw.Column> pdfSummaryTable(
    BuildContext context, List<int> roundsToBeIncremented) async {
  List<List<int>> indices =
      await Data.getPlayerIndicesInRoundsToBeInc(roundsToBeIncremented);
  List<IndexNamePair> allPlayers = await getAllPlayersForPdf(indices);

  List<pw.Widget> rows = [
    pdfSpace(10),
    await pdfSummaryHeaderRow(context, roundsToBeIncremented.length),
  ];

  if (roundsToBeIncremented.length <= 7) {
    rows.add(await pdfDateRow(context, roundsToBeIncremented));
    rows.add(await pdfTimeRow(context, roundsToBeIncremented));
  }

  for (var i = 0; i < allPlayers.length; i++)
    rows.add(await pdfSummaryTableRow(context, allPlayers[i],
        roundsToBeIncremented, i == 0, i == allPlayers.length - 1));

  rows.add(pdfSpace(10));

  return pw.Column(children: rows);
}

Future<pw.Widget> pdfSummaryTableRow(BuildContext context, IndexNamePair player,
    List<int> roundsToBeIncremented, bool first, bool last) async {
  final double top = first ? pdfDlinewidth : pdfLinewidth;
  final double bottom = last ? pdfDlinewidth : pdfLinewidth;

  List<pw.Widget> widgets = [
    await pdfHeaderCellFix(player.name, pdfSummaryWidth, true, pdfDlinewidth,
        top, pdfLinewidth, bottom),
  ];

  int sum = 0;

  int l = roundsToBeIncremented.length;
  for (var i = 0; i < l; i++) {
    int score = await Data.getTotalScoreForPlayerIndex(
        roundsToBeIncremented[l - i - 1] + 1, player.index);

    String text = score.toString();
    sum += score;

    widgets.add(await pdfCell(
        text,
        i == 0 ? pdfDlinewidth : pdfLinewidth,
        top,
        i == roundsToBeIncremented.length - 1 ? pdfDlinewidth : pdfLinewidth,
        bottom,
        empty: score == 0));
  }

  widgets.add(await pdfHeaderCell(
      sum.toString(), pdfDlinewidth, top, pdfDlinewidth, bottom));

  return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: widgets);
}

Future<pw.Widget> pdfSummaryHeaderRow(
    BuildContext context, int roundCnt) async {
  List<pw.Widget> widgets = [
    await pdfHeaderCellFix(AppLocalizations.of(context)!.round, pdfSummaryWidth,
        true, pdfDlinewidth, pdfDlinewidth, pdfLinewidth, pdfDlinewidth),
  ];
  for (var i = 0; i < roundCnt; i++)
    widgets.add(await pdfCell(
        (i + 1).toString(),
        i == 0 ? pdfDlinewidth : pdfLinewidth,
        pdfDlinewidth,
        i == roundCnt - 1 ? pdfDlinewidth : pdfLinewidth,
        pdfDlinewidth));

  widgets.add(await pdfHeaderCell(
      "\u03a3", pdfDlinewidth, pdfDlinewidth, pdfDlinewidth, pdfDlinewidth));

  return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: widgets);
}

Future<pw.Widget> pdfDateRow(
    BuildContext context, List<int> roundsToBeIncremented) async {
  List<pw.Widget> widgets = [
    await pdfHeaderCellFix(AppLocalizations.of(context)!.date, pdfSummaryWidth,
        true, pdfDlinewidth, pdfDlinewidth, pdfLinewidth, pdfLinewidth),
  ];

  int l = roundsToBeIncremented.length;
  for (var i = 0; i < roundsToBeIncremented.length; i++) {
    String date = await Data.getDate(roundsToBeIncremented[l - i - 1] + 1);
    final parts = splitDateTime(date);

    String dateOnly = parts[0];
    if (roundsToBeIncremented.length > 3) {
      final firstDot = dateOnly.indexOf('.');
      final secondDot =
          firstDot < 0 ? -1 : dateOnly.indexOf('.', firstDot + 1);
      if (secondDot > 0) dateOnly = dateOnly.substring(0, secondDot + 1);
    }

    widgets.add(await pdfCell(
        dateOnly,
        i == 0 ? pdfDlinewidth : pdfLinewidth,
        pdfDlinewidth,
        i == roundsToBeIncremented.length - 1 ? pdfDlinewidth : pdfLinewidth,
        pdfLinewidth));
  }

  widgets.add(await pdfCell(
      "0", pdfDlinewidth, pdfDlinewidth, pdfDlinewidth, pdfLinewidth,
      empty: true));

  return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: widgets);
}

Future<pw.Widget> pdfTimeRow(
    BuildContext context, List<int> roundsToBeIncremented) async {
  List<pw.Widget> widgets = [
    await pdfHeaderCellFix(AppLocalizations.of(context)!.time, pdfSummaryWidth,
        true, pdfDlinewidth, pdfLinewidth, pdfLinewidth, pdfDlinewidth),
  ];

  int l = roundsToBeIncremented.length;
  for (var i = 0; i < roundsToBeIncremented.length; i++) {
    String date = await Data.getDate(roundsToBeIncremented[l - i - 1] + 1);
    final parts = splitDateTime(date);

    widgets.add(await pdfCell(
        parts[1],
        i == 0 ? pdfDlinewidth : pdfLinewidth,
        pdfLinewidth,
        i == roundsToBeIncremented.length - 1 ? pdfDlinewidth : pdfLinewidth,
        pdfDlinewidth));
  }

  widgets.add(await pdfCell(
      "0", pdfDlinewidth, pdfLinewidth, pdfDlinewidth, pdfDlinewidth,
      empty: true));

  return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: widgets);
}

Future<List<IndexNamePair>> getAllPlayersForPdf(List<List<int>> indices) async {
  final allIndicesSet = <int>{for (final list in indices) ...list};

  List<IndexNamePair> players = [];
  for (var id in allIndicesSet)
    players.add(IndexNamePair(id, await Data.getPlayerName(id)));

  players.sort((a, b) => a.name.compareTo(b.name));

  return players;
}

Future<bool> savePdf(
    BuildContext context, pw.Document pdf, String filename) async {
  final bytes = await pdf.save();
  if (!context.mounted) return false;
  return saveExportFile(context, bytes, filename, 'pdf');
}

pw.Widget pdfSpace(double _height) {
  return pw.SizedBox(height: _height);
}

pw.Widget pdfSpaceH(double _widtht) {
  return pw.SizedBox(width: _widtht);
}
