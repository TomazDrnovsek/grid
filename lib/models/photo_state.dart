// File: lib/models/photo_state.dart
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_state.freezed.dart';

/// Immutable state class for photo management using Freezed
/// PHASE 2 IMPLEMENTATION: Added UUID support for stable photo identification
/// Replaces the current setState-based state management in grid_home.dart
@freezed
class PhotoState with _$PhotoState {
  const factory PhotoState({
    /// List of full-resolution image files
    @Default([]) List<File> images,

    /// List of thumbnail files corresponding to images
    @Default([]) List<File> thumbnails,

    /// PHASE 2: List of photo UUIDs corresponding to images (for backup/restore order preservation)
    @Default(<String>[]) List<String> imageUuids,

    /// Set of selected image indexes
    @Default({}) Set<int> selectedIndexes,

    /// Loading state for image operations
    @Default(false) bool isLoading,

    /// Delete confirmation modal state
    @Default(false) bool showDeleteConfirm,

    /// PHASE 1: Loading modal with progress state
    @Default(false) bool showLoadingModal,

    /// Image preview modal state
    @Default(false) bool showImagePreview,

    /// Index of currently previewed image (-1 if none)
    @Default(-1) int previewImageIndex,

    /// Scroll position state (true if at top)
    @Default(true) bool isAtTop,

    /// Header username editing state
    @Default(false) bool editingHeaderUsername,

    /// Current header username value
    @Default('namesurname') String headerUsername,

    /// Total count of images for convenience
    @Default(0) int imageCount,

    /// Whether arrays are in sync (safety check)
    @Default(true) bool arraysInSync,

    /// PHASE 2: Hue map overlay toggle state
    @Default(false) bool showHueMap,

    // ========================================================================
    // PHASE 2: ENHANCED BATCH OPERATION TRACKING
    // ========================================================================

    /// Current batch operation in progress (null if none)
    BatchOperationStatus? currentBatchOperation,

    /// History of recent batch operations for debugging
    @Default([]) List<BatchOperationRecord> batchHistory,

    /// Total number of batch operations completed in this session
    @Default(0) int totalBatchOperations,

    /// Number of operations currently queued for batch processing
    @Default(0) int queuedOperations,

    /// Whether batch processing is currently active
    @Default(false) bool isBatchProcessing,

    /// Last batch operation result for UI feedback
    BatchResult? lastBatchResult,

    /// Batch processing metrics for performance monitoring
    @Default(BatchMetrics()) BatchMetrics batchMetrics,
  }) = _PhotoState;

  // CRITICAL: Required constructor for Freezed when using getters
  const PhotoState._();

  /// Convenience getter for checking if any images are selected
  bool get hasSelection => selectedIndexes.isNotEmpty;

  /// Convenience getter for checking if single image is selected (for sharing)
  bool get hasSingleSelection => selectedIndexes.length == 1;

  /// Convenience getter for checking if multiple images are selected
  bool get hasMultipleSelection => selectedIndexes.length > 1;

  /// Convenience getter for selected count
  int get selectedCount => selectedIndexes.length;

  /// Convenience getter for checking if images list is empty
  bool get isEmpty => images.isEmpty;

  /// Convenience getter for checking if images list is not empty
  bool get isNotEmpty => images.isNotEmpty;

  /// Convenience getter for first selected index (for single selection operations)
  int get firstSelectedIndex => selectedIndexes.isEmpty ? -1 : selectedIndexes.first;

  /// Check if all arrays (images, thumbnails) are in sync
  bool get arraysInSyncBasic {
    return images.length == thumbnails.length;
  }

  /// Check if currently displaying the image preview modal
  bool get isShowingPreview => showImagePreview && previewImageIndex >= 0;

  /// Check if header is in editing mode
  bool get isEditingHeader => editingHeaderUsername;

  /// Get a debug description of the current state
  String get debugInfo {
    return 'PhotoState(images: ${images.length}, thumbnails: ${thumbnails.length}, '
        'uuids: ${imageUuids.length}, selected: $selectedCount, loading: $isLoading)';
  }
}

