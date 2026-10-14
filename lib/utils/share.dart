import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

void share(GlobalKey globalKey, String text) async {
  print("before getImage");
  Uint8List image = await capturePng(globalKey);
  print("before writeByteToImageFile");
  File file = await writeByteToImageFile(image);
  print("before shareFile");
  shareFile(file, text);
  print("after shareFile");
}

Future<Uint8List> capturePng(GlobalKey _globalKey) async {
  //try {
  print('inside');
  RenderObject? b = _globalKey.currentContext!.findRenderObject();
  RenderRepaintBoundary boundary = b as RenderRepaintBoundary;

  if (!kReleaseMode && boundary.debugNeedsPaint) {
    print("Waiting for boundary to be painted.");
    await Future.delayed(const Duration(milliseconds: 20));
    return capturePng(_globalKey);
  }

  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  var pngBytes = byteData!.buffer.asUint8List();
  //print(pngBytes);
  //print(bs64);
  return pngBytes;
  /*} catch (e) {
      print(e);
    }

    return ;*/
}

Future<File> writeByteToImageFile(Uint8List bytes) async {
  Directory? dir = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();

  File imageFile = await new File(
          "${dir!.path}/flutter/${DateTime.now().millisecondsSinceEpoch}.png")
      .create(recursive: true);
  imageFile.writeAsBytesSync(bytes);
  return imageFile;
}

void shareFile(File f, String text) {
  print("path " + f.path);
  final params = ShareParams(
    text: text,
    files: [XFile('${f.path}')],
  );
  SharePlus.instance.share(params);
}
//final directory = (await getExternalStorageDirectories(type: StorageDirectory.documents)).first!;
//final directory = (await getExternalStorageDirectories(type: StorageDirectory.downloads)).first!;
