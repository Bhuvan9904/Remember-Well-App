import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/file_utils.dart';

/// Service for handling file operations
class FileService {
  /// Get app documents directory
  static Future<Directory> get _documentsDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/rememberwell_files');
  }

  /// Save photo file
  static Future<String> savePhoto(File photoFile) async {
    final dir = await _documentsDirectory;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Compress if needed
    final compressedFile = await FileUtils.compressImageIfNeeded(photoFile);
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = '${dir.path}/photo_$timestamp.jpg';
    await (compressedFile ?? photoFile).copy(newPath);
    
    return newPath;
  }

  /// Load photo file
  static Future<File?> loadPhoto(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Delete file
  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}