/// PHASE 2: Extension for UUID-related helper methods
/// Moved to extension to avoid Freezed constructor conflicts
extension PhotoStateX on PhotoState {
  /// Check if UUID array is in sync with images array
  bool get uuidsInSync => images.length == imageUuids.length;

  /// Enhanced array sync check (includes UUIDs)
  bool get enhancedArraysInSync {
    return images.length == thumbnails.length && images.length == imageUuids.length;
  }

  /// Safe UUID getter by index
  String? getUuidAtIndex(int index) {
    if (index >= 0 && index < imageUuids.length) {
      return imageUuids[index];
    }
    return null;
  }

  /// Get UUIDs for currently selected images
  List<String> get selectedUuids {
    final uuids = <String>[];
    for (final index in selectedIndexes) {
      final uuid = getUuidAtIndex(index);
      if (uuid != null) {
        uuids.add(uuid);
      }
    }
    return uuids;
  }

  /// Get all UUIDs in current display order
  List<String> get orderedUuids => List<String>.from(imageUuids);

  /// Get batch debug info (enhanced with UUID check)
  BatchDebugInfo get debugInfo {
    final recentHistory = batchHistory.length > 10
        ? batchHistory.skip(batchHistory.length - 10).toList()
        : batchHistory;

    return BatchDebugInfo(
      currentOperation: currentBatchOperation,
      queuedOperations: queuedOperations,
      isBatchProcessing: isBatchProcessing,
      totalOperations: totalBatchOperations,
      recentHistory: recentHistory,
      metrics: batchMetrics,
      lastResult: lastBatchResult,
      arraysInSync: enhancedArraysInSync, // Enhanced check including UUIDs
      imagesCount: images.length,
      thumbnailsCount: thumbnails.length,
      selectedCount: selectedCount,
    );
  }

  /// Check if state is healthy for batch operations (enhanced with UUID check)
  bool get isBatchHealthy {
    return enhancedArraysInSync &&
        !isBatchProcessing &&
        queuedOperations < 20 &&
        batchMetrics.averageProcessingTime.inMilliseconds < 1000;
  }
}

/// Data class for processed image results
@freezed
class ProcessedImage with _$ProcessedImage {
  const factory ProcessedImage({
    required File image,
    required File thumbnail,
  }) = _ProcessedImage;
}

/// Data class for batch image operations
@freezed
class BatchImageResult with _$BatchImageResult {
  const factory BatchImageResult({
    required List<ProcessedImage> processedImages,
    required int successCount,
    required int failureCount,
    @Default([]) List<String> errors,
  }) = _BatchImageResult;
}

/// Enum for different types of photo operations
enum PhotoOperation {
  add,
  delete,
  reorder,
  select,
  deselect,
  clearSelection,
  share,
}

/// Data class for photo operation events
@freezed
class PhotoOperationEvent with _$PhotoOperationEvent {
  const factory PhotoOperationEvent({
    required PhotoOperation operation,
    @Default([]) List<int> indexes,
    @Default('') String message,
    DateTime? timestamp,
  }) = _PhotoOperationEvent;
}

// ============================================================================
// PHASE 2: ENHANCED BATCH OPERATION MODELS & TRACKING
// ============================================================================

/// Enum for batch operation types (matches provider implementation)
enum BatchOperationType {
  addPhotos,
  deletePhotos,
  reorderPhotos,
  selectPhotos,
  deselectPhotos,
}

/// Current batch operation status for real-time tracking
@freezed
class BatchOperationStatus with _$BatchOperationStatus {
  const factory BatchOperationStatus({
    required BatchOperationType type,
    required DateTime startTime,
    required int operationCount,
    @Default('Processing...') String status,
    @Default(0) int completedOperations,
    @Default([]) List<String> currentMessages,
  }) = _BatchOperationStatus;

  const BatchOperationStatus._();

  /// Calculate progress percentage (0.0 to 1.0)
  double get progress => operationCount > 0
      ? (completedOperations / operationCount).clamp(0.0, 1.0)
      : 0.0;

  /// Get elapsed time since operation started
  Duration get elapsedTime => DateTime.now().difference(startTime);

  /// Check if operation is taking too long (over 5 seconds)
  bool get isTakingTooLong => elapsedTime.inSeconds > 5;
}

/// Complete record of a batch operation for history tracking
@freezed
class BatchOperationRecord with _$BatchOperationRecord {
  const factory BatchOperationRecord({
    required BatchOperationType type,
    required DateTime startTime,
    required DateTime endTime,
    required int operationCount,
    required int successCount,
    required int failureCount,
    @Default([]) List<String> errors,
    @Default([]) List<String> warnings,
    required bool wasOptimized,
    @Default({}) Map<String, dynamic> metadata,
  }) = _BatchOperationRecord;

  const BatchOperationRecord._();

  /// Get operation duration
  Duration get duration => endTime.difference(startTime);

  /// Check if operation was successful
  bool get wasSuccessful => failureCount == 0;

  /// Get operation efficiency score (0.0 to 1.0)
  double get efficiencyScore {
    if (operationCount == 0) return 1.0;
    final successRate = successCount / operationCount;
    final speedScore = duration.inMilliseconds < 100 ? 1.0 : 0.5;
    return (successRate + speedScore) / 2.0;
  }

  /// Get human-readable summary
  String get summary {
    final typeStr = type.toString().split('.').last;
    final durationStr = '${duration.inMilliseconds}ms';
    if (wasSuccessful) {
      return '$typeStr: $successCount operations completed in $durationStr';
    } else {
      return '$typeStr: $successCount/$operationCount successful in $durationStr (${errors.length} errors)';
    }
  }
}

/// Enhanced batch result with detailed tracking
@freezed
class BatchResult with _$BatchResult {
  const factory BatchResult({
    required int operationsProcessed,
    required int successCount,
    required int failureCount,
    required Duration processingTime,
    @Default([]) List<String> errors,
    @Default([]) List<String> warnings,
    required bool wasOptimized,
    required BatchOperationType primaryOperationType,
    @Default({}) Map<String, int> operationBreakdown,
    @Default({}) Map<String, dynamic> performanceMetrics,
  }) = _BatchResult;

  const BatchResult._();

  /// Check if batch was successful
  bool get isSuccess => failureCount == 0;

  /// Check if batch had any issues
  bool get hasErrors => errors.isNotEmpty;

  /// Check if batch had warnings
  bool get hasWarnings => warnings.isNotEmpty;

  /// Get success rate (0.0 to 1.0)
  double get successRate => operationsProcessed > 0
      ? successCount / operationsProcessed
      : 1.0;

  /// Check if batch was fast (under 100ms)
  bool get wasFast => processingTime.inMilliseconds < 100;

  /// Get performance grade (A, B, C, D, F)
  String get performanceGrade {
    if (isSuccess && wasFast) return 'A';
    if (isSuccess && processingTime.inMilliseconds < 500) return 'B';
    if (successRate > 0.8 && processingTime.inMilliseconds < 1000) return 'C';
    if (successRate > 0.5) return 'D';
    return 'F';
  }
}

/// Validation result for batch operations
@freezed
class BatchValidationResult with _$BatchValidationResult {
  const factory BatchValidationResult({
    required bool isValid,
    required List<String> errors,
    required List<String> warnings,
    required BatchOperationType operationType,
  }) = _BatchValidationResult;

  const BatchValidationResult._();

  /// Check if validation has any issues
  bool get hasIssues => errors.isNotEmpty || warnings.isNotEmpty;

  /// Get validation summary message
  String get summary {
    if (isValid && warnings.isEmpty) {
      return 'Validation passed for ${operationType.toString().split('.').last}';
    } else if (isValid && warnings.isNotEmpty) {
      return 'Validation passed with ${warnings.length} warnings';
    } else {
      return 'Validation failed with ${errors.length} errors';
    }
  }
}

/// Comprehensive batch debugging information
@freezed
class BatchDebugInfo with _$BatchDebugInfo {
  const factory BatchDebugInfo({
    BatchOperationStatus? currentOperation,
    required int queuedOperations,
    required bool isBatchProcessing,
    required int totalOperations,
    required List<BatchOperationRecord> recentHistory,
    required BatchMetrics metrics,
    BatchResult? lastResult,
    required bool arraysInSync,
    required int imagesCount,
    required int thumbnailsCount,
    required int selectedCount,
  }) = _BatchDebugInfo;

  const BatchDebugInfo._();

  /// Get system health score (0.0 to 1.0)
  double get healthScore {
    double score = 1.0;

    // Penalize if arrays out of sync
    if (!arraysInSync) score -= 0.3;

    // Penalize high queue
    if (queuedOperations > 10) score -= 0.2;

    // Penalize if processing is taking too long
    if (currentOperation?.isTakingTooLong == true) score -= 0.2;

    // Penalize poor average performance
    if (metrics.averageProcessingTime.inMilliseconds > 200) score -= 0.2;

    // Penalize recent failures
    final recentFailures = recentHistory.where((r) => !r.wasSuccessful).length;
    if (recentFailures > 2) score -= 0.3;

    return score.clamp(0.0, 1.0);
  }

  /// Get health status description
  String get healthStatus {
    final score = healthScore;
    if (score >= 0.9) return 'Excellent';
    if (score >= 0.7) return 'Good';
    if (score >= 0.5) return 'Fair';
    if (score >= 0.3) return 'Poor';
    return 'Critical';
  }

  /// Check if immediate attention is needed
  bool get needsAttention => healthScore < 0.5;
}

/// Performance metrics for batch operations
@freezed
class BatchMetrics with _$BatchMetrics {
  const factory BatchMetrics({
    @Default(Duration.zero) Duration totalProcessingTime,
    @Default(0) int totalOperations,
    @Default(0) int totalBatches,
    @Default(Duration.zero) Duration averageProcessingTime,
    @Default(Duration.zero) Duration averageBatchTime,
    @Default(0) int totalOptimizations,
    @Default(0) int totalFailures,
    @Default({}) Map<BatchOperationType, int> operationTypeBreakdown,
    DateTime? lastResetTime,
  }) = _BatchMetrics;

  const BatchMetrics._();

  /// Get operations per batch average
  double get averageOperationsPerBatch => totalBatches > 0
      ? totalOperations / totalBatches
      : 0.0;

  /// Get failure rate (0.0 to 1.0)
  double get failureRate => totalOperations > 0
      ? totalFailures / totalOperations
      : 0.0;

  /// Get optimization rate (0.0 to 1.0)
  double get optimizationRate => totalBatches > 0
      ? totalOptimizations / totalBatches
      : 0.0;

  /// Check if metrics indicate good performance
  bool get isPerformanceGood {
    return averageProcessingTime.inMilliseconds < 100 &&
        failureRate < 0.1 &&
        optimizationRate > 0.5;
  }

  /// Get performance summary
  String get performanceSummary {
    final avgMs = averageProcessingTime.inMilliseconds;
    final failPercent = (failureRate * 100).toStringAsFixed(1);
    final optPercent = (optimizationRate * 100).toStringAsFixed(1);

    return 'Avg: ${avgMs}ms, Failures: $failPercent%, Optimizations: $optPercent%';
  }

  /// Update metrics with new batch result
  BatchMetrics updateWithBatch(BatchResult result) {
    final newTotalTime = totalProcessingTime + result.processingTime;
    final newTotalOps = totalOperations + result.operationsProcessed;
    final newTotalBatches = totalBatches + 1;
    final newFailures = totalFailures + result.failureCount;
    final newOptimizations = totalOptimizations + (result.wasOptimized ? 1 : 0);

    // Update operation type breakdown
    final updatedBreakdown = Map<BatchOperationType, int>.from(operationTypeBreakdown);
    updatedBreakdown[result.primaryOperationType] =
        (updatedBreakdown[result.primaryOperationType] ?? 0) + 1;

    return copyWith(
      totalProcessingTime: newTotalTime,
      totalOperations: newTotalOps,
      totalBatches: newTotalBatches,
      totalFailures: newFailures,
      totalOptimizations: newOptimizations,
      averageProcessingTime: Duration(
          microseconds: newTotalBatches > 0
              ? (newTotalTime.inMicroseconds / newTotalBatches).round()
              : 0
      ),
      averageBatchTime: Duration(
          microseconds: newTotalOps > 0
              ? (newTotalTime.inMicroseconds / newTotalOps).round()
              : 0
      ),
      operationTypeBreakdown: updatedBreakdown,
    );
  }
}