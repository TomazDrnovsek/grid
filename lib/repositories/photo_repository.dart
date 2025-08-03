// File: lib/repositories/photo_repository.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../models/photo_state.dart';
import '../file_utils.dart';

/// Repository layer for photo management business logic
/// Separates data operations from UI state management
class PhotoRepository {
  static const String _imagePathsKey = 'grid_image_paths';
  static const String _headerUsernameKey = 'header_username';

  final ImagePicker _picker = ImagePicker();

  /// Load saved image paths from persistent storage
  /// Returns list of valid image file paths
  Future<List<String>> loadSavedImagePaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList(_imagePathsKey);
      return stored ?? [];
    } catch (e) {
      debugPrint('Error loading saved image paths: $e');
      return [];
    }
  }

  /// Save image paths to persistent storage
  Future<bool> saveImagePaths(List<String> paths) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_imagePathsKey, paths);
      return true;
    } catch (e) {
      debugPrint('Error saving image paths: $e');
      return false;
    }
  }

  /// Process and validate a single saved image path
  /// Handles migration from external storage if needed
  Future<ProcessedImageData?> processSavedImagePath(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        debugPrint('Skipping non-existent file: $path');
        return null;
      }

      final appDir = await FileUtils.getAppImagesDir();
      String finalPath = path;

      // Migrate if needed (external file to app storage)
      if (!path.startsWith(appDir.path)) {
        try {
          final result = await FileUtils.processImageWithThumbnail(XFile(path));
          finalPath = result['image']!.path;
          debugPrint('Migrated image to: $finalPath');
        } catch (e) {
          debugPrint('Migration failed for $path: $e');
          return null;
        }
      }

      // Verify the image file still exists after migration
      final imageFile = File(finalPath);
      if (!await imageFile.exists()) {
        debugPrint('Image file not found after migration: $finalPath');
        return null;
      }

      // Get or generate thumbnail
      File thumbnailFile;
      try {
        final existingThumbnail = await FileUtils.getThumbnailForImage(finalPath);
        if (existingThumbnail != null && await existingThumbnail.exists()) {
          thumbnailFile = existingThumbnail;
        } else {
          debugPrint('Generating missing thumbnail for: $finalPath');
          thumbnailFile = await FileUtils.generateThumbnail(XFile(finalPath));
        }
      } catch (e) {
        debugPrint('Thumbnail handling failed for $finalPath: $e');
        // Use original image as fallback
        thumbnailFile = imageFile;
      }

      return ProcessedImageData(
        imagePath: finalPath,
        imageFile: imageFile,
        thumbnailFile: thumbnailFile,
      );

    } catch (e) {
      debugPrint('Error processing saved image path $path: $e');
      return null;
    }
  }

  /// Load all saved photos with validation and migration
  Future<LoadPhotosResult> loadAllSavedPhotos() async {
    try {
      final storedPaths = await loadSavedImagePaths();
      if (storedPaths.isEmpty) {
        return const LoadPhotosResult(
          images: [],
          thumbnails: [],
          validPaths: [],
          migratedCount: 0,
          repairedCount: 0,
        );
      }

      final List<String> validPaths = [];
      final List<File> loadedImages = [];
      final List<File> loadedThumbnails = [];
      int migratedCount = 0;

      // Process all saved paths
      for (final path in storedPaths) {
        final processed = await processSavedImagePath(path);
        if (processed != null) {
          loadedImages.add(processed.imageFile);
          loadedThumbnails.add(processed.thumbnailFile);
          validPaths.add(processed.imagePath);

          if (processed.imagePath != path) {
            migratedCount++;
          }
        }
      }

      // Save updated paths if migrations occurred
      if (validPaths.length != storedPaths.length || migratedCount > 0) {
        await saveImagePaths(validPaths);
        debugPrint('Updated stored paths: ${validPaths.length} valid out of ${storedPaths.length}, $migratedCount migrated');
      }

      // Repair any missing thumbnails
      final repairedCount = await FileUtils.repairMissingThumbnails(validPaths);
      if (repairedCount > 0) {
        debugPrint('Repaired $repairedCount missing thumbnails');

        // Reload thumbnails after repair
        final repairedThumbnails = <File>[];
        for (final imagePath in validPaths) {
          final thumbnail = await FileUtils.getThumbnailForImage(imagePath);
          repairedThumbnails.add(thumbnail ?? File(imagePath));
        }
        loadedThumbnails.clear();
        loadedThumbnails.addAll(repairedThumbnails);
      }

      return LoadPhotosResult(
        images: loadedImages,
        thumbnails: loadedThumbnails,
        validPaths: validPaths,
        migratedCount: migratedCount,
        repairedCount: repairedCount,
      );

    } catch (e) {
      debugPrint('Error loading all saved photos: $e');
      return const LoadPhotosResult(
        images: <File>[],
        thumbnails: <File>[],
        validPaths: <String>[],
        migratedCount: 0,
        repairedCount: 0,
        error: 'Failed to load saved photos',
      );
    }
  }

  /// Pick multiple images from device gallery
  Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> picks = await _picker.pickMultiImage();
      return picks;
    } catch (e) {
      debugPrint('Error picking images: $e');
      return <XFile>[];
    }
  }

  /// Process a batch of picked images
  Future<BatchImageResult> processBatchImages(List<XFile> imageFiles) async {
    if (imageFiles.isEmpty) {
      return const BatchImageResult(
        processedImages: <ProcessedImage>[],
        successCount: 0,
        failureCount: 0,
      );
    }

    final List<ProcessedImage> processedImages = [];
    final List<String> errors = [];
    int successCount = 0;
    int failureCount = 0;

    for (int i = 0; i < imageFiles.length; i++) {
      final xfile = imageFiles[i];
      try {
        debugPrint('Processing image ${i + 1}/${imageFiles.length}: ${xfile.path}');

        final result = await FileUtils.processImageWithThumbnail(xfile);
        final compressed = result['image']!;
        final thumbnail = result['thumbnail']!;

        // Verify files were created successfully
        if (!await compressed.exists()) {
          throw Exception('Compressed image was not created');
        }
        if (!await thumbnail.exists()) {
          throw Exception('Thumbnail was not created');
        }

        // Verify files are valid
        if (!await FileUtils.verifyImageFile(compressed)) {
          throw Exception('Compressed image is corrupted');
        }
        if (!await FileUtils.verifyImageFile(thumbnail)) {
          throw Exception('Thumbnail is corrupted');
        }

        processedImages.add(ProcessedImage(
          image: compressed,
          thumbnail: thumbnail,
        ));
        successCount++;

        debugPrint('Successfully processed: ${compressed.path}');

        // Add small delay between operations to prevent file system overload
        if (i < imageFiles.length - 1) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Try to delete original file
        try {
          await File(xfile.path).delete();
        } catch (e) {
          debugPrint('Failed to delete original file ${xfile.path}: $e');
        }

      } catch (e) {
        debugPrint('Error processing ${xfile.path}: $e');
        errors.add('Failed to process ${xfile.path}: $e');
        failureCount++;
      }
    }

    return BatchImageResult(
      processedImages: processedImages,
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }

  /// Delete multiple image files safely
  Future<DeleteResult> deleteImages(List<File> images, List<File> thumbnails) async {
    try {
      final allFiles = [...images, ...thumbnails];
      final deletedCount = await FileUtils.deleteFilesSafely(allFiles);

      return DeleteResult(
        requestedCount: allFiles.length,
        deletedCount: deletedCount,
        success: deletedCount == allFiles.length,
      );
    } catch (e) {
      debugPrint('Error deleting images: $e');
      return DeleteResult(
        requestedCount: images.length + thumbnails.length,
        deletedCount: 0,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Cleanup orphaned thumbnails
  Future<int> cleanupOrphanedThumbnails(List<String> validImagePaths) async {
    try {
      await FileUtils.cleanupOrphanedThumbnails(validImagePaths);
      return 0; // FileUtils doesn't return count, but operation succeeded
    } catch (e) {
      debugPrint('Error cleaning up orphaned thumbnails: $e');
      return -1; // Indicate error
    }
  }

  /// Share a single image file
  Future<ShareResult> shareImage(File imageFile) async {
    try {
      // Verify file exists before sharing
      if (!await imageFile.exists()) {
        throw Exception('Image file no longer exists');
      }

      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: 'Shared from Grid',
      );

      return const ShareResult(success: true);
    } catch (e) {
      debugPrint('Error sharing image: $e');
      return ShareResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Load header username from storage
  Future<String> loadHeaderUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_headerUsernameKey) ?? 'tomazdrnovsek';
    } catch (e) {
      debugPrint('Error loading header username: $e');
      return 'tomazdrnovsek';
    }
  }

  /// Save header username to storage
  Future<bool> saveHeaderUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_headerUsernameKey, username);
      return true;
    } catch (e) {
      debugPrint('Error saving header username: $e');
      return false;
    }
  }

  /// Get storage statistics
  Future<StorageStats> getStorageStats() async {
    try {
      final totalBytes = await FileUtils.getTotalStorageUsed();
      final paths = await loadSavedImagePaths();

      return StorageStats(
        totalImages: paths.length,
        totalBytes: totalBytes,
        formattedSize: FileUtils.formatBytes(totalBytes),
      );
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return const StorageStats(
        totalImages: 0,
        totalBytes: 0,
        formattedSize: '0 B',
      );
    }
  }
}

/// Data class for processed image data during loading
class ProcessedImageData {
  final String imagePath;
  final File imageFile;
  final File thumbnailFile;

  const ProcessedImageData({
    required this.imagePath,
    required this.imageFile,
    required this.thumbnailFile,
  });
}

/// Result class for loading photos operation
class LoadPhotosResult {
  final List<File> images;
  final List<File> thumbnails;
  final List<String> validPaths;
  final int migratedCount;
  final int repairedCount;
  final String? error;

  const LoadPhotosResult({
    required this.images,
    required this.thumbnails,
    required this.validPaths,
    required this.migratedCount,
    required this.repairedCount,
    this.error,
  });

  bool get isSuccess => error == null;
  bool get hasMigrations => migratedCount > 0;
  bool get hasRepairs => repairedCount > 0;
}

/// Result class for delete operations
class DeleteResult {
  final int requestedCount;
  final int deletedCount;
  final bool success;
  final String? error;

  const DeleteResult({
    required this.requestedCount,
    required this.deletedCount,
    required this.success,
    this.error,
  });
}

/// Result class for share operations
class ShareResult {
  final bool success;
  final String? error;

  const ShareResult({
    required this.success,
    this.error,
  });
}

/// Storage statistics
class StorageStats {
  final int totalImages;
  final int totalBytes;
  final String formattedSize;

  const StorageStats({
    required this.totalImages,
    required this.totalBytes,
    required this.formattedSize,
  });
}