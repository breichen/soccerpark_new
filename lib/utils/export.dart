import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../main.dart';
import './data.dart';

Future<String> getFilePath(BuildContext context, String filename) async {
  List<Directory>? l =
      (await getExternalStorageDirectories(type: StorageDirectory.documents));
  if (l == null) return "";

  final path = "/storage/emulated/0/Documents/Soccerpark/" +
      Data.getFilenamePrefix(App.of(context).getLocality()) +
      filename;
  ;
  print(path);
  return path;
}

PopupMenuButton getExportMenuImpl(
    BuildContext context, void Function(ExportMenuItemE value) func) {
  return PopupMenuButton(
      icon: Image.asset(
        'assets/pics/export.png',
        color: Colors.white,
      ),
      offset: Offset(30, 0),
      itemBuilder: (context) {
        return getExportItems(context);
      },
      onSelected: (value) {
        func(ExportMenuItemE.values[value]);
      });
}

List<ExportMenuItem> getExportItems(BuildContext context) {
  List<ExportMenuItem> items = [];
  for (var i = 0; i < ExportMenuItemE.COUNT.index; i++) {
    items.add(ExportMenuItem(context, ExportMenuItemE.values[i]));
  }
  return items;
}

enum ExportMenuItemE { CSV, PDF, COUNT }

class ExportMenuItem extends PopupMenuItem<int> {
  ExportMenuItem(BuildContext context, ExportMenuItemE value)
      : super(
          value: value.index,
          child: ListTile(
            leading: getIcon(value), // your icon
            title: Text(getText(context, value),
                style: GoogleFonts.lato(color: Color(mainredValue))),
          ),
        );

  static String getText(BuildContext context, ExportMenuItemE value) {
    switch (value) {
      case ExportMenuItemE.CSV:
        return AppLocalizations.of(context)!.export_csv;
      case ExportMenuItemE.PDF:
        return AppLocalizations.of(context)!.export_pdf;
      default:
        assert(false);
        return "";
    }
  }

  static Widget getIcon(ExportMenuItemE value) {
    switch (value) {
      case ExportMenuItemE.CSV:
        return Image.asset('assets/pics/csv.png', color: mainred, width: 24);
      case ExportMenuItemE.PDF:
        return Image.asset(
          'assets/pics/pdf_icon_2.png',
          color: mainred,
          width: 24,
        );
      default:
        assert(false);
        return Image.asset(
          'assets/pics/csv.png',
          color: mainred,
          width: 24,
        );
    }
  }
}
