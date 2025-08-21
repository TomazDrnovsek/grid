// lib/repositories/saf_storage_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/backup_models.dart';

/// Provider for Storage Access Framework operations
/// Wraps Android SAF platform channel with proper error handling
class SafStorageProvider {
  static const MethodChannel _channel = MethodChannel('com.grid/saf');

  // SharedPreferences keys
  static const String _cloudFolderUriKey = 'cloud_folder_uri';
  static const String _cloudFolderNameKey = 'cloud_folder_name';
  static const String _lastBackupDateKey = 'last_backup_date';

  // File size threshold for automatic streaming (100KB)
  static const int _streamingThreshold = 100 * 1024;

  /// Pick a directory using Android's folder picker
  /// Returns {uri: String, name: String} on success, null on cancel
  Future<Map<String, String>?> pickDirectory() async {
    try {
      final result = await _channel.invokeMethod('pickDirectory');
      if (result != null) {
        final map = Map<String, String>.from(result);
        return map;
      }
      return null;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking directory: ${e.message}');
      }
      return null;
    }
  }

  /// Set the cloud folder and persist the configuration
  /// CRITICAL FIX: Now properly persists after successful selection
  Future<bool> setCloudFolder(String uri, String name) async {
    try {
      // First verify we can access the folder
      final hasAccess = await validateAccess(uri);
      if (!hasAccess) {
        if (kDebugMode) {
          debugPrint('Cannot access selected folder');
        }
        return false;
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cloudFolderUriKey, uri);
      await prefs.setString(_cloudFolderNameKey, name);

      if (kDebugMode) {
        debugPrint('Cloud folder set: $name ($uri)');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting cloud folder: $e');
      }
      return false;
    }
  }

  /// Get the saved cloud folder URI
  Future<String?> getCloudFolderUri() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cloudFolderUriKey);
  }

  /// Get the saved cloud folder name
  Future<String?> getCloudFolderName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cloudFolderNameKey);
  }

  /// Get the last backup date
  Future<DateTime?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastBackupDateKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Save the last backup date
  Future<void> saveLastBackupDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastBackupDateKey, date.millisecondsSinceEpoch);
  }

  /// Release/forget the persisted URI permission
  Future<bool> releaseUri(String uri) async {
    try {
      await _channel.invokeMethod('releaseUri', {'uri': uri});

      // Clear saved preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cloudFolderUriKey);
      await prefs.remove(_cloudFolderNameKey);
      await prefs.remove(_lastBackupDateKey);

      return true;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error releasing URI: ${e.message}');
      }
      return false;
    }
  }

  /// Check if a file/directory exists at the given path
  Future<bool> exists(String uri, String relativePath) async {
    try {
      final result = await _channel.invokeMethod('exists', {
        'uri': uri,
        'relativePath': relativePath,
      });
      return result as bool;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking existence: ${e.message}');
      }
      return false;
    }
  }

  /// List contents of a directory
  Future<List<SafEntry>> listDirectory(String uri, String relativeDir) async {
    try {
      final result = await _channel.invokeMethod('list', {
        'uri': uri,
        'relativeDir': relativeDir,
      });

      final entries = (result as List).map((item) {
        final map = item as Map;
        return SafEntry(
          name: map['name'] as String,
          type: map['type'] == 'directory'
              ? SafEntryType.directory
              : SafEntryType.file,
          size: map['size'] as int,
          lastModified:
          DateTime.fromMillisecondsSinceEpoch(map['lastModified'] as int),
          mimeType: map['mimeType'] as String?,
        );
      }).toList();

      return entries;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error listing directory: ${e.message}');
      }
      return [];
    }
  }

  /// Read a file from cloud storage
  /// Returns the file contents as bytes
  Future<Uint8List?> readFile(String uri, String relativePath) async {
    try {
      final result = await _channel.invokeMethod('read', {
        'uri': uri,
        'relativePath': relativePath,
      });
      return result as Uint8List;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error reading file: ${e.message}');
      }
      return null;
    }
  }

  /// Write a file to cloud storage (UPDATED: Auto-routes large files to streaming)
  /// Creates parent directories if createDirs is true
  Future<bool> writeFile(
      String uri,
      String relativePath,
      Uint8List bytes, {
        bool createDirs = true,
      }) async {
    // CRITICAL FIX: Auto-route large files to streaming to avoid truncate mode issues
    if (bytes.length > _streamingThreshold) {
      if (kDebugMode) {
        debugPrint(
            'File size ${bytes.length} > ${_streamingThreshold}B, using streaming');
      }
      return await _writeFileUsingStreaming(uri, relativePath, bytes, createDirs);
    }

    // Use legacy method for small files
    try {
      await _channel.invokeMethod('write', {
        'uri': uri,
        'relativePath': relativePath,
        'bytes': bytes,
        'createDirs': createDirs,
      });
      return true;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error writing file: ${e.message}');
      }
      return false;
    }
  }

  /// Write large file using streaming to avoid truncate mode issues
  Future<bool> _writeFileUsingStreaming(
      String uri,
      String relativePath,
      Uint8List bytes,
      bool createDirs,
      ) async {
    try {
      // Begin write session
      final String? token = await _channel.invokeMethod<String>('beginWrite', {
        'uri': uri,
        'relativePath': relativePath,
        'createDirs': createDirs,
      });

      if (token == null) {
        if (kDebugMode) {
          debugPrint('Failed to begin write session');
        }
        return false;
      }

      const chunkSize = 64 * 1024; // 64KB chunks
      var offset = 0;

      try {
        // Write in chunks
        while (offset < bytes.length) {
          final end = (offset + chunkSize < bytes.length)
              ? offset + chunkSize
              : bytes.length;
          final chunk = bytes.sublist(offset, end);

          final success = await _channel.invokeMethod('writeChunk', {
            'token': token,
            'data': chunk,
          });

          if (success != true) {
            // Abort session on failure
            await _channel.invokeMethod('abortWrite', {'token': token});
            return false;
          }

          offset = end;
        }

        // End session successfully
        final endSuccess =
        await _channel.invokeMethod('endWrite', {'token': token});
        return endSuccess == true;
      } catch (e) {
        // Abort session on any error
        try {
          await _channel.invokeMethod('abortWrite', {'token': token});
        } catch (_) {}
        rethrow;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error in streaming write: ${e.message}');
      }
      return false;
    }
  }

  /// NEW: Stream write a file in chunks using session-based API
  /// This method uses the new session-based streaming to avoid truncate mode issues
  Future<bool> writeFileStreamed(
      String uri,
      String relativePath,
      Stream<List<int>> dataStream,
      int totalBytes, {
        bool createDirs = true,
        void Function(StreamProgress)? onProgress,
      }) async {
    try {
      final startTime = DateTime.now();

      // Begin write session
      final String? token = await _channel.invokeMethod<String>('beginWrite', {
        'uri': uri,
        'relativePath': relativePath,
        'createDirs': createDirs,
      });

      if (token == null) {
        if (kDebugMode) {
          debugPrint('Failed to begin write session');
        }
        return false;
      }

      var bytesWritten = 0;
      const chunkSize = 64 * 1024; // 64KB chunks
      final buffer = <int>[];

      try {
        await for (final chunk in dataStream) {
          buffer.addAll(chunk);
          bytesWritten += chunk.length;

          // Write full chunks
          while (buffer.length >= chunkSize) {
            final writeChunk = buffer.take(chunkSize).toList();
            buffer.removeRange(0, chunkSize);

            final success = await _channel.invokeMethod('writeChunk', {
              'token': token,
              'data': Uint8List.fromList(writeChunk),
            });

            if (success != true) {
              await _channel.invokeMethod('abortWrite', {'token': token});
              return false;
            }
          }

          // Report progress
          if (onProgress != null) {
            onProgress(StreamProgress(
              fileName: relativePath,
              bytesTransferred: bytesWritten,
              totalBytes: totalBytes,
              startTime: startTime,
            ));
          }
        }

        // Write remaining bytes
        if (buffer.isNotEmpty) {
          final success = await _channel.invokeMethod('writeChunk', {
            'token': token,
            'data': Uint8List.fromList(buffer),
          });

          if (success != true) {
            await _channel.invokeMethod('abortWrite', {'token': token});
            return false;
          }
        }

        // End session successfully
        final endSuccess =
        await _channel.invokeMethod('endWrite', {'token': token});

        // Final progress report
        if (onProgress != null && endSuccess == true) {
          onProgress(StreamProgress(
            fileName: relativePath,
            bytesTransferred: bytesWritten,
            totalBytes: totalBytes,
            startTime: startTime,
            endTime: DateTime.now(),
          ));
        }

        return endSuccess == true;
      } catch (e) {
        // Abort session on any error
        try {
          await _channel.invokeMethod('abortWrite', {'token': token});
        } catch (_) {}
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in streamed write: $e');
      }
      return false;
    }
  }

  /// NEW: Copy file from cloud storage to local file system
  /// Uses native Android copy to avoid Binder limits and memory issues
  Future<String?> copyFromCloudToLocal(
      String uri,
      String relativePath,
      String destPath,
      ) async {
    try {
      final result =
      await _channel.invokeMethod<String>('copyToLocalFile', {
        'uri': uri,
        'relativePath': relativePath,
        'destPath': destPath,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error copying file to local: ${e.message}');
      }
      return null;
    }
  }

  /// Create directories
  Future<bool> makeDirectories(String uri, String relativeDir) async {
    try {
      await _channel.invokeMethod('mkdirs', {
        'uri': uri,
        'relativeDir': relativeDir,
      });
      return true;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating directories: ${e.message}');
      }
      return false;
    }
  }

  /// Rename a file (atomic for manifest updates)
  /// Note: Only works within the same directory
  Future<bool> renameFile(String uri, String fromPath, String toPath) async {
    try {
      final result = await _channel.invokeMethod('rename', {
        'uri': uri,
        'fromPath': fromPath,
        'toPath': toPath,
      });
      return result as bool;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error renaming file: ${e.message}');
      }
      return false;
    }
  }

  /// Delete a file or directory
  Future<bool> deleteFile(String uri, String relativePath) async {
    try {
      final result = await _channel.invokeMethod('delete', {
        'uri': uri,
        'relativePath': relativePath,
      });
      return result as bool;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting file: ${e.message}');
      }
      return false;
    }
  }

  /// Validate access to a URI by attempting to list its contents
  Future<bool> validateAccess(String uri) async {
    try {
      await _channel.invokeMethod('list', {
        'uri': uri,
        'relativeDir': '',
      });
      return true; // If we got here without exception, we have access
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error validating access: $e');
      }
      return false;
    }
  }

  /// Build the full cloud path for a file
  String buildCloudPath(String baseDir, String fileName) {
    if (baseDir.isEmpty || baseDir == '.') {
      return fileName;
    }
    return '$baseDir/$fileName';
  }

  /// Extract the directory part from a path
  String getDirectory(String path) {
    final lastSlash = path.lastIndexOf('/');
    if (lastSlash <= 0) return '';
    return path.substring(0, lastSlash);
  }

  /// Extract the filename from a path
  String getFileName(String path) {
    final lastSlash = path.lastIndexOf('/');
    if (lastSlash < 0) return path;
    return path.substring(lastSlash + 1);
  }

  /// Create date-based directory structure (YYYY/MM)
  String getDateBasedPath(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$year/$month';
  }

  /// Clear all saved cloud configuration
  Future<void> clearConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cloudFolderUriKey);
    await prefs.remove(_cloudFolderNameKey);
    await prefs.remove(_lastBackupDateKey);
  }

  /// Check if cloud backup is configured
  Future<bool> isConfigured() async {
    final uri = await getCloudFolderUri();
    return uri != null && uri.isNotEmpty;
  }

  /// Get configuration summary
  Future<Map<String, dynamic>> getConfiguration() async {
    final uri = await getCloudFolderUri();
    final name = await getCloudFolderName();
    final lastBackup = await getLastBackupDate();

    return {
      'configured': uri != null,
      'uri': uri,
      'name': name ?? 'Unknown',
      'lastBackup': lastBackup?.toIso8601String(),
      'hasAccess': uri != null ? await validateAccess(uri) : false,
    };
  }
}

/// Riverpod provider for SafStorageProvider
final safStorageProvider = Provider<SafStorageProvider>((ref) {
  return SafStorageProvider();
});