import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../widgets/toast.dart';
import './data.dart';

enum ExportMenuItemE { CSV, PDF, COUNT }

/// Turns a user/date based name into something every file system accepts
/// (dates contain ':' and '.', which are illegal or awkward on Android/iOS).
String sanitizeFileName(String name) => name
    .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
    .replaceAll(' ', '__')
    .replaceAll('.', '_');

/// Lets the user choose where to save [bytes] via the system save dialog
/// (Storage Access Framework on Android, Files app on iOS).
/// No storage permissions or hardcoded paths are needed.
///
/// Returns true if the file was saved, false if the user cancelled or
/// saving failed (a toast is shown in the failure case).
Future<bool> saveExportFile(BuildContext context, Uint8List bytes,
    String baseName, String extension) async {
  final l10n = AppLocalizations.of(context)!;
  final prefix = Data.getFilenamePrefix(App.of(context).getLocality());
  final fileName = '${sanitizeFileName(prefix + baseName)}.$extension';

  try {
    final path = await FilePicker.saveFile(
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [extension],
      bytes: bytes, // required on Android/iOS: the plugin writes the file
    );

    if (!context.mounted) return false;
    if (path == null) return false; // cancelled by the user

    // The path can be a content:// URI on mobile, so show the name instead.
    CustomToast.showToastIcon(
        context, '${l10n.saved_as} $fileName', Icons.check,
        dur: 5);
    return true;
  } catch (e) {
    debugPrint('Export failed: $e');
    if (context.mounted) {
      CustomToast.showToast(context, l10n.could_not_store);
    }
    return false;
  }
}

PopupMenuButton<ExportMenuItemE> getExportMenuImpl(
    BuildContext context, void Function(ExportMenuItemE value) func) {
  return PopupMenuButton<ExportMenuItemE>(
    icon: const Icon(Icons.save_alt),
    offset: const Offset(30, 0),
    itemBuilder: (context) => getExportItems(context),
    onSelected: func,
  );
}

List<ExportMenuItem> getExportItems(BuildContext context) {
  return [
    for (final item in ExportMenuItemE.values)
      if (item != ExportMenuItemE.COUNT) ExportMenuItem(context, item),
  ];
}

class ExportMenuItem extends PopupMenuItem<ExportMenuItemE> {
  ExportMenuItem(BuildContext context, ExportMenuItemE value)
      : super(
          value: value,
          child: ListTile(
            leading: getIcon(value),
            title: Text(getText(context, value),
                style: GoogleFonts.lato(color: mainred)),
          ),
        );

  static String getText(BuildContext context, ExportMenuItemE value) {
    switch (value) {
      case ExportMenuItemE.CSV:
        return AppLocalizations.of(context)!.export_csv;
      case ExportMenuItemE.PDF:
        return AppLocalizations.of(context)!.export_pdf;
      case ExportMenuItemE.COUNT:
        assert(false);
        return "";
    }
  }

  static Widget getIcon(ExportMenuItemE value) {
    switch (value) {
      case ExportMenuItemE.CSV:
        return Image.asset('assets/pics/csv.png', color: mainred, width: 24);
      case ExportMenuItemE.PDF:
        return Image.asset('assets/pics/pdf_icon_2.png',
            color: mainred, width: 24);
      case ExportMenuItemE.COUNT:
        assert(false);
        return const SizedBox.shrink();
    }
  }
}
