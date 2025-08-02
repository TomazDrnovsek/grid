// File: lib/file_utils.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class FileUtils {
  /// Returns (and creates if needed) the app's private "images" folder.
  static Future<Directory> getAppImagesDir() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${docsDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      return imagesDir;
    } catch (e) {
      debugPrint('Error getting app images directory: $e');
      rethrow;
    }
  }

  /// Returns (and creates if needed) the app's private "thumbnails" folder.
  static Future<Directory> getAppThumbnailsDir() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final thumbsDir = Directory('${docsDir.path}/thumbnails');
      if (!await thumbsDir.exists()) {
        await thumbsDir.create(recursive: true);
      }
      return thumbsDir;
    } catch (e) {
      debugPrint('Error getting app thumbnails directory: $e');
      rethrow;
    }
  }

  /// Copies [source] into app storage and compresses it.
  /// - maxWidth: 1080px, quality: 85
  /// - preserves EXIF orientation (autoCorrectionAngle)
  /// Throws on I/O errors.
  static Future<File> copyAndCompress(XFile source) async {
    try {
      // Verify source file exists
      final sourceFile = File(source.path);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: ${source.path}');
      }

      final appDir = await getAppImagesDir();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${appDir.path}/IMG_$timestamp.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        source.path,
        targetPath,
        minWidth: 1080,
        // Let plugin decide minHeight to preserve aspect ratio
        quality: 85,
        autoCorrectionAngle: true,
        keepExif: true,
      );

      if (result == null) {
        throw Exception('Compression failed for ${source.path}');
      }

      // Verify the compressed file was created
      final compressedFile = File(result.path);
      if (!await compressedFile.exists()) {
        throw Exception('Compressed file was not created: ${result.path}');
      }

      return compressedFile;
    } catch (e) {
      debugPrint('Error in copyAndCompress: $e');
      rethrow;
    }
  }

  /// Generates a small thumbnail optimized for 3:4 grid display.
  /// - Width: 360px (perfect for 3-column grid with 3x pixel density)
  /// - Quality: 85 (high quality for sharp grid display)
  /// - Preserves EXIF orientation and aspect ratio
  /// Returns the thumbnail file path.
  static Future<File> generateThumbnail(XFile source) async {
    try {
      // Verify source file exists
      final sourceFile = File(source.path);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: ${source.path}');
      }

      final thumbDir = await getAppThumbnailsDir();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final thumbPath = '${thumbDir.path}/THUMB_$timestamp.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        source.path,
        thumbPath,
        minWidth: 360,
        // Let plugin decide minHeight to preserve aspect ratio
        quality: 85,
        autoCorrectionAngle: true,
        keepExif: false, // Thumbnails don't need EXIF data
      );

      if (result == null) {
        throw Exception('Thumbnail generation failed for ${source.path}');
      }

      // Verify the thumbnail file was created
      final thumbFile = File(result.path);
      if (!await thumbFile.exists()) {
        throw Exception('Thumbnail file was not created: ${result.path}');
      }

      return thumbFile;
    } catch (e) {
      debugPrint('Error in generateThumbnail: $e');
      rethrow;
    }
  }

  /// Creates both a full-size compressed image and a thumbnail.
  /// Returns a map with 'image' and 'thumbnail' keys containing the File objects.
  /// This is the primary method for processing new images.
  static Future<Map<String, File>> processImageWithThumbnail(XFile source) async {
    try {
      // Verify source file exists
      final sourceFile = File(source.path);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: ${source.path}');
      }

      final appDir = await getAppImagesDir();
      final thumbDir = await getAppThumbnailsDir();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final imagePath = '${appDir.path}/IMG_$timestamp.jpg';
      final thumbPath = '${thumbDir.path}/THUMB_$timestamp.jpg';

      // Process full image - high quality for future full-screen viewing
      final imageResult = await FlutterImageCompress.compressAndGetFile(
        source.path,
        imagePath,
        minWidth: 1074,
        quality: 85,
        autoCorrectionAngle: true,
        keepExif: true,
      );

      if (imageResult == null) {
        throw Exception('Full image compression failed for ${source.path}');
      }

      // Process thumbnail - optimized for 3:4 grid display
      final thumbResult = await FlutterImageCompress.compressAndGetFile(
        source.path,
        thumbPath,
        minWidth: 360, // Perfect for 3-column grid
        quality: 85,   // High quality for sharp grid display
        autoCorrectionAngle: true,
        keepExif: false,
      );

      if (thumbResult == null) {
        // Clean up the full image if thumbnail fails
        try {
          await File(imageResult.path).delete();
        } catch (e) {
          debugPrint('Failed to clean up full image after thumbnail failure: $e');
        }
        throw Exception('Thumbnail generation failed for ${source.path}');
      }

      // Verify both files were created
      final imageFile = File(imageResult.path);
      final thumbFile = File(thumbResult.path);

      if (!await imageFile.exists() || !await thumbFile.exists()) {
        // Clean up any created files
        try {
          if (await imageFile.exists()) await imageFile.delete();
          if (await thumbFile.exists()) await thumbFile.delete();
        } catch (e) {
          debugPrint('Failed to clean up files after verification failure: $e');
        }
        throw Exception('Image processing verification failed');
      }

      return {
        'image': imageFile,
        'thumbnail': thumbFile,
      };
    } catch (e) {
      debugPrint('Error in processImageWithThumbnail: $e');
      rethrow;
    }
  }

  /// Cleans up orphaned thumbnail files when images are deleted.
  /// Call this periodically or after batch deletions.
  static Future<void> cleanupOrphanedThumbnails(List<String> validImagePaths) async {
    try {
      final thumbDir = await getAppThumbnailsDir();

      // Check if thumbnail directory exists
      if (!await thumbDir.exists()) {
        return;
      }

      final thumbFiles = await thumbDir.list().toList();

      // Extract timestamps from valid image paths
      final validTimestamps = <String>{};
      for (final imagePath in validImagePaths) {
        try {
          final fileName = imagePath.split('/').last;
          if (fileName.startsWith('IMG_') && fileName.endsWith('.jpg')) {
            final timestamp = fileName.substring(4, fileName.length - 4);
            validTimestamps.add(timestamp);
          }
        } catch (e) {
          debugPrint('Error parsing image path $imagePath: $e');
        }
      }

      // Delete thumbnails that don't have corresponding images
      for (final entity in thumbFiles) {
        if (entity is File) {
          try {
            final fileName = entity.path.split('/').last;
            if (fileName.startsWith('THUMB_') && fileName.endsWith('.jpg')) {
              final timestamp = fileName.substring(6, fileName.length - 4);
              if (!validTimestamps.contains(timestamp)) {
                try {
                  await entity.delete();
                  debugPrint('Deleted orphaned thumbnail: ${entity.path}');
                } catch (e) {
                  debugPrint('Failed to delete orphaned thumbnail ${entity.path}: $e');
                }
              }
            }
          } catch (e) {
            debugPrint('Error processing thumbnail file ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error in cleanupOrphanedThumbnails: $e');
      // Don't rethrow - cleanup errors are not critical
    }
  }

  /// Gets the thumbnail file path for a given image file path.
  /// Returns null if the thumbnail doesn't exist.
  static Future<File?> getThumbnailForImage(String imagePath) async {
    try {
      final fileName = imagePath.split('/').last;
      if (!fileName.startsWith('IMG_') || !fileName.endsWith('.jpg')) {
        return null;
      }

      final timestamp = fileName.substring(4, fileName.length - 4);
      final thumbDir = await getAppThumbnailsDir();
      final thumbFile = File('${thumbDir.path}/THUMB_$timestamp.jpg');

      if (await thumbFile.exists()) {
        return thumbFile;
      }
      return null;
    } catch (e) {
      debugPrint('Error in getThumbnailForImage: $e');
      return null;
    }
  }

  /// Calculates the total storage used by images and thumbnails.
  /// Returns size in bytes.
  static Future<int> getTotalStorageUsed() async {
    int totalSize = 0;

    try {
      final imageDir = await getAppImagesDir();
      final thumbDir = await getAppThumbnailsDir();

      // Calculate image directory size
      if (await imageDir.exists()) {
        try {
          await for (final entity in imageDir.list(recursive: false)) {
            if (entity is File) {
              try {
                final stat = await entity.stat();
                totalSize += stat.size;
              } catch (e) {
                debugPrint('Error getting file stats for ${entity.path}: $e');
                // Continue with other files
              }
            }
          }
        } catch (e) {
          debugPrint('Error listing image directory: $e');
        }
      }

      // Calculate thumbnail directory size
      if (await thumbDir.exists()) {
        try {
          await for (final entity in thumbDir.list(recursive: false)) {
            if (entity is File) {
              try {
                final stat = await entity.stat();
                totalSize += stat.size;
              } catch (e) {
                debugPrint('Error getting file stats for ${entity.path}: $e');
                // Continue with other files
              }
            }
          }
        } catch (e) {
          debugPrint('Error listing thumbnail directory: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in getTotalStorageUsed: $e');
      // Return the size we calculated so far
    }

    return totalSize;
  }

  /// Formats bytes into human-readable format (KB, MB, GB).
  static String formatBytes(int bytes) {
    if (bytes < 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Safely deletes a file with error handling.
  /// Returns true if successful, false otherwise.
  static Future<bool> deleteFileSafely(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return true; // File doesn't exist, consider it a success
    } catch (e) {
      debugPrint('Error deleting file ${file.path}: $e');
      return false;
    }
  }

  /// Safely deletes multiple files with error handling.
  /// Returns the number of successfully deleted files.
  static Future<int> deleteFilesSafely(List<File> files) async {
    int successCount = 0;
    for (final file in files) {
      if (await deleteFileSafely(file)) {
        successCount++;
      }
    }
    return successCount;
  }

  /// Verifies that an image file is valid and can be loaded.
  /// Returns true if the image is valid, false otherwise.
  static Future<bool> verifyImageFile(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return false;
      }

      // Check file size - if it's 0, the file is corrupted
      final stat = await imageFile.stat();
      if (stat.size == 0) {
        debugPrint('Image file is empty: ${imageFile.path}');
        return false;
      }

      // Try to read the first few bytes to ensure file is accessible
      final bytes = await imageFile.openRead(0, 100).first;
      if (bytes.isEmpty) {
        debugPrint('Unable to read image file: ${imageFile.path}');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error verifying image file ${imageFile.path}: $e');
      return false;
    }
  }

  /// Repairs missing or corrupted thumbnails for existing images.
  /// Returns the number of thumbnails repaired.
  static Future<int> repairMissingThumbnails(List<String> imagePaths) async {
    int repairedCount = 0;

    for (final imagePath in imagePaths) {
      try {
        // Skip if not a valid image path
        if (!imagePath.contains('/IMG_') || !imagePath.endsWith('.jpg')) {
          continue;
        }

        // Check if image exists
        final imageFile = File(imagePath);
        if (!await verifyImageFile(imageFile)) {
          debugPrint('Skipping invalid image: $imagePath');
          continue;
        }

        // Check if thumbnail exists and is valid
        final thumbnail = await getThumbnailForImage(imagePath);
        bool needsRepair = false;

        if (thumbnail == null) {
          needsRepair = true;
          debugPrint('Missing thumbnail for: $imagePath');
        } else if (!await verifyImageFile(thumbnail)) {
          needsRepair = true;
          debugPrint('Corrupted thumbnail for: $imagePath');
        }

        if (needsRepair) {
          try {
            debugPrint('Generating new thumbnail for: $imagePath');
            await generateThumbnail(XFile(imagePath));
            repairedCount++;
          } catch (e) {
            debugPrint('Failed to repair thumbnail for $imagePath: $e');
          }
        }
      } catch (e) {
        debugPrint('Error checking thumbnail for $imagePath: $e');
      }
    }

    return repairedCount;
  }
}