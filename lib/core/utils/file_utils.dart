import 'dart:io';
import 'package:image/image.dart' as img;
import '../../core/constants/app_constants.dart';

/// Utility functions for file handling
class FileUtils {
  /// Check if image file exceeds size limit and compress if needed
  static Future<File?> compressImageIfNeeded(File imageFile) async {
    try {
      final fileSizeInBytes = await imageFile.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      // If file is under size limit, return as-is
      if (fileSizeInMB <= AppConstants.maxImageSizeMB) {
        return imageFile;
      }

      // Read and decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return imageFile; // Return original if decode fails
      }

      // Compress image
      final compressedBytes = img.encodeJpg(image, quality: 85);
      
      // Check compressed size
      var compressedSize = compressedBytes.length;
      
      // If still too large, further compress
      var quality = 85;
      var finalBytes = compressedBytes;
      
      while (compressedSize > AppConstants.maxImageSizeMB * 1024 * 1024 && quality > 20) {
        quality -= 10;
        final resizedImage = img.copyResize(
          image,
          width: (image.width * 0.9).round(),
          height: (image.height * 0.9).round(),
        );
        finalBytes = img.encodeJpg(resizedImage, quality: quality);
      }

      // Write compressed image to new file
      final compressedFile = File(imageFile.path.replaceFirst('.jpg', '_compressed.jpg')
          .replaceFirst('.png', '_compressed.jpg')
          .replaceFirst('.jpeg', '_compressed.jpg'));
      
      await compressedFile.writeAsBytes(finalBytes);
      
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile; // Return original on error
    }
  }

  /// Get file extension from file path
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Generate unique filename with timestamp
  static String generateUniqueFilename(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.$extension';
  }
}
