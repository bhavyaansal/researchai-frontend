import 'package:flutter/foundation.dart';
import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart'
    if (dart.library.io) 'download_helper_non_web.dart' as helper;

class DownloadHelper {
  static Future<void> downloadFile(String filename, String content) async {
    await helper.saveFile(filename, content);
  }

  /// Returns the save path so callers can show it in a SnackBar
  static Future<String> downloadFileAndGetPath(String filename, String content) async {
    await helper.saveFile(filename, content);
    return kIsWeb ? filename : filename;
  }

  static Future<void> downloadBytes(String filename, Uint8List bytes) async {
    await helper.saveBytes(filename, bytes);
  }
}