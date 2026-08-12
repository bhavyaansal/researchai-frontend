import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class DownloadHelper {
  static Future<void> downloadFile(String filename, String content) async {
    // Get the Downloads folder on Windows
    final directory = await getDownloadsDirectory() 
        ?? await getApplicationDocumentsDirectory();
    
    final file = File('${directory.path}\\$filename');
    await file.writeAsString(content, flush: true);
    
    debugPrint('File saved to: ${file.path}');
  }
  
  /// Returns the save path so callers can show it in a SnackBar
  static Future<String> downloadFileAndGetPath(String filename, String content) async {
    final directory = await getDownloadsDirectory() 
        ?? await getApplicationDocumentsDirectory();
    
    final file = File('${directory.path}\\$filename');
    await file.writeAsString(content, flush: true);
    return file.path;
  }
}