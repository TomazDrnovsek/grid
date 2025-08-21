// File: lib/providers/backup_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/backup_models.dart';
import '../repositories/backup_restore_repository.dart';
import '../repositories/cloud_manifest_repository.dart';
import '../repositories/saf_storage_provider.dart';
import '../repositories/photo_repository.dart';
import '../services/backup_hasher.dart';
import '../services/thumbnail_service.dart';
import '../services/performance_monitor.dart';
import '../widgets/error_boundary.dart';

/// StateNotifier for cloud backup state management following established patterns
/// Integrates with existing backup infrastructure and provides UI-ready state updates
class BackupNotifier extends StateNotifier<BackupState> {
  // Initialize repository as field initializer (null safety compliant)
  final BackupRestoreRepository _repository = BackupRestoreRepository(
    CloudManifestRepository(SafStorageProvider()),
    SafStorageProvider(),
    PhotoRepository(),
    BackupHasherService(),
    ThumbnailService(),
  );

  // Stream subscriptions for progress tracking
  StreamSubscription<BackupState>? _backupSubscription;
  StreamSubscription<BackupState>? _restoreSubscription;

  // Operation cancellation
  bool _isOperationCancelled = false;

  BackupNotifier() : super(const BackupState()) {
    // Schedule initial cloud folder check
    Future.microtask(() {
      _loadCloudFolderSettings();
    });
  }

  @override
  void dispose() {
    // Cancel any ongoing operations
    _isOperationCancelled = true;

    // Cancel stream subscriptions with null safety
    _backupSubscription?.cancel();
    _backupSubscription = null;

    _restoreSubscription?.cancel();
    _restoreSubscription = null;

    if (kDebugMode) {
      debugPrint('BackupNotifier: Disposed and cleaned up');
    }

    super.dispose();
  }

  /// Set cloud folder URI and persist to SharedPreferences
  Future<void> setCloudFolder(String uri, String displayName) async {
    await RepositoryErrorHandler.handleAsyncOperation<void>(
          () async {
        if (kDebugMode) {
          debugPrint('BackupProvider: Setting cloud folder - $displayName');
        }

        // Update state immediately for UI responsiveness
        state = state.copyWith(
          cloudFolderUri: uri,
          cloudFolderName: displayName,
          status: BackupStatus.idle,
          error: null,
        );

        // Persist to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('backup_cloud_folder_uri', uri);
        await prefs.setString('backup_cloud_folder_name', displayName);

        // Check backup status in cloud folder
        await _checkCloudBackupStatus();

        if (kDebugMode) {
          debugPrint('BackupProvider: Cloud folder set successfully');
        }
      },
      fallbackValue: null,
      context: 'BackupProvider.setCloudFolder',
    );
  }

  /// Remove cloud folder configuration
  Future<void> removeCloudFolder() async {
    await RepositoryErrorHandler.handleAsyncOperation<void>(
          () async {
        if (kDebugMode) {
          debugPrint('BackupProvider: Removing cloud folder configuration');
        }

        // Clear SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('backup_cloud_folder_uri');
        await prefs.remove('backup_cloud_folder_name');

        // Reset state
        state = const BackupState();

        if (kDebugMode) {
          debugPrint('BackupProvider: Cloud folder removed successfully');
        }
      },
      fallbackValue: null,
      context: 'BackupProvider.removeCloudFolder',
    );
  }

  /// Perform backup with real-time progress tracking
  Future<void> performBackup() async {
    if (state.status == BackupStatus.running) {
      if (kDebugMode) {
        debugPrint('BackupProvider: Backup already in progress');
      }
      return;
    }

    final cloudFolderUri = state.cloudFolderUri;
    if (cloudFolderUri == null) {
      state = state.copyWith(
        status: BackupStatus.error,
        error: 'No cloud folder selected',
      );
      return;
    }

    await RepositoryErrorHandler.handleAsyncOperation<void>(
          () async {
        if (kDebugMode) {
          debugPrint('BackupProvider: Starting backup operation');
        }

        // Initialize backup state
        _isOperationCancelled = false;
        state = state.copyWith(
          status: BackupStatus.running,
          phase: BackupPhase.backingUp,
          current: 0,
          total: 0,
          bytesProcessed: 0,
          totalBytes: 0,
          error: null,
          currentFile: null,
        );

        // Start performance monitoring
        PerformanceMonitor.instance.startOperation('cloud_backup');

        try {
          // Setup backup stream subscription
          _backupSubscription?.cancel();
          _backupSubscription = _repository.performBackup().listen(
                (backupState) => _handleBackupProgress(backupState),
            onError: (error) => _handleBackupError(error),
            onDone: () => _handleBackupComplete(),
          );

        } catch (e) {
          // Stop performance monitoring on error
          PerformanceMonitor.instance.endOperation('cloud_backup');
          rethrow;
        }
      },
      fallbackValue: null,
      context: 'BackupProvider.performBackup',
    );
  }

  /// Perform restore with real-time progress tracking
  Future<void> performRestore() async {
    if (state.status == BackupStatus.running) {
      if (kDebugMode) {
        debugPrint('BackupProvider: Operation already in progress');
      }
      return;
    }

    final cloudFolderUri = state.cloudFolderUri;
    if (cloudFolderUri == null) {
      state = state.copyWith(
        status: BackupStatus.error,
        error: 'No cloud folder selected',
      );
      return;
    }

    await RepositoryErrorHandler.handleAsyncOperation<void>(
          () async {
        if (kDebugMode) {
          debugPrint('BackupProvider: Starting restore operation');
        }

        // Initialize restore state
        _isOperationCancelled = false;
        state = state.copyWith(
          status: BackupStatus.running,
          phase: BackupPhase.restoring,
          current: 0,
          total: 0,
          bytesProcessed: 0,
          totalBytes: 0,
          error: null,
          currentFile: null,
        );

        // Start performance monitoring
        PerformanceMonitor.instance.startOperation('cloud_restore');

        try {
          // Setup restore stream subscription
          _restoreSubscription?.cancel();
          _restoreSubscription = _repository.performRestore().listen(
                (backupState) => _handleRestoreProgress(backupState),
            onError: (error) => _handleRestoreError(error),
            onDone: () => _handleRestoreComplete(),
          );

        } catch (e) {
          // Stop performance monitoring on error
          PerformanceMonitor.instance.endOperation('cloud_restore');
          rethrow;
        }
      },
      fallbackValue: null,
      context: 'BackupProvider.performRestore',
    );
  }

  /// Cancel ongoing backup or restore operation
  Future<void> cancelOperation() async {
    if (state.status != BackupStatus.running) {
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint('BackupProvider: Cancelling operation');
      }

      // Set cancellation flag
      _isOperationCancelled = true;

      // Cancel stream subscriptions
      _backupSubscription?.cancel();
      _backupSubscription = null;

      _restoreSubscription?.cancel();
      _restoreSubscription = null;

      // Reset to idle state
      state = state.copyWith(
        status: BackupStatus.idle,
        phase: null,
        current: 0,
        total: 0,
        bytesProcessed: 0,
        totalBytes: 0,
        currentFile: null,
        error: null,
      );

      if (kDebugMode) {
        debugPrint('BackupProvider: Operation cancelled successfully');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('BackupProvider: Error cancelling operation - $e');
      }
    }
  }

  /// Load persisted cloud folder settings
  Future<void> _loadCloudFolderSettings() async {
    await RepositoryErrorHandler.handleAsyncOperation<void>(
          () async {
        // Load persisted cloud folder settings
        final prefs = await SharedPreferences.getInstance();
        final cloudFolderUri = prefs.getString('backup_cloud_folder_uri');
        final cloudFolderName = prefs.getString('backup_cloud_folder_name');

        if (cloudFolderUri != null && cloudFolderName != null) {
          // Update state with persisted settings
          state = state.copyWith(
            cloudFolderUri: cloudFolderUri,
            cloudFolderName: cloudFolderName,
          );

          // Check if backup exists in cloud folder
          await _checkCloudBackupStatus();
        }
      },
      fallbackValue: null,
      context: 'BackupProvider._loadCloudFolderSettings',
    );
  }

  /// Check cloud backup status
  Future<void> _checkCloudBackupStatus() async {
    await RepositoryErrorHandler.handleAsyncOperation<void>(
          () async {
        final status = await _repository.getBackupStatus();

        if (kDebugMode) {
          debugPrint('BackupProvider: Cloud backup status - $status.hasBackup');
        }

        // Update state with backup status
        state = state.copyWith(
          lastBackupDate: status.lastBackupDate,
        );
      },
      fallbackValue: null,
      context: 'BackupProvider._checkCloudBackupStatus',
    );
  }

  /// Handle backup progress updates from stream
  void _handleBackupProgress(BackupState update) {
    if (_isOperationCancelled) return;

    try {
      // Update state with progress from repository
      state = update.copyWith(
        cloudFolderUri: state.cloudFolderUri,
        cloudFolderName: state.cloudFolderName,
        lastBackupDate: state.lastBackupDate,
      );

      if (kDebugMode) {
        final progress = update.total > 0
            ? (update.current / update.total * 100).toStringAsFixed(1)
            : '0.0';
        debugPrint('BackupProvider: Progress $progress% - $update.currentFile');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('BackupProvider: Error handling backup progress - $e');
      }
    }
  }

  /// Handle restore progress updates from stream
  void _handleRestoreProgress(BackupState update) {
    if (_isOperationCancelled) return;

    try {
      // Update state with progress from repository
      state = update.copyWith(
        cloudFolderUri: state.cloudFolderUri,
        cloudFolderName: state.cloudFolderName,
        lastBackupDate: state.lastBackupDate,
      );

      if (kDebugMode) {
        final progress = update.total > 0
            ? (update.current / update.total * 100).toStringAsFixed(1)
            : '0.0';
        debugPrint('BackupProvider: Restore $progress% - $update.currentFile');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('BackupProvider: Error handling restore progress - $e');
      }
    }
  }

  /// Handle backup completion
  void _handleBackupComplete() {
    if (_isOperationCancelled) return;

    try {
      if (kDebugMode) {
        debugPrint('BackupProvider: Backup completed successfully');
      }

      state = state.copyWith(
        status: BackupStatus.success,
        phase: null,
        lastBackupDate: DateTime.now(),
        currentFile: null,
      );

      // Clean up subscription
      _backupSubscription?.cancel();
      _backupSubscription = null;

      // Stop performance monitoring
      PerformanceMonitor.instance.endOperation('cloud_backup');

    } catch (e) {
      if (kDebugMode) {
        debugPrint('BackupProvider: Error handling backup completion - $e');
      }
    }
  }

  /// Handle restore completion
  void _handleRestoreComplete() {
    if (_isOperationCancelled) return;

    try {
      if (kDebugMode) {
        debugPrint('BackupProvider: Restore completed successfully');
      }

      state = state.copyWith(
        status: BackupStatus.success,
        phase: null,
        currentFile: null,
      );

      // Clean up subscription
      _restoreSubscription?.cancel();
      _restoreSubscription = null;

      // Stop performance monitoring
      PerformanceMonitor.instance.endOperation('cloud_restore');

    } catch (e) {
      if (kDebugMode) {
        debugPrint('BackupProvider: Error handling restore completion - $e');
      }
    }
  }

  /// Handle backup operation errors
  void _handleBackupError(dynamic error) {
    if (_isOperationCancelled) return;

    try {
      if (kDebugMode) {
        debugPrint('BackupProvider: Backup error - $error');
      }

      state = state.copyWith(
        status: BackupStatus.error,
        phase: null,
        error: 'Backup failed: $error',
        currentFile: null,
      );

      // Clean up subscription
      _backupSubscription?.cancel();
      _backupSubscription = null;

      // Stop performance monitoring
      PerformanceMonitor.instance.endOperation('cloud_backup');

    } catch (e) {
      if (kDebugMode) {
        debugPrint('BackupProvider: Error in backup error handler - $e');
      }
    }
  }

  /// Handle restore operation errors
  void _handleRestoreError(dynamic error) {
    if (_isOperationCancelled) return;

    try {
      if (kDebugMode) {
        debugPrint('BackupProvider: Restore error - $error');
      }

      state = state.copyWith(
        status: BackupStatus.error,
        phase: null,
        error: 'Restore failed: $error',
        currentFile: null,
      );

      // Clean up subscription
      _restoreSubscription?.cancel();
      _restoreSubscription = null;

      // Stop performance monitoring
      PerformanceMonitor.instance.endOperation('cloud_restore');

    } catch (e) {
      if (kDebugMode) {
        debugPrint('BackupProvider: Error in restore error handler - $e');
      }
    }
  }

  /// Get current backup status for UI display
  BackupStatus get currentStatus => state.status;

  /// Check if operation is currently running
  bool get isOperationRunning => state.status == BackupStatus.running;

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (state.total == 0) return 0.0;
    return (state.current / state.total).clamp(0.0, 1.0);
  }

  /// Get bytes progress percentage (0.0 to 1.0)
  double get bytesProgressPercentage {
    if (state.totalBytes == 0) return 0.0;
    return (state.bytesProcessed / state.totalBytes).clamp(0.0, 1.0);
  }

  /// Get human-readable progress status
  String get progressStatus {
    if (state.status == BackupStatus.idle) {
      return 'Ready';
    } else if (state.status == BackupStatus.running) {
      if (state.phase == BackupPhase.backingUp) {
        return 'Backing up ${state.current}/${state.total}';
      } else if (state.phase == BackupPhase.restoring) {
        return 'Restoring ${state.current}/${state.total}';
      } else {
        return 'Processing...';
      }
    } else if (state.status == BackupStatus.success) {
      return 'Completed successfully';
    } else if (state.status == BackupStatus.error) {
      return 'Error: ${state.error ?? 'Unknown error'}';
    }
    return 'Unknown status';
  }

  /// Check if cloud folder is configured
  bool get hasCloudFolder =>
      state.cloudFolderUri != null && state.cloudFolderUri!.isNotEmpty;

  /// Check if backup is available in cloud
  bool get hasCloudBackup => state.lastBackupDate != null;
}

/// StateNotifierProvider following established patterns from handoff documentation
final backupProvider = StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  return BackupNotifier();
});

/// Provider for checking if backup is in progress
final isBackupRunningProvider = Provider<bool>((ref) {
  final backupState = ref.watch(backupProvider);
  return backupState.status == BackupStatus.running;
});

/// Provider for backup progress percentage
final backupProgressProvider = Provider<double>((ref) {
  final backupState = ref.watch(backupProvider);
  if (backupState.total == 0) return 0.0;
  return (backupState.current / backupState.total).clamp(0.0, 1.0);
});

/// Provider for backup progress status string
final backupProgressStatusProvider = Provider<String>((ref) {
  final notifier = ref.read(backupProvider.notifier);
  return notifier.progressStatus;
});

/// Provider for cloud backup status checking
final cloudBackupStatusProvider = FutureProvider<CloudBackupStatus>((ref) async {
  final repository = BackupRestoreRepository(
    CloudManifestRepository(SafStorageProvider()),
    SafStorageProvider(),
    PhotoRepository(),
    BackupHasherService(),
    ThumbnailService(),
  );
  return await repository.getBackupStatus();
});