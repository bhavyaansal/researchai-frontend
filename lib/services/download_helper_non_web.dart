import 'dart:io';
import 'package:flutter/foundation.dart';

void saveFile(String filename, String content) {
  try {
    final file = File(filename);
    file.writeAsStringSync(content);
    debugPrint('File saved successfully to ${file.absolute.path}');
  } catch (e) {
    debugPrint('Failed to save file locally: $e');
  }
}
