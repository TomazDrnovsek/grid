// File: lib/models/photo_state.dart
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_state.freezed.dart';

/// Immutable state class for photo management using Freezed
/// Replaces the current setState-based state management in grid_home.dart
@freezed
class PhotoState with _$PhotoState {
  const factory PhotoState({
    /// List of full-resolution image files
    @Default([]) List<File> images,

    /// List of thumbnail files corresponding to images
    @Default([]) List<File> thumbnails,

    /// Set of selected image indexes
    @Default({}) Set<int> selectedIndexes,

    /// Loading state for image operations
    @Default(false) bool isLoading,

    /// Delete confirmation modal state
    @Default(false) bool showDeleteConfirm,

    /// Image preview modal state
    @Default(false) bool showImagePreview,

    /// Index of currently previewed image (-1 if none)
    @Default(-1) int previewImageIndex,

    /// Scroll position state (true if at top)
    @Default(true) bool isAtTop,

    /// Header username editing state
    @Default(false) bool editingHeaderUsername,

    /// Current header username value
    @Default('tomazdrnovsek') String headerUsername,

    /// Total count of images for convenience
    @Default(0) int imageCount,

    /// Whether arrays are in sync (safety check)
    @Default(true) bool arraysInSync,
  }) = _PhotoState;

  /// Empty state factory for initial state
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

  /// Safety check to ensure arrays are properly synchronized
  bool get isArraysSynchronized => images.length == thumbnails.length;

  /// Get valid selected indexes (within bounds)
  Set<int> get validSelectedIndexes {
    if (images.isEmpty) return {};
    final maxIndex = images.length - 1;
    return selectedIndexes.where((index) => index >= 0 && index <= maxIndex).toSet();
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