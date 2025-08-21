import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_models.freezed.dart';
part 'backup_models.g.dart';

/// Backup operation status for UI state management
enum BackupStatus { idle, running, success, error }

/// Backup operation phase
enum BackupPhase { backingUp, restoring }

/// SAF (Storage Access Framework) entry type
enum SafEntryType { file, directory }

/// Backup manifest version 1 - Top level structure
@freezed
class BackupManifest with _$BackupManifest {
  const factory BackupManifest({
    @Default(1) int version,
    required DateTime exportedAt,
    required String deviceId,
    required String appVersion,
    required List<BackupItem> items,
    @Default({}) Map<String, dynamic> metadata,
  }) = _BackupManifest;

  factory BackupManifest.fromJson(Map<String, dynamic> json) =>
      _$BackupManifestFromJson(json);
}

/// Individual photo item in the backup manifest
@freezed
class BackupItem with _$BackupItem {
  const factory BackupItem({
    required String id,
    required String relativePath,
    required String thumbPath,
    required String checksumSha256,
    required int byteSize,
    required DateTime createdAt,
    required int width,
    required int height,
    DateTime? exifTs,
    required int sortIndex,
    @Default({}) Map<String, dynamic> metadata,
  }) = _BackupItem;

  factory BackupItem.fromJson(Map<String, dynamic> json) =>
      _$BackupItemFromJson(json);
}

/// State for backup/restore operations in Riverpod
@freezed
class BackupState with _$BackupState {
  const factory BackupState({
    @Default(BackupStatus.idle) BackupStatus status,
    BackupPhase? phase,
    @Default(0) int current,
    @Default(0) int total,
    @Default(0) int bytesProcessed,
    @Default(0) int totalBytes,
    BackupResult? lastResult,
    String? currentFile,
    String? error,
    String? cloudFolderUri,
    String? cloudFolderName,
    DateTime? lastBackupDate,
    @Default(false) bool isCancelled,
  }) = _BackupState;

  const BackupState._();

  /// Progress as a value between 0.0 and 1.0
  double get progress {
    if (total == 0) return 0.0;
    return (current / total).clamp(0.0, 1.0);
  }

  /// Bytes progress as a value between 0.0 and 1.0
  double get bytesProgress {
    if (totalBytes == 0) return 0.0;
    return (bytesProcessed / totalBytes).clamp(0.0, 1.0);
  }

  /// Whether the operation is currently running
  bool get isRunning => status == BackupStatus.running;

  /// Whether a cloud folder is configured
  bool get hasCloudFolder => cloudFolderUri != null && cloudFolderUri!.isNotEmpty;
}

/// Result of a backup or restore operation
@freezed
class BackupResult with _$BackupResult {
  const factory BackupResult({
    required int operationsProcessed,
    required int successCount,
    required int failureCount,
    required Duration processingTime,
    @Default([]) List<String> errors,
    @Default([]) List<String> warnings,
    @Default({}) Map<String, dynamic> metadata,
  }) = _BackupResult;

  const BackupResult._();

  /// Whether the operation was fully successful
  bool get isFullSuccess => failureCount == 0 && errors.isEmpty;

  /// Whether the operation had partial success
  bool get isPartialSuccess => successCount > 0 && failureCount > 0;

  /// Success rate as a percentage
  double get successRate {
    if (operationsProcessed == 0) return 0.0;
    return (successCount / operationsProcessed) * 100;
  }
}

/// SAF directory entry for listing cloud folder contents
@freezed
class SafEntry with _$SafEntry {
  const factory SafEntry({
    required String name,
    required SafEntryType type,
    required int size,
    required DateTime lastModified,
    String? mimeType,
  }) = _SafEntry;

  factory SafEntry.fromJson(Map<String, dynamic> json) =>
      _$SafEntryFromJson(json);
}

/// Validation result for backup manifest
@freezed
class ManifestValidation with _$ManifestValidation {
  const factory ManifestValidation({
    required bool isValid,
    required int version,
    required int itemCount,
    @Default([]) List<String> errors,
    @Default([]) List<String> warnings,
    @Default([]) List<String> missingFiles,
    DateTime? exportedAt,
    String? deviceId,
  }) = _ManifestValidation;

  const ManifestValidation._();

  /// Whether the manifest can be used for restore
  bool get canRestore => isValid && errors.isEmpty;

  /// Whether the manifest has issues but can still be used
  bool get hasWarnings => warnings.isNotEmpty || missingFiles.isNotEmpty;
}

/// Progress update for streaming operations
@freezed
class StreamProgress with _$StreamProgress {
  const factory StreamProgress({
    required String fileName,
    required int bytesTransferred,
    required int totalBytes,
    required DateTime startTime,
    DateTime? endTime,
  }) = _StreamProgress;

  const StreamProgress._();

  /// Progress as a value between 0.0 and 1.0
  double get progress {
    if (totalBytes == 0) return 0.0;
    return (bytesTransferred / totalBytes).clamp(0.0, 1.0);
  }

  /// Transfer speed in bytes per second
  double get bytesPerSecond {
    final elapsed = (endTime ?? DateTime.now()).difference(startTime);
    if (elapsed.inMilliseconds == 0) return 0;
    return bytesTransferred / (elapsed.inMilliseconds / 1000);
  }

  /// Formatted transfer speed (e.g., "1.5 MB/s")
  String get formattedSpeed {
    final speed = bytesPerSecond;
    if (speed < 1024) return '${speed.toStringAsFixed(0)} B/s';
    if (speed < 1024 * 1024) return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}

/// Configuration for backup operations
@freezed
class BackupConfig with _$BackupConfig {
  const factory BackupConfig({
    @Default(64 * 1024) int chunkSize, // 64KB chunks for streaming
    @Default(2) int maxConcurrency, // Max concurrent file operations
    @Default(true) bool includeOriginals,
    @Default(true) bool includeThumbnails,
    @Default(true) bool validateChecksums,
    @Default(false) bool skipExisting, // Skip files that already exist
    @Default(false) bool verboseLogging,
    @Default('Grid') String cloudFolderName, // Root folder name in cloud
  }) = _BackupConfig;

  factory BackupConfig.fromJson(Map<String, dynamic> json) =>
      _$BackupConfigFromJson(json);
}

/// Checkpoint for resumable operations
@freezed
class BackupCheckpoint with _$BackupCheckpoint {
  const factory BackupCheckpoint({
    required String operationId,
    required BackupPhase phase,
    required DateTime startedAt,
    DateTime? lastUpdatedAt,
    required int lastProcessedIndex,
    required List<String> processedIds,
    required List<String> failedIds,
    @Default({}) Map<String, dynamic> metadata,
  }) = _BackupCheckpoint;

  factory BackupCheckpoint.fromJson(Map<String, dynamic> json) =>
      _$BackupCheckpointFromJson(json);

  const BackupCheckpoint._();

  /// Create a new checkpoint from current state
  BackupCheckpoint copyWithProgress({
    required int newIndex,
    String? newProcessedId,
    String? newFailedId,
  }) {
    return copyWith(
      lastProcessedIndex: newIndex,
      lastUpdatedAt: DateTime.now(),
      processedIds: newProcessedId != null
          ? [...processedIds, newProcessedId]
          : processedIds,
      failedIds: newFailedId != null
          ? [...failedIds, newFailedId]
          : failedIds,
    );
  }
}

/// Device information for manifest metadata
@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    required String deviceId,
    required String manufacturer,
    required String model,
    required String androidVersion,
    required int sdkInt,
    required String appVersion,
    required String buildNumber,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}