import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import './download_stub.dart' if (dart.library.js_interop) './download_web.dart';

/// Captures the widget behind [globalKey] as PNG and shares it.
/// Works without dart:io, so it runs on Android, iOS and the web.
/// On browsers without file sharing (e.g. desktop Firefox) the PNG is
/// downloaded instead.
Future<void> share(GlobalKey globalKey, String text) async {
  final Uint8List image = await capturePng(globalKey);
  const name = 'soccerpark.png';

  try {
    await SharePlus.instance.share(ShareParams(
      text: text,
      files: [XFile.fromData(image, mimeType: 'image/png', name: name)],
      fileNameOverrides: const [name],
    ));
  } catch (e) {
    debugPrint('Share failed: $e');
    if (kIsWeb) downloadBytes(image, name, 'image/png');
  }
}

Future<Uint8List> capturePng(GlobalKey globalKey) async {
  final RenderObject? b = globalKey.currentContext!.findRenderObject();
  final RenderRepaintBoundary boundary = b as RenderRepaintBoundary;

  if (!kReleaseMode && boundary.debugNeedsPaint) {
    await Future.delayed(const Duration(milliseconds: 20));
    return capturePng(globalKey);
  }

  final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
