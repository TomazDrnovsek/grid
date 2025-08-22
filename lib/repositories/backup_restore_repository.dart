// lib/repositories/backup_restore_repository.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/backup_models.dart';
import '../repositories/cloud_manifest_repository.dart' as manifest;
import '../repositories/photo_repository.dart';
import '../repositories/saf_storage_provider.dart' as saf;
import '../services/backup_hasher.dart';
import '../services/performance_monitor.dart';
import '../services/photo_database.dart';
import '../services/thumbnail_service.dart';

/// Main orchestration repository for cloud backup and restore operations.
class BackupRestoreRepository {
  static const String _deviceIdKey = 'device_id';

  final manifest.CloudManifestRepository _manifestRepo;
  final saf.SafStorageProvider _safProvider;
  final PhotoRepository _photoRepo;
  final BackupHasherService _hasher;
  final ThumbnailService _thumbnailService;

  // Operation state - using async* (no private StreamController)
  final Map<String, CancelToken> _cancellationTokens = {};

  BackupRestoreRepository(
      this._manifestRepo,
      this._safProvider,
      this._photoRepo,
      this._hasher,
      this._thumbnailService,
      );

  /// Performs a complete backup of all photos to cloud storage.
  /// Returns a stream of backup state updates for UI progress tracking.
  Stream<BackupState> performBackup({
    BackupConfig config = const BackupConfig(),
    String? operationId,
  }) async* {
    final id = operationId ?? 'backup_${DateTime.now().millisecondsSinceEpoch}';
    final cancelToken = CancelToken();
    _cancellationTokens[id] = cancelToken;

    try {
      if (kDebugMode) {
        debugPrint('[BackupRestore] Starting backup operation: $id');
      }

      PerformanceMonitor.instance.startOperation('cloud_backup');
      final startTime = DateTime.now();

      // Phase 1: Preflight checks
      yield const BackupState(
        status: BackupStatus.running,
        phase: BackupPhase.backingUp,
        current: 0,
        total: 0,
      );

      final preflightResult = await _performPreflight(config, cancelToken);
      if (!preflightResult.success) {
        yield BackupState(
          status: BackupStatus.error,
          error: preflightResult.error ?? 'Preflight check failed',
        );
        return;
      }

      await _manifestRepo.cleanupOldBackupFiles();

      // Phase 2: Load photos from database
      final loadResult = await _photoRepo.loadAllSavedPhotos();
      if (!loadResult.isSuccess) {
        yield BackupState(
          status: BackupStatus.error,
          error: loadResult.error ?? 'Failed to load photos',
        );
        return;
      }

      final photos = loadResult.images;
      if (photos.isEmpty) {
        yield const BackupState(
          status: BackupStatus.success,
          current: 0,
          total: 0,
        );
        return;
      }

      if (kDebugMode) {
        debugPrint('[BackupRestore] Found ${photos.length} photos to backup');
      }

      // Get cloud folder URI
      final cloudFolder = await _safProvider.getCloudFolderUri();
      if (cloudFolder == null) {
        yield const BackupState(
          status: BackupStatus.error,
          error: 'No cloud folder configured',
        );
        return;
      }

      // Compute total bytes once (for byte-based progress)
      final totalBytes = await _calculateTotalBytes(photos);

      final results = <ProcessResult>[];
      var completedCount = 0;
      var processedBytes = 0;

      // Initial running state
      yield BackupState(
        status: BackupStatus.running,
        phase: BackupPhase.backingUp,
        current: 0,
        total: photos.length,
        bytesProcessed: 0,
        totalBytes: totalBytes,
      );

      // Sequential loop (stable, easy progress updates)
      for (final photo in photos) {
        if (cancelToken.isCancelled) {
          yield const BackupState(
            status: BackupStatus.error,
            error: 'Operation cancelled',
          );
          return;
        }

        // Show what we're working on
        yield BackupState(
          status: BackupStatus.running,
          phase: BackupPhase.backingUp,
          current: completedCount,
          total: photos.length,
          bytesProcessed: processedBytes,
          totalBytes: totalBytes,
          currentFile: path.basename(photo.path),
        );

        final result =
        await _processPhoto(photo, cloudFolder, config, cancelToken);
        results.add(result);

        completedCount++;
        try {
          processedBytes += await photo.length();
        } catch (_) {
          // ignore per-file length failure; totalBytes still OK
        }

        // Per-item progress update
        yield BackupState(
          status: BackupStatus.running,
          phase: BackupPhase.backingUp,
          current: completedCount,
          total: photos.length,
          bytesProcessed: processedBytes,
          totalBytes: totalBytes,
        );
      }

      if (cancelToken.isCancelled) {
        yield const BackupState(
          status: BackupStatus.error,
          error: 'Operation cancelled',
        );
        return;
      }

      // Phase 4: Write manifest
      yield BackupState(
        status: BackupStatus.running,
        phase: BackupPhase.backingUp,
        current: photos.length,
        total: photos.length,
        bytesProcessed: processedBytes,
        totalBytes: totalBytes,
        currentFile: 'Writing manifest...',
      );

      final manifestObj = await _createBackupManifest(
        results
            .where((r) => r.isSuccess && r.item != null)
            .map((r) => r.item!)
            .toList(),
      );

      await _manifestRepo.writeManifest(manifestObj);

      // Save last backup date
      await _safProvider.saveLastBackupDate(DateTime.now());

      // Final success state
      final processingTime = DateTime.now().difference(startTime);
      final successCount = results.where((r) => r.isSuccess).length;
      final failureCount = results.where((r) => !r.isSuccess).length;

      yield BackupState(
        status: BackupStatus.success,
        phase: BackupPhase.backingUp,
        current: photos.length,
        total: photos.length,
        bytesProcessed: processedBytes,
        totalBytes: totalBytes,
        lastResult: BackupResult(
          operationsProcessed: photos.length,
          successCount: successCount,
          failureCount: failureCount,
          processingTime: processingTime,
          errors: results
              .where((r) => !r.isSuccess && r.error != null)
              .map((r) => r.error!)
              .toList(),
          warnings: const [],
        ),
      );

      if (kDebugMode) {
        debugPrint(
            '[BackupRestore] Backup completed: $successCount/${photos.length} photos');
      }
    } catch (e) {
      yield BackupState(
        status: BackupStatus.error,
        error: 'Backup failed: ${e.toString()}',
      );

      if (kDebugMode) {
        debugPrint('[BackupRestore] Backup error: $e');
      }
    } finally {
      // Cleanup
      PerformanceMonitor.instance.endOperation('cloud_backup');
      _cancellationTokens.remove(id);
    }
  }

  /// Performs a complete restore from cloud storage.
  /// Properly yields progress updates and restores both originals and thumbnails.
  Stream<BackupState> performRestore({
    BackupConfig config = const BackupConfig(),
    String? operationId,
  }) async* {
    final id = operationId ?? 'restore_${DateTime.now().millisecondsSinceEpoch}';
    final cancelToken = CancelToken();
    _cancellationTokens[id] = cancelToken;

    try {
      if (kDebugMode) {
        debugPrint('[BackupRestore] Starting restore operation: $id');
      }

      PerformanceMonitor.instance.startOperation('cloud_restore');

      // Phase 1: Preflight
      yield const BackupState(
        status: BackupStatus.running,
        phase: BackupPhase.restoring,
        current: 0,
        total: 0,
      );

      final preflightResult = await _performPreflight(config, cancelToken);
      if (!preflightResult.success) {
        yield BackupState(
          status: BackupStatus.error,
          error: preflightResult.error ?? 'Preflight check failed',
        );
        return;
      }

      // Phase 2: Read manifest
      final manifestObj = await _manifestRepo.readManifest();
      if (manifestObj == null) {
        yield const BackupState(
          status: BackupStatus.error,
          error: 'No backup manifest found in cloud storage',
        );
        return;
      }

      final manifestItems = manifestObj.items;
      if (manifestItems.isEmpty) {
        yield const BackupState(
          status: BackupStatus.success,
          current: 0,
          total: 0,
        );
        return;
      }

      if (kDebugMode) {
        debugPrint('[BackupRestore] Found ${manifestItems.length} items in manifest');
      }

      // Get cloud folder URI
      final cloudFolder = await _safProvider.getCloudFolderUri();
      if (cloudFolder == null) {
        yield const BackupState(
          status: BackupStatus.error,
          error: 'No cloud folder configured',
        );
        return;
      }

      final totalBytes = manifestItems.fold<int>(0, (sum, item) => sum + item.byteSize);

      final results = <ProcessResult>[];
      var completedCount = 0;
      var processedBytes = 0;

      // Initial running state
      yield BackupState(
        status: BackupStatus.running,
        phase: BackupPhase.restoring,
        current: 0,
        total: manifestItems.length,
        bytesProcessed: 0,
        totalBytes: totalBytes,
      );

      // Restore each item from cloud
      for (final item in manifestItems) {
        if (cancelToken.isCancelled) {
          yield const BackupState(
            status: BackupStatus.error,
            error: 'Operation cancelled',
          );
          return;
        }

        // Show what we're working on
        yield BackupState(
          status: BackupStatus.running,
          phase: BackupPhase.restoring,
          current: completedCount,
          total: manifestItems.length,
          bytesProcessed: processedBytes,
          totalBytes: totalBytes,
          currentFile: path.basename(item.relativePath),
        );

        final result =
        await _restorePhoto(item, cloudFolder, config, cancelToken);
        results.add(result);

        completedCount++;
        processedBytes += item.byteSize;

        // Per-item progress update
        yield BackupState(
          status: BackupStatus.running,
          phase: BackupPhase.restoring,
          current: completedCount,
          total: manifestItems.length,
          bytesProcessed: processedBytes,
          totalBytes: totalBytes,
        );
      }

      if (cancelToken.isCancelled) {
        yield const BackupState(
          status: BackupStatus.error,
          error: 'Operation cancelled',
        );
        return;
      }

      // Phase 4: Update database
      yield BackupState(
        status: BackupStatus.running,
        phase: BackupPhase.restoring,
        current: manifestItems.length,
        total: manifestItems.length,
        bytesProcessed: processedBytes,
        totalBytes: totalBytes,
        currentFile: 'Updating database...',
      );

      await _updateDatabaseFromRestore(results, manifestItems);

      // Final success state
      final successCount = results.where((r) => r.isSuccess).length;
      final failureCount = results.where((r) => !r.isSuccess).length;

      yield BackupState(
        status: BackupStatus.success,
        phase: BackupPhase.restoring,
        current: manifestItems.length,
        total: manifestItems.length,
        bytesProcessed: processedBytes,
        totalBytes: totalBytes,
        lastResult: BackupResult(
          operationsProcessed: manifestItems.length,
          successCount: successCount,
          failureCount: failureCount,
          processingTime: const Duration(seconds: 0), // Will be set by caller
          errors: results
              .where((r) => !r.isSuccess && r.error != null)
              .map((r) => r.error!)
              .toList(),
          warnings: const [],
        ),
      );

      if (kDebugMode) {
        debugPrint(
            '[BackupRestore] Restore completed: $successCount/${manifestItems.length} items');
      }
    } catch (e) {
      yield BackupState(
        status: BackupStatus.error,
        error: 'Restore failed: ${e.toString()}',
      );

      if (kDebugMode) {
        debugPrint('[BackupRestore] Restore error: $e');
      }
    } finally {
      // Cleanup
      PerformanceMonitor.instance.endOperation('cloud_restore');
      _cancellationTokens.remove(id);
    }
  }

  /// Cancel a running operation
  void cancelOperation(String operationId) {
    final token = _cancellationTokens[operationId];
    if (token != null) {
      token.cancel();
      if (kDebugMode) {
        debugPrint('[BackupRestore] Cancelled operation: $operationId');
      }
    }
  }

  /// Get backup status information
  Future<CloudBackupStatus> getBackupStatus() async {
    try {
      // Check if manifest exists
      final manifestExists = await _manifestRepo.manifestExists();
      if (!manifestExists) {
        return const CloudBackupStatus(hasBackup: false);
      }

      // Read manifest to get basic info
      final manifest = await _manifestRepo.readManifest();
      if (manifest == null) {
        return const CloudBackupStatus(hasBackup: false);
      }

      // Get last backup date from SAF storage
      final lastBackupDate = await _safProvider.getLastBackupDate();

      return CloudBackupStatus(
        hasBackup: true,
        itemCount: manifest.items.length,
        lastBackupDate: lastBackupDate ?? manifest.exportedAt,
        deviceId: manifest.deviceId,
        appVersion: manifest.appVersion,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BackupRestore] Error getting backup status: $e');
      }
      return const CloudBackupStatus(hasBackup: false);
    }
  }

  /// Calculate total bytes for progress tracking
  Future<int> _calculateTotalBytes(List<File> photos) async {
    var total = 0;
    for (final photo in photos) {
      try {
        total += await photo.length();
      } catch (e) {
        // Skip files that can't be accessed
        if (kDebugMode) {
          debugPrint('[BackupRestore] Could not get file size for ${photo.path}: $e');
        }
      }
    }
    return total;
  }

  /// Process a single photo for backup
  Future<ProcessResult> _processPhoto(
      File photo,
      String cloudFolder,
      BackupConfig config,
      CancelToken cancelToken,
      ) async {
    if (cancelToken.isCancelled) {
      return ProcessResult(isSuccess: false, error: 'Operation cancelled');
    }

    try {
      final fileName = path.basename(photo.path);
      final fileDate = await photo.lastModified();
      final fileSize = await photo.length();

      // Create date-based folder structure
      final dateFolder = _safProvider.getDateBasedPath(fileDate);

      // Backup original
      final originalPath = 'originals/$dateFolder/$fileName';
      final originalWritten = await _safProvider.writeFileStreamed(
        cloudFolder,
        originalPath,
        photo.openRead(),
        fileSize,
      );

      if (!originalWritten) {
        return ProcessResult(
          isSuccess: false,
          error: 'Failed to write original file',
        );
      }

      // Generate hash
      final hash = await _hasher.computeFileHashInIsolate(photo.path);

      // Backup thumbnail if enabled
      String? thumbPath;
      if (config.includeThumbnails) {
        try {
          final thumbFileName =
              '${path.basenameWithoutExtension(fileName)}.webp';
          thumbPath = 'thumbs/$dateFolder/$thumbFileName';

          final thumbFile =
          await _thumbnailService.generateImmediately(photo.path);
          if (thumbFile != null && await thumbFile.exists()) {
            final thumbSize = await thumbFile.length();
            final thumbWritten = await _safProvider.writeFileStreamed(
              cloudFolder,
              thumbPath,
              thumbFile.openRead(),
              thumbSize,
            );

            if (!thumbWritten) {
              thumbPath = null;
            }
          } else {
            thumbPath = null;
          }
        } catch (e) {
          thumbPath = null;
        }
      }

      // Get photo metadata from database for UUID and sortIndex
      String photoId;
      var sortIndex = 0;

      try {
        // Access the PhotoDatabase directly to get photo metadata
        final photoDb = PhotoDatabase();
        final photoEntry = await photoDb.getPhotoByPath(photo.path);

        if (photoEntry != null && photoEntry.uuid != null) {
          photoId = photoEntry.uuid!;
          sortIndex = photoEntry.orderIndex;
        } else {
          // Generate a fallback ID if no UUID found
          photoId =
          'photo_${DateTime.now().millisecondsSinceEpoch}_${photo.path.hashCode}';
        }
      } catch (e) {
        // Fallback ID if database lookup fails
        photoId =
        'photo_${DateTime.now().millisecondsSinceEpoch}_${photo.path.hashCode}';
        if (kDebugMode) {
          debugPrint('[BackupRestore] Could not get photo UUID: $e');
        }
      }

      // Create backup item with UUID and sortIndex
      final backupItem = BackupItem(
        id: photoId,
        relativePath: originalPath,
        thumbPath: thumbPath ?? '',
        checksumSha256: hash,
        byteSize: fileSize,
        createdAt: fileDate,
        width: 0, // TODO: Extract from EXIF if available
        height: 0, // TODO: Extract from EXIF if available
        sortIndex: sortIndex,
      );

      return ProcessResult(
        isSuccess: true,
        item: backupItem,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BackupRestore] Error processing photo ${photo.path}: $e');
      }
      return ProcessResult(
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// Restore a single photo from backup - handles thumbnails too.
  Future<ProcessResult> _restorePhoto(
      BackupItem item,
      String cloudFolder,
      BackupConfig config,
      CancelToken cancelToken,
      ) async {
    if (cancelToken.isCancelled) {
      return ProcessResult(isSuccess: false, error: 'Operation cancelled');
    }

    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      // Restore original file
      final fileName = path.basename(item.relativePath);
      final localFile = File('${photosDir.path}/$fileName');

      // NOTE: copyFromCloudToLocal may return String?; guard for null/empty.
      final String? copiedPath = await _safProvider.copyFromCloudToLocal(
        cloudFolder,
        item.relativePath,
        localFile.path,
      );

      if (copiedPath == null || copiedPath.isEmpty) {
        return ProcessResult(
          isSuccess: false,
          error: 'Failed to restore ${item.relativePath}',
        );
      }

      // Restore thumbnail if it exists and config allows
      if (config.includeThumbnails && item.thumbPath.isNotEmpty) {
        try {
          final thumbsDir = Directory('${appDir.path}/thumbnails');
          if (!await thumbsDir.exists()) {
            await thumbsDir.create(recursive: true);
          }

          final thumbFileName = path.basename(item.thumbPath);
          final localThumbFile = File('${thumbsDir.path}/$thumbFileName');

          final String? thumbCopiedPath = await _safProvider.copyFromCloudToLocal(
            cloudFolder,
            item.thumbPath,
            localThumbFile.path,
          );

          if ((thumbCopiedPath == null || thumbCopiedPath.isEmpty) &&
              kDebugMode) {
            debugPrint(
                '[BackupRestore] Failed to restore thumbnail for ${item.relativePath}');
          }
        } catch (e) {
          // Thumbnail restore failure is non-fatal
          if (kDebugMode) {
            debugPrint('[BackupRestore] Error restoring thumbnail: $e');
          }
        }
      }

      return ProcessResult(
        isSuccess: true,
        item: item,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BackupRestore] Error restoring ${item.relativePath}: $e');
      }
      return ProcessResult(
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// 🔧 FIXED: Update database with restored photos and apply sort order correctly.
  /// This is the key fix for the photo order reversal issue.
  Future<void> _updateDatabaseFromRestore(
      List<ProcessResult> results,
      List<BackupItem> manifestItems,
      ) async {
    try {
      final successfulResults =
      results.where((r) => r.isSuccess && r.item != null);

      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/photos');
      final thumbsDir = Directory('${appDir.path}/thumbnails');

      // Access the PhotoDatabase directly for UUID operations
      final photoDb = PhotoDatabase();

      // 🔧 CRITICAL FIX: Instead of using addPhotosToDatabase (which auto-reorders),
      // we manually insert photos with their correct order indices from the manifest.
      final existingUuids = <String>{};

      for (final result in successfulResults) {
        final item = result.item!;
        final fileName = path.basename(item.relativePath);
        final imageFile = File('${photosDir.path}/$fileName');

        if (await imageFile.exists()) {
          // Check if this UUID already exists in the database
          final existingPhoto = await photoDb.getPhotoByUuid(item.id);
          if (existingPhoto != null) {
            existingUuids.add(item.id);

            // Update the existing photo's path and order if it changed
            if (existingPhoto.imagePath != imageFile.path ||
                existingPhoto.orderIndex != item.sortIndex) {
              await photoDb.updatePhoto(
                existingPhoto.copyWith(
                  imagePath: imageFile.path,
                  orderIndex: item.sortIndex,
                ),
              );
            }
          } else {
            // 🔧 CRITICAL FIX: Insert new photo directly with correct order index
            // instead of using addPhotosToDatabase which would reorder everything
            File? thumbnailFile;
            if (item.thumbPath.isNotEmpty) {
              final thumbFileName = path.basename(item.thumbPath);
              thumbnailFile = File('${thumbsDir.path}/$thumbFileName');
              if (!await thumbnailFile.exists()) {
                thumbnailFile = null;
              }
            }

            // If we don't have a thumbnail, use the original for now.
            thumbnailFile ??= imageFile;

            // Get file info
            final fileSize = await imageFile.length();
            final originalName = imageFile.path.split('/').last;

            // Create database entry with exact sort index from manifest
            final entry = PhotoDatabaseEntry(
              uuid: item.id, // Use UUID from manifest
              imagePath: imageFile.path,
              thumbnailPath: thumbnailFile.path,
              originalName: originalName,
              fileSize: fileSize,
              width: item.width,
              height: item.height,
              dateAdded: item.createdAt,
              orderIndex: item.sortIndex, // 🔧 CRITICAL: Use exact order from manifest
              isFavorite: false,
              tags: const <String>[],
            );

            // Insert directly without automatic reordering
            await photoDb.insertPhoto(entry);

            if (kDebugMode) {
              debugPrint('[BackupRestore] Inserted photo with UUID: ${item.id}, order: ${item.sortIndex}');
            }
          }
        }
      }

      // 🔧 NOTE: We removed the automatic photo reordering that was causing the issue.
      // Photos are now inserted with their exact order indices from the manifest.

      if (kDebugMode) {
        final newPhotosCount = successfulResults.length - existingUuids.length;
        debugPrint(
            '[BackupRestore] Database update complete: $newPhotosCount new, ${existingUuids.length} existing');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BackupRestore] Error updating database: $e');
      }
      // Don't throw - database update failure shouldn't fail the restore
    }
  }

  /// Perform preflight validation before backup
  Future<ValidationResult> _performPreflight(
      BackupConfig config, CancelToken cancelToken) async {
    try {
      final cloudFolder = await _safProvider.getCloudFolderUri();
      if (cloudFolder == null) {
        return const ValidationResult(
          success: false,
          error: 'No cloud folder configured',
        );
      }

      // Ensure required directories exist
      await _safProvider.makeDirectories(cloudFolder, 'meta');
      await _safProvider.makeDirectories(cloudFolder, 'originals');
      await _safProvider.makeDirectories(cloudFolder, 'thumbs');

      return const ValidationResult(success: true);
    } catch (e) {
      return ValidationResult(
        success: false,
        error: 'Preflight failed: ${e.toString()}',
      );
    }
  }

  /// Create backup manifest from processed items
  Future<BackupManifest> _createBackupManifest(List<BackupItem> items) async {
    final deviceId = await _getOrCreateDeviceId();

    return BackupManifest(
      version: 1,
      exportedAt: DateTime.now(),
      deviceId: deviceId,
      appVersion: Constants.appVersion,
      items: items,
      metadata: {
        'totalItems': items.length,
        'totalBytes':
        items.fold<int>(0, (sum, item) => sum + item.byteSize),
        'device': deviceId,
      },
    );
  }

  /// Get or create device ID
  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId =
      'device_${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().hashCode}';
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }
}

/// Helper classes for operation management

/// Token for cancelling operations
class CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

/// Result of processing a single item
class ProcessResult {
  final bool isSuccess;
  final BackupItem? item;
  final String? error;

  const ProcessResult({
    required this.isSuccess,
    this.item,
    this.error,
  });
}

/// Configuration for backup operations
class BackupConfig {
  final bool includeThumbnails;

  const BackupConfig({
    this.includeThumbnails = true,
  });
}

/// Configuration for restore operations
class RestoreConfig {
  final bool includeThumbnails;

  const RestoreConfig({
    this.includeThumbnails = true,
  });
}

/// Validation result for preflight checks
class ValidationResult {
  final bool success;
  final String? error;

  const ValidationResult({
    required this.success,
    this.error,
  });
}

/// Cloud backup information class
class CloudBackupStatus {
  final bool hasBackup;
  final int? itemCount;
  final DateTime? lastBackupDate;
  final String? deviceId;
  final String? appVersion;

  const CloudBackupStatus({
    required this.hasBackup,
    this.itemCount,
    this.lastBackupDate,
    this.deviceId,
    this.appVersion,
  });
}