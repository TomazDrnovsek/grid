// lib/repositories/cloud_manifest_repository.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/backup_models.dart';
import 'saf_storage_provider.dart';

/// Repository for managing backup manifest operations with atomic writes
/// and comprehensive validation. Handles the critical manifest.json file
/// that preserves photo metadata and order during cloud backup/restore.
class CloudManifestRepository {
  static const String _manifestFileName = 'manifest.json';
  static const String _manifestTempFileName = 'manifest.json.tmp';
  static const int _currentManifestVersion = 1;
  static const int _maxManifestSizeMB = 50; // Reasonable limit for large libraries

  final SafStorageProvider _safProvider;

  CloudManifestRepository(this._safProvider);

  /// Gets the cloud folder URI, throwing if not configured
  Future<String> _getRequiredCloudUri() async {
    final uri = await _safProvider.getCloudFolderUri();
    if (uri == null || uri.isEmpty) {
      throw const CloudManifestException('Cloud folder not configured');
    }
    return uri;
  }

  /// Reads and validates manifest from cloud storage
  /// Returns null if manifest doesn't exist (first backup scenario)
  Future<BackupManifest?> readManifest() async {
    try {
      if (kDebugMode) {
        debugPrint('[CloudManifest] Reading manifest from cloud storage');
      }

      final uri = await _getRequiredCloudUri();

      // Check if manifest exists
      final manifestExists = await _safProvider.exists(uri, _manifestFileName);
      if (!manifestExists) {
        if (kDebugMode) {
          debugPrint('[CloudManifest] No existing manifest found - first backup scenario');
        }
        return null;
      }

      // Read manifest content
      final manifestData = await _safProvider.readFile(uri, _manifestFileName);
      if (manifestData == null || manifestData.isEmpty) {
        throw const CloudManifestException('Manifest file is empty or unreadable');
      }

      // Validate size before parsing
      final sizeInMB = manifestData.length / (1024 * 1024);
      if (sizeInMB > _maxManifestSizeMB) {
        throw CloudManifestException(
            'Manifest file too large: ${sizeInMB.toStringAsFixed(1)}MB (max: ${_maxManifestSizeMB}MB)'
        );
      }

      // Parse JSON
      final jsonString = utf8.decode(manifestData);
      final Map<String, dynamic> jsonData;

      try {
        jsonData = json.decode(jsonString) as Map<String, dynamic>;
      } on FormatException catch (e) {
        throw CloudManifestException('Invalid JSON format: ${e.message}');
      }

      // Validate and deserialize
      final manifest = _deserializeManifest(jsonData);
      final validation = _validateManifest(manifest);

      if (!validation.isValid) {
        throw CloudManifestException(
            'Manifest validation failed: ${validation.errors.join(', ')}'
        );
      }

      if (kDebugMode) {
        debugPrint('[CloudManifest] Successfully read manifest: ${manifest.items.length} items, version ${manifest.version}');
      }

      return manifest;

    } catch (e) {
      if (e is CloudManifestException) {
        rethrow;
      }
      throw CloudManifestException('Failed to read manifest: $e');
    }
  }

  /// Writes manifest to cloud storage using atomic operation
  /// Uses .tmp file then rename to ensure data integrity
  Future<void> writeManifest(BackupManifest manifest) async {
    try {
      if (kDebugMode) {
        debugPrint('[CloudManifest] Writing manifest with ${manifest.items.length} items');
      }

      final uri = await _getRequiredCloudUri();

      // Validate manifest before writing
      final validation = _validateManifest(manifest);
      if (!validation.isValid) {
        throw CloudManifestException(
            'Cannot write invalid manifest: ${validation.errors.join(', ')}'
        );
      }

      // Serialize to JSON
      final jsonData = _serializeManifest(manifest);
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final manifestBytes = Uint8List.fromList(utf8.encode(jsonString));

      // Validate size
      final sizeInMB = manifestBytes.length / (1024 * 1024);
      if (sizeInMB > _maxManifestSizeMB) {
        throw CloudManifestException(
            'Manifest too large to write: ${sizeInMB.toStringAsFixed(1)}MB (max: ${_maxManifestSizeMB}MB)'
        );
      }

      // ATOMIC WRITE PATTERN:
      // 1. Write to temporary file
      // 2. Rename temp to final (atomic operation)
      // 3. Clean up temp file if rename fails

      try {
        // Step 1: Write to temporary file
        final writeSuccess = await _safProvider.writeFile(uri, _manifestTempFileName, manifestBytes);
        if (!writeSuccess) {
          throw const CloudManifestException('Failed to write temporary manifest file');
        }

        if (kDebugMode) {
          debugPrint('[CloudManifest] Temporary manifest written (${manifestBytes.length} bytes)');
        }

        // Step 2: Atomic rename operation
        final renameSuccess = await _safProvider.renameFile(uri, _manifestTempFileName, _manifestFileName);
        if (!renameSuccess) {
          throw const CloudManifestException('Failed to rename temporary manifest to final');
        }

        if (kDebugMode) {
          debugPrint('[CloudManifest] Manifest successfully written via atomic operation');
        }

      } catch (e) {
        // Step 3: Clean up temp file if operation failed
        try {
          final tempExists = await _safProvider.exists(uri, _manifestTempFileName);
          if (tempExists) {
            await _safProvider.deleteFile(uri, _manifestTempFileName);
            if (kDebugMode) {
              debugPrint('[CloudManifest] Cleaned up temporary manifest file after failure');
            }
          }
        } catch (cleanupError) {
          if (kDebugMode) {
            debugPrint('[CloudManifest] Warning: Could not clean up temp file: $cleanupError');
          }
        }

        throw CloudManifestException('Atomic write failed: $e');
      }

    } catch (e) {
      if (e is CloudManifestException) {
        rethrow;
      }
      throw CloudManifestException('Failed to write manifest: $e');
    }
  }

  /// Creates a new manifest for initial backup
  BackupManifest createNewManifest({
    required String deviceId,
    required String appVersion,
    required List<BackupItem> items,
    Map<String, dynamic>? metadata,
  }) {
    return BackupManifest(
      version: _currentManifestVersion,
      exportedAt: DateTime.now(),
      deviceId: deviceId,
      appVersion: appVersion,
      items: items,
      metadata: metadata ?? {},
    );
  }

  /// Updates existing manifest with new items and metadata
  BackupManifest updateManifest(
      BackupManifest existingManifest, {
        required List<BackupItem> newItems,
        required String appVersion,
        Map<String, dynamic>? metadata,
      }) {
    return existingManifest.copyWith(
      exportedAt: DateTime.now(),
      appVersion: appVersion,
      items: newItems,
      metadata: metadata ?? existingManifest.metadata,
    );
  }

  /// Validates manifest structure and content
  ManifestValidation _validateManifest(BackupManifest manifest) {
    final errors = <String>[];
    final warnings = <String>[];

    // Version validation
    if (manifest.version < 1 || manifest.version > _currentManifestVersion) {
      errors.add('Unsupported manifest version: ${manifest.version} (supported: 1-$_currentManifestVersion)');
    }

    // Basic field validation
    if (manifest.deviceId.isEmpty) {
      errors.add('Device ID cannot be empty');
    }

    if (manifest.appVersion.isEmpty) {
      errors.add('App version cannot be empty');
    }

    // Date validation
    if (manifest.exportedAt.isAfter(DateTime.now().add(const Duration(hours: 1)))) {
      errors.add('Export date is in the future');
    }

    // Item validation
    final seenIds = <String>{};
    final seenPaths = <String>{};
    for (int i = 0; i < manifest.items.length; i++) {
      final item = manifest.items[i];
      final prefix = 'Item $i';

      // Check for duplicate IDs
      if (seenIds.contains(item.id)) {
        errors.add('$prefix: Duplicate ID: ${item.id}');
      }
      seenIds.add(item.id);

      // Check for duplicate paths
      if (seenPaths.contains(item.relativePath)) {
        errors.add('$prefix: Duplicate relative path: ${item.relativePath}');
      }
      seenPaths.add(item.relativePath);

      // Validate item fields
      if (item.id.isEmpty) {
        errors.add('$prefix: ID cannot be empty');
      }

      if (item.relativePath.isEmpty) {
        errors.add('$prefix: Relative path cannot be empty');
      }

      if (item.thumbPath.isEmpty) {
        errors.add('$prefix: Thumb path cannot be empty');
      }

      if (item.byteSize <= 0) {
        errors.add('$prefix: Invalid file size: ${item.byteSize}');
      }

      if (item.checksumSha256.length != 64) {
        errors.add('$prefix: Invalid SHA256 hash length: ${item.checksumSha256.length}');
      }

      // Validate SHA256 format (hex characters only)
      final hashRegex = RegExp(r'^[a-fA-F0-9]{64}$');
      if (!hashRegex.hasMatch(item.checksumSha256)) {
        errors.add('$prefix: Invalid SHA256 hash format');
      }

      // Validate dimensions
      if (item.width <= 0 || item.height <= 0) {
        warnings.add('$prefix: Invalid or missing dimensions: ${item.width}x${item.height}');
      }
    }

    return ManifestValidation(
      isValid: errors.isEmpty,
      version: manifest.version,
      itemCount: manifest.items.length,
      errors: errors,
      warnings: warnings,
      missingFiles: [], // Will be populated by other validation methods
      exportedAt: manifest.exportedAt,
      deviceId: manifest.deviceId,
    );
  }

  /// Serializes manifest to JSON map
  Map<String, dynamic> _serializeManifest(BackupManifest manifest) {
    return {
      'version': manifest.version,
      'exportedAt': manifest.exportedAt.toIso8601String(),
      'deviceId': manifest.deviceId,
      'appVersion': manifest.appVersion,
      'items': manifest.items.map((item) => {
        'id': item.id,
        'relativePath': item.relativePath,
        'thumbPath': item.thumbPath,
        'checksumSha256': item.checksumSha256,
        'byteSize': item.byteSize,
        'createdAt': item.createdAt.toIso8601String(),
        'width': item.width,
        'height': item.height,
        'exifTs': item.exifTs?.toIso8601String(),
        'sortIndex': item.sortIndex,
        'metadata': item.metadata,
      }).toList(),
      'metadata': manifest.metadata,
    };
  }

  /// Deserializes JSON map to manifest
  BackupManifest _deserializeManifest(Map<String, dynamic> jsonData) {
    try {
      final items = (jsonData['items'] as List<dynamic>?)
          ?.map((itemJson) => _deserializeBackupItem(itemJson as Map<String, dynamic>))
          .toList() ?? [];

      return BackupManifest(
        version: jsonData['version'] as int? ?? 1,
        exportedAt: DateTime.parse(jsonData['exportedAt'] as String? ?? DateTime.now().toIso8601String()),
        deviceId: jsonData['deviceId'] as String? ?? '',
        appVersion: jsonData['appVersion'] as String? ?? '',
        items: items,
        metadata: (jsonData['metadata'] as Map<String, dynamic>?) ?? {},
      );
    } catch (e) {
      throw CloudManifestException('Failed to deserialize manifest: $e');
    }
  }

  /// Deserializes JSON map to backup item
  BackupItem _deserializeBackupItem(Map<String, dynamic> itemJson) {
    try {
      return BackupItem(
        id: itemJson['id'] as String? ?? '',
        relativePath: itemJson['relativePath'] as String? ?? '',
        thumbPath: itemJson['thumbPath'] as String? ?? '',
        checksumSha256: itemJson['checksumSha256'] as String? ?? '',
        byteSize: itemJson['byteSize'] as int? ?? 0,
        createdAt: DateTime.parse(itemJson['createdAt'] as String? ?? DateTime.now().toIso8601String()),
        width: itemJson['width'] as int? ?? 0,
        height: itemJson['height'] as int? ?? 0,
        exifTs: itemJson['exifTs'] != null ? DateTime.parse(itemJson['exifTs'] as String) : null,
        sortIndex: itemJson['sortIndex'] as int? ?? 0,
        metadata: (itemJson['metadata'] as Map<String, dynamic>?) ?? {},
      );
    } catch (e) {
      throw CloudManifestException('Failed to deserialize backup item: $e');
    }
  }

  /// Checks if manifest exists in cloud storage
  Future<bool> manifestExists() async {
    try {
      final uri = await _getRequiredCloudUri();
      return await _safProvider.exists(uri, _manifestFileName);
    } catch (e) {
      throw CloudManifestException('Failed to check manifest existence: $e');
    }
  }

  /// Deletes manifest from cloud storage (for complete reset scenarios)
  Future<void> deleteManifest() async {
    try {
      final uri = await _getRequiredCloudUri();

      final exists = await _safProvider.exists(uri, _manifestFileName);
      if (exists) {
        final deleteSuccess = await _safProvider.deleteFile(uri, _manifestFileName);
        if (!deleteSuccess) {
          throw const CloudManifestException('Failed to delete manifest file');
        }
        if (kDebugMode) {
          debugPrint('[CloudManifest] Manifest deleted from cloud storage');
        }
      }

      // Also clean up any leftover temp files
      final tempExists = await _safProvider.exists(uri, _manifestTempFileName);
      if (tempExists) {
        final tempDeleteSuccess = await _safProvider.deleteFile(uri, _manifestTempFileName);
        if (tempDeleteSuccess && kDebugMode) {
          debugPrint('[CloudManifest] Cleaned up temporary manifest file');
        }
      }
    } catch (e) {
      if (e is CloudManifestException) {
        rethrow;
      }
      throw CloudManifestException('Failed to delete manifest: $e');
    }
  }

  /// Validates that the cloud storage is accessible and writable
  Future<bool> validateCloudAccess() async {
    try {
      final uri = await _getRequiredCloudUri();
      return await _safProvider.validateAccess(uri);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CloudManifest] Cloud access validation failed: $e');
      }
      return false;
    }
  }

  /// Gets information about the configured cloud folder
  Future<Map<String, String>?> getCloudFolderInfo() async {
    try {
      final uri = await _safProvider.getCloudFolderUri();
      final name = await _safProvider.getCloudFolderName();
      final lastBackup = await _safProvider.getLastBackupDate();

      if (uri == null) return null;

      return {
        'uri': uri,
        'name': name ?? 'Unknown',
        'lastBackup': lastBackup?.toIso8601String() ?? 'Never',
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CloudManifest] Failed to get cloud folder info: $e');
      }
      return null;
    }
  }
}

/// Custom exception for manifest operations
class CloudManifestException implements Exception {
  final String message;

  const CloudManifestException(this.message);

  @override
  String toString() => 'CloudManifestException: $message';
}

/// Riverpod provider for SafStorageProvider
final safStorageProvider = Provider<SafStorageProvider>((ref) {
  return SafStorageProvider();
});

/// Riverpod provider for CloudManifestRepository
final cloudManifestRepositoryProvider = Provider<CloudManifestRepository>((ref) {
  final safProvider = ref.read(safStorageProvider);
  return CloudManifestRepository(safProvider);
});