import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveFile(String filename, String content) async {
  try {
    final directory = await getDownloadsDirectory() 
        ?? await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content, flush: true);
    debugPrint('File saved successfully to ${file.path}');
  } catch (e) {
    debugPrint('Failed to save file locally: $e');
  }
}

Future<void> saveBytes(String filename, Uint8List bytes) async {
  try {
    final directory = await getDownloadsDirectory()
        ?? await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    debugPrint('File saved to ${file.path}');
  } catch (e) {
    debugPrint('Failed to save file locally: $e');
  }
}