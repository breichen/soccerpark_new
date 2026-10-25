import 'dart:typed_data';

/// Only used on the web (see download_web.dart). Mobile builds save and
/// share files through file_picker / share_plus instead.
void downloadBytes(Uint8List bytes, String fileName, String mimeType) {
  throw UnsupportedError('downloadBytes is only available on the web');
}
