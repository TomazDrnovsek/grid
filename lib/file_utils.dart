import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FileUtils {
  /// Returns (and creates if needed) the app's private "images" folder.
  static Future<Directory> getAppImagesDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${docsDir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  /// Returns (and creates if needed) the app's private "thumbnails" folder.
  static Future<Directory> getAppThumbnailsDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final thumbsDir = Directory('${docsDir.path}/thumbnails');
    if (!await thumbsDir.exists()) {
      await thumbsDir.create(recursive: true);
    }
    return thumbsDir;
  }

  /// Copies [source] into app storage and compresses it.
  /// - maxWidth: 1074px, quality: 85
  /// - preserves EXIF orientation (autoCorrectionAngle)
  /// Throws on I/O errors.
  static Future<File> copyAndCompress(XFile source) async {
    final appDir = await getAppImagesDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetPath = '${appDir.path}/IMG_$timestamp.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      source.path,
      targetPath,
      minWidth: 1074,
      // Let plugin decide minHeight to preserve aspect ratio
      quality: 85,
      autoCorrectionAngle: true,
      keepExif: true,
    );

    if (result == null) {
      throw Exception('Compression failed for ${source.path}');
    }
    return File(result.path);
  }

  /// Generates a small thumbnail optimized for 3:4 grid display.
  /// - Width: 360px (perfect for 3-column grid with 3x pixel density)
  /// - Quality: 85 (high quality for sharp grid display)
  /// - Preserves EXIF orientation and aspect ratio
  /// Returns the thumbnail file path.
  static Future<File> generateThumbnail(XFile source) async {
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
    return File(result.path);
  }

  /// Creates both a full-size compressed image and a thumbnail.
  /// Returns a map with 'image' and 'thumbnail' keys containing the File objects.
  /// This is the primary method for processing new images.
  static Future<Map<String, File>> processImageWithThumbnail(XFile source) async {
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

    // Process thumbnail - optimized for 3:4 grid display
    final thumbResult = await FlutterImageCompress.compressAndGetFile(
      source.path,
      thumbPath,
      minWidth: 360, // Perfect for 3-column grid
      quality: 85,   // High quality for sharp grid display
      autoCorrectionAngle: true,
      keepExif: false,
    );

    if (imageResult == null || thumbResult == null) {
      throw Exception('Image processing failed for ${source.path}');
    }

    return {
      'image': File(imageResult.path),
      'thumbnail': File(thumbResult.path),
    };
  }

  /// Cleans up orphaned thumbnail files when images are deleted.
  /// Call this periodically or after batch deletions.
  static Future<void> cleanupOrphanedThumbnails(List<String> validImagePaths) async {
    try {
      final thumbDir = await getAppThumbnailsDir();
      final thumbFiles = await thumbDir.list().toList();

      // Extract timestamps from valid image paths
      final validTimestamps = <String>{};
      for (final imagePath in validImagePaths) {
        final fileName = imagePath.split('/').last;
        if (fileName.startsWith('IMG_') && fileName.endsWith('.jpg')) {
          final timestamp = fileName.substring(4, fileName.length - 4);
          validTimestamps.add(timestamp);
        }
      }

      // Delete thumbnails that don't have corresponding images
      for (final entity in thumbFiles) {
        if (entity is File) {
          final fileName = entity.path.split('/').last;
          if (fileName.startsWith('THUMB_') && fileName.endsWith('.jpg')) {
            final timestamp = fileName.substring(6, fileName.length - 4);
            if (!validTimestamps.contains(timestamp)) {
              try {
                await entity.delete();
              } catch (e) {
                // Ignore individual deletion errors
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors - not critical
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
      await for (final entity in imageDir.list(recursive: true)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            totalSize += stat.size;
          } catch (e) {
            // Ignore individual file errors
          }
        }
      }

      // Calculate thumbnail directory size
      await for (final entity in thumbDir.list(recursive: true)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            totalSize += stat.size;
          } catch (e) {
            // Ignore individual file errors
          }
        }
      }
    } catch (e) {
      // Return 0 if there's an error calculating size
    }

    return totalSize;
  }

  /// Formats bytes into human-readable format (KB, MB, GB).
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}