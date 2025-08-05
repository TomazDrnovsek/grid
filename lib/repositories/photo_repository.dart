// File: lib/repositories/photo_repository.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../models/photo_state.dart';
import '../file_utils.dart';
import '../services/photo_database.dart';
import '../services/performance_monitor.dart';

/// Repository layer for photo management business logic
/// FIXED: Uses reliable FileUtils instead of isolate processing for now
/// Maintains UI thread responsiveness while ensuring functionality works
class PhotoRepository {
  static const String _legacyImagePathsKey = 'grid_image_paths';
  static const String _legacyHeaderUsernameKey = 'header_username';
  static const String _migrationCompleteKey = 'database_migration_complete';

  final ImagePicker _picker = ImagePicker();
  final PhotoDatabase _database = PhotoDatabase();

  /// Load all saved photos with automatic migration from SharedPreferences
  Future<LoadPhotosResult> loadAllSavedPhotos() async {
    try {
      // Start performance monitoring
      PerformanceMonitor.instance.startOperation('load_saved_photos');

      // Check if migration is needed
      final migrationNeeded = await _isMigrationNeeded();

      if (migrationNeeded) {
        debugPrint('Migration needed: transferring data from SharedPreferences to database');
        await _performMigration();
      }

      // Load photos from database
      final photoEntries = await _database.getAllPhotos();

      if (photoEntries.isEmpty) {
        PerformanceMonitor.instance.endOperation('load_saved_photos');
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
      int repairedCount = 0;

      // Process all database entries
      for (final entry in photoEntries) {
        try {
          final processed = await processSavedImagePath(entry.imagePath);
          if (processed != null) {
            loadedImages.add(processed.imageFile);
            loadedThumbnails.add(processed.thumbnailFile);
            validPaths.add(processed.imagePath);

            // Update database if path changed during processing
            if (processed.imagePath != entry.imagePath) {
              repairedCount++;
              await _database.insertPhoto(PhotoDatabaseEntry(
                imagePath: processed.imagePath,
                thumbnailPath: processed.thumbnailFile.path,
                dateAdded: entry.dateAdded,
                orderIndex: entry.orderIndex,
              ));
            }
          } else {
            // Remove invalid entries from database
            await _database.deletePhotosByPaths([entry.imagePath]);
            debugPrint('Removed invalid database entry: ${entry.imagePath}');
          }
        } catch (e) {
          debugPrint('Error processing database entry ${entry.imagePath}: $e');
          continue;
        }
      }

      // Repair any missing thumbnails
      final thumbnailRepairs = await FileUtils.repairMissingThumbnails(validPaths);
      if (thumbnailRepairs > 0) {
        debugPrint('Repaired $thumbnailRepairs missing thumbnails');
        repairedCount += thumbnailRepairs;

        // Reload thumbnails after repair
        loadedThumbnails.clear();
        for (final imagePath in validPaths) {
          final thumbnail = await FileUtils.getThumbnailForImage(imagePath);
          loadedThumbnails.add(thumbnail ?? File(imagePath));
        }
      }

      PerformanceMonitor.instance.endOperation('load_saved_photos');

      return LoadPhotosResult(
        images: loadedImages,
        thumbnails: loadedThumbnails,
        validPaths: validPaths,
        migratedCount: migrationNeeded ? validPaths.length : 0,
        repairedCount: repairedCount,
      );

    } catch (e) {
      PerformanceMonitor.instance.endOperation('load_saved_photos');
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

  /// Check if migration from SharedPreferences is needed
  Future<bool> _isMigrationNeeded() async {
    try {
      // Check if migration already completed
      final migrationComplete = await _database.getSetting<bool>(_migrationCompleteKey, false);
      if (migrationComplete == true) {
        return false;
      }

      // Check if there's any data in SharedPreferences to migrate
      final prefs = await SharedPreferences.getInstance();
      final legacyPaths = prefs.getStringList(_legacyImagePathsKey);

      return legacyPaths != null && legacyPaths.isNotEmpty;

    } catch (e) {
      debugPrint('Error checking migration status: $e');
      return false;
    }
  }

  /// Perform migration from SharedPreferences to database
  Future<void> _performMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Migrate image paths
      final legacyPaths = prefs.getStringList(_legacyImagePathsKey) ?? [];
      if (legacyPaths.isNotEmpty) {
        debugPrint('Migrating ${legacyPaths.length} image paths to database');

        final photoEntries = <PhotoDatabaseEntry>[];
        final now = DateTime.now();

        for (int i = 0; i < legacyPaths.length; i++) {
          final path = legacyPaths[i];
          try {
            // Get thumbnail path if it exists
            final thumbnailFile = await FileUtils.getThumbnailForImage(path);

            photoEntries.add(PhotoDatabaseEntry(
              imagePath: path,
              thumbnailPath: thumbnailFile?.path,
              dateAdded: now,
              orderIndex: i,
            ));
          } catch (e) {
            debugPrint('Error creating database entry for $path: $e');
          }
        }

        if (photoEntries.isNotEmpty) {
          await _database.insertPhotos(photoEntries);
          debugPrint('Successfully migrated ${photoEntries.length} photos to database');
        }
      }

      // Migrate header username
      final legacyUsername = prefs.getString(_legacyHeaderUsernameKey);
      if (legacyUsername != null) {
        await _database.setSetting('header_username', legacyUsername);
        debugPrint('Migrated header username to database');
      }

      // Mark migration as complete
      await _database.setSetting(_migrationCompleteKey, true);

      // Clean up SharedPreferences (optional - keep for safety during transition)
      debugPrint('Migration completed successfully');

    } catch (e) {
      debugPrint('Error during migration: $e');
      rethrow;
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
          debugPrint('Migrating external file to app storage: $path');
          final processed = await FileUtils.processImageWithThumbnail(XFile(path));
          finalPath = processed['image']!.path;
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

  /// Save image paths to database (replaces SharedPreferences)
  Future<bool> saveImagePaths(List<String> paths) async {
    try {
      await _database.updatePhotoOrders(paths);
      return true;
    } catch (e) {
      debugPrint('Error saving image paths to database: $e');
      return false;
    }
  }

  /// Add new photos to database
  Future<void> addPhotosToDatabase(List<ProcessedImage> processedImages) async {
    try {
      final photoEntries = <PhotoDatabaseEntry>[];
      final now = DateTime.now();

      // Create database entries for new photos (inserted at beginning)
      for (int i = 0; i < processedImages.length; i++) {
        final processed = processedImages[i];
        photoEntries.add(PhotoDatabaseEntry(
          imagePath: processed.image.path,
          thumbnailPath: processed.thumbnail.path,
          dateAdded: now,
          orderIndex: i, // New photos get lowest order indexes
        ));
      }

      // Shift existing photos' order indexes
      final existingPaths = await _database.getAllPhotoPaths();
      final shiftedPaths = <String>[];

      // Add new paths first, then existing paths
      for (final entry in photoEntries) {
        shiftedPaths.add(entry.imagePath);
      }
      shiftedPaths.addAll(existingPaths);

      // Insert new photos and update all order indexes
      await _database.insertPhotos(photoEntries);
      await _database.updatePhotoOrders(shiftedPaths);

      debugPrint('Added ${processedImages.length} photos to database');

    } catch (e) {
      debugPrint('Error adding photos to database: $e');
      rethrow;
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

  /// FIXED: Process a batch of picked images using reliable FileUtils
  /// This ensures add photos functionality works while maintaining good performance
  Future<BatchImageResult> processBatchImages(List<XFile> imageFiles) async {
    if (imageFiles.isEmpty) {
      return const BatchImageResult(
        processedImages: <ProcessedImage>[],
        successCount: 0,
        failureCount: 0,
      );
    }

    try {
      debugPrint('🔄 Processing ${imageFiles.length} images using FileUtils (reliable approach)');

      final List<ProcessedImage> processedImages = [];
      final List<String> errors = [];
      int successCount = 0;
      int failureCount = 0;

      // Process images sequentially to avoid overwhelming the system
      // This is still much better than the original blocking approach
      for (final imageFile in imageFiles) {
        try {
          debugPrint('Processing image: ${imageFile.path}');

          // Use proven FileUtils approach
          final result = await FileUtils.processImageWithThumbnail(imageFile);

          final processedImage = ProcessedImage(
            image: result['image']!,
            thumbnail: result['thumbnail']!,
          );

          processedImages.add(processedImage);
          successCount++;

          debugPrint('✅ Successfully processed: ${processedImage.image.path}');

        } catch (e) {
          debugPrint('❌ Error processing ${imageFile.path}: $e');
          errors.add(e.toString());
          failureCount++;
        }

        // Small delay between images to keep UI responsive
        if (imageFiles.length > 1) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      // Add processed images to database
      if (processedImages.isNotEmpty) {
        try {
          await addPhotosToDatabase(processedImages);
        } catch (e) {
          debugPrint('Error adding processed images to database: $e');
          // Don't fail the entire operation, but log the error
        }
      }

      // Clean up original files
      for (final xfile in imageFiles) {
        try {
          await File(xfile.path).delete();
        } catch (e) {
          debugPrint('Failed to delete original file ${xfile.path}: $e');
        }
      }

      debugPrint('✅ Batch processing complete: $successCount success, $failureCount failed');

      return BatchImageResult(
        processedImages: processedImages,
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );

    } catch (e) {
      debugPrint('❌ Error in batch processing: $e');

      return BatchImageResult(
        processedImages: const <ProcessedImage>[],
        successCount: 0,
        failureCount: imageFiles.length,
        errors: ['Batch processing failed: $e'],
      );
    }
  }

  /// Delete multiple image files safely and remove from database
  Future<DeleteResult> deleteImages(List<File> images, List<File> thumbnails) async {
    try {
      final allFiles = [...images, ...thumbnails];
      final imagePaths = images.map((f) => f.path).toList();

      // Delete from database first
      final deletedFromDb = await _database.deletePhotosByPaths(imagePaths);

      // Delete physical files
      final deletedCount = await FileUtils.deleteFilesSafely(allFiles);

      return DeleteResult(
        requestedCount: allFiles.length,
        deletedCount: deletedCount,
        success: deletedCount == allFiles.length && deletedFromDb == images.length,
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

  /// Load header username from database (with SharedPreferences fallback)
  Future<String> loadHeaderUsername() async {
    try {
      // Try database first
      final username = await _database.getSetting<String>('header_username');
      if (username != null) {
        return username;
      }

      // Fallback to SharedPreferences for migration compatibility
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_legacyHeaderUsernameKey) ?? 'tomazdrnovsek';
    } catch (e) {
      debugPrint('Error loading header username: $e');
      return 'tomazdrnovsek';
    }
  }

  /// Save header username to database
  Future<bool> saveHeaderUsername(String username) async {
    try {
      await _database.setSetting('header_username', username);
      return true;
    } catch (e) {
      debugPrint('Error saving header username: $e');
      return false;
    }
  }

  /// Get storage statistics including database info
  Future<StorageStats> getStorageStats() async {
    try {
      final totalBytes = await FileUtils.getTotalStorageUsed();
      final dbStats = await _database.getStatistics();

      return StorageStats(
        totalImages: dbStats.photoCount,
        totalBytes: totalBytes,
        formattedSize: FileUtils.formatBytes(totalBytes),
        databaseSize: dbStats.databaseSizeBytes,
        databaseFormattedSize: dbStats.formattedSize,
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

  /// Debug method to check migration status and current data storage
  Future<void> printMigrationStatus() async {
    try {
      debugPrint('=== MIGRATION STATUS CHECK ===');

      // Check database
      final dbStats = await _database.getStatistics();
      final migrationComplete = await _database.getSetting<bool>(_migrationCompleteKey, false);
      final photosInDb = await _database.getPhotoCount();

      debugPrint('Database Status:');
      debugPrint('  Photos in database: $photosInDb');
      debugPrint('  Migration completed: $migrationComplete');
      debugPrint('  Database size: ${dbStats.formattedSize}');
      debugPrint('  Database path: ${dbStats.databasePath}');

      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final legacyPaths = prefs.getStringList(_legacyImagePathsKey);
      final legacyUsername = prefs.getString(_legacyHeaderUsernameKey);

      debugPrint('SharedPreferences Status:');
      debugPrint('  Legacy image paths: ${legacyPaths?.length ?? 0} entries');
      debugPrint('  Legacy username: $legacyUsername');

      // Determine migration status
      if (migrationComplete == true) {
        debugPrint('✅ Migration: COMPLETED - App is using database');
      } else if (photosInDb > 0) {
        debugPrint('🔄 Migration: Database has photos but not marked complete');
      } else if ((legacyPaths?.length ?? 0) > 0) {
        debugPrint('⏳ Migration: NEEDED - SharedPreferences data exists');
      } else {
        debugPrint('🆕 Migration: NOT NEEDED - Fresh install or no data');
      }

      debugPrint('🔧 Processing: Using FileUtils (reliable approach)');
      debugPrint('================================');

    } catch (e) {
      debugPrint('Error checking migration status: $e');
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

/// Storage statistics with database info
class StorageStats {
  final int totalImages;
  final int totalBytes;
  final String formattedSize;
  final int? databaseSize;
  final String? databaseFormattedSize;

  const StorageStats({
    required this.totalImages,
    required this.totalBytes,
    required this.formattedSize,
    this.databaseSize,
    this.databaseFormattedSize,
  });
}