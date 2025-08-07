// File: lib/providers/photo_provider.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/photo_state.dart';
import '../repositories/photo_repository.dart';
import '../widgets/error_boundary.dart';
import '../services/performance_monitor.dart';

part 'photo_provider.g.dart';

/// ENHANCED: Batch operation types for intelligent operation grouping
enum BatchOperationType {
  addPhotos,
  deletePhotos,
  reorderPhotos,
  selectPhotos,
  deselectPhotos,
}

/// ENHANCED: Batch operation data container
class BatchOperation {
  final BatchOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  BatchOperation({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory constructors for different operation types
  factory BatchOperation.addPhotos(List<ProcessedImage> images) {
    return BatchOperation(
      type: BatchOperationType.addPhotos,
      data: {'images': images},
    );
  }

  factory BatchOperation.deletePhotos(List<int> indexes) {
    return BatchOperation(
      type: BatchOperationType.deletePhotos,
      data: {'indexes': indexes},
    );
  }

  factory BatchOperation.reorderPhoto(int oldIndex, int newIndex) {
    return BatchOperation(
      type: BatchOperationType.reorderPhotos,
      data: {'oldIndex': oldIndex, 'newIndex': newIndex},
    );
  }

  factory BatchOperation.selectPhotos(List<int> indexes) {
    return BatchOperation(
      type: BatchOperationType.selectPhotos,
      data: {'indexes': indexes},
    );
  }

  factory BatchOperation.deselectPhotos(List<int> indexes) {
    return BatchOperation(
      type: BatchOperationType.deselectPhotos,
      data: {'indexes': indexes},
    );
  }
}

/// ENHANCED: Batch processing result
class BatchResult {
  final int operationsProcessed;
  final int successCount;
  final int failureCount;
  final Duration processingTime;
  final List<String> errors;

  const BatchResult({
    required this.operationsProcessed,
    required this.successCount,
    required this.failureCount,
    required this.processingTime,
    this.errors = const [],
  });

  bool get isSuccess => failureCount == 0;
  bool get hasErrors => errors.isNotEmpty;
}

/// Riverpod provider for photo state management with ENHANCED batch processing
/// Reduces cascading rebuilds from multiple operations (5 photos = 1 state update)
@riverpod
class PhotoNotifier extends _$PhotoNotifier {
  // FIXED: Initialize repository as field initializer (null safety compliant)
  final PhotoRepository _repository = PhotoRepository();

  // ENHANCED: Batch operation infrastructure
  final List<BatchOperation> _batchQueue = [];
  Timer? _batchTimer;
  bool _isBatchProcessing = false;

  // ENHANCED: Batch configuration
  static const Duration _batchDelay = Duration(milliseconds: 100); // 100ms batch window
  static const int _maxBatchSize = 20; // Max operations per batch
  static const Duration _maxBatchAge = Duration(milliseconds: 500); // Max age before force processing

  @override
  PhotoState build() {
    // Schedule initial data loading after provider is built
    // FIXED: Use ref.onDispose for proper cleanup
    ref.onDispose(() {
      _cleanup();
    });

    // Schedule initial data loading
    Future.microtask(() {
      _loadInitialData();
    });

    // Return initial empty state
    return const PhotoState();
  }

  /// FIXED: Proper cleanup using Riverpod lifecycle
  void _cleanup() {
    // Clean up batch timer with null safety
    _batchTimer?.cancel();
    _batchTimer = null;

    // Clear batch queue
    _batchQueue.clear();

    if (kDebugMode) {
      debugPrint('PhotoNotifier disposed and cleaned up');
    }
  }

  /// ENHANCED: Add operation to batch queue with intelligent scheduling
  void _enqueueBatchOperation(BatchOperation operation) {
    try {
      _batchQueue.add(operation);

      // ENHANCED: Smart batch scheduling logic
      if (_shouldProcessBatchImmediately()) {
        _processBatchImmediately();
      } else {
        _scheduleBatchProcessing();
      }

      if (kDebugMode) {
        debugPrint('📦 Batch: Enqueued ${operation.type} (queue: ${_batchQueue.length})');
      }

    } catch (e) {
      debugPrint('Error enqueueing batch operation: $e');
      // Fallback: process operation immediately without batching
      _processSingleOperation(operation);
    }
  }

  /// ENHANCED: Smart batch scheduling with performance optimization
  void _scheduleBatchProcessing() {
    _batchTimer?.cancel();

    _batchTimer = Timer(_batchDelay, () {
      if (_batchQueue.isNotEmpty) {
        _processBatch();
      }
    });
  }

  /// ENHANCED: Determine if batch should be processed immediately
  bool _shouldProcessBatchImmediately() {
    if (_batchQueue.isEmpty) return false;

    // Process immediately if:
    // 1. Queue is full
    if (_batchQueue.length >= _maxBatchSize) return true;

    // 2. Oldest operation is too old
    final oldestOperation = _batchQueue.first;
    final age = DateTime.now().difference(oldestOperation.timestamp);
    if (age > _maxBatchAge) return true;

    // 3. Critical operations that need immediate processing
    final criticalTypes = {
      BatchOperationType.deletePhotos,
      BatchOperationType.reorderPhotos,
    };
    if (_batchQueue.any((op) => criticalTypes.contains(op.type))) return true;

    return false;
  }

  /// ENHANCED: Process batch immediately for critical operations
  void _processBatchImmediately() {
    _batchTimer?.cancel();
    _processBatch();
  }

  /// ENHANCED: Core batch processing with optimized state updates
  Future<void> _processBatch() async {
    if (_isBatchProcessing || _batchQueue.isEmpty) return;

    _isBatchProcessing = true;
    final startTime = DateTime.now();

    try {
      // Start performance monitoring
      PerformanceMonitor.instance.startOperation('batch_processing');

      // Create a copy of the queue for processing
      final operationsToProcess = List<BatchOperation>.from(_batchQueue);
      _batchQueue.clear();

      if (kDebugMode) {
        debugPrint('📦 Batch: Processing ${operationsToProcess.length} operations');
      }

      // ENHANCED: Group and optimize operations
      final optimizedOperations = _optimizeBatchOperations(operationsToProcess);

      // Process each operation type in optimized order
      await _processBatchOperations(optimizedOperations);

      // End performance monitoring
      PerformanceMonitor.instance.endOperation('batch_processing');

      final processingTime = DateTime.now().difference(startTime);
      if (kDebugMode) {
        debugPrint('📦 Batch: Completed in ${processingTime.inMilliseconds}ms');
      }

    } catch (e) {
      debugPrint('Error in batch processing: $e');
      PerformanceMonitor.instance.endOperation('batch_processing');
    } finally {
      _isBatchProcessing = false;
    }
  }

  /// ENHANCED: Optimize batch operations by grouping and deduplicating
  Map<BatchOperationType, List<BatchOperation>> _optimizeBatchOperations(
      List<BatchOperation> operations
      ) {
    final grouped = <BatchOperationType, List<BatchOperation>>{};

    for (final operation in operations) {
      grouped.putIfAbsent(operation.type, () => []).add(operation);
    }

    // ENHANCED: Deduplicate and optimize within each group
    for (final type in grouped.keys) {
      switch (type) {
        case BatchOperationType.selectPhotos:
        case BatchOperationType.deselectPhotos:
        // Combine all selection operations
          grouped[type] = _optimizeSelectionOperations(grouped[type]!);
          break;
        case BatchOperationType.deletePhotos:
        // Combine all delete operations
          grouped[type] = _optimizeDeleteOperations(grouped[type]!);
          break;
        default:
        // Keep other operations as-is
          break;
      }
    }

    return grouped;
  }

  /// ENHANCED: Optimize selection operations by combining indexes
  List<BatchOperation> _optimizeSelectionOperations(List<BatchOperation> operations) {
    if (operations.isEmpty) return [];

    final allIndexes = <int>{};
    for (final op in operations) {
      final indexes = op.data['indexes'] as List<int>? ?? [];
      allIndexes.addAll(indexes);
    }

    if (allIndexes.isEmpty) return [];

    // Return single optimized operation
    return [BatchOperation(
      type: operations.first.type,
      data: {'indexes': allIndexes.toList()},
    )];
  }

  /// ENHANCED: Optimize delete operations by combining indexes
  List<BatchOperation> _optimizeDeleteOperations(List<BatchOperation> operations) {
    if (operations.isEmpty) return [];

    final allIndexes = <int>{};
    for (final op in operations) {
      final indexes = op.data['indexes'] as List<int>? ?? [];
      allIndexes.addAll(indexes);
    }

    if (allIndexes.isEmpty) return [];

    // Return single optimized operation
    return [BatchOperation.deletePhotos(allIndexes.toList())];
  }

  /// ENHANCED: Process grouped batch operations with single state update
  Future<void> _processBatchOperations(
      Map<BatchOperationType, List<BatchOperation>> groupedOperations
      ) async {
    // Track what needs to be updated in final state
    PhotoState updatedState = state;

    // Process each operation type
    for (final type in _getOptimalProcessingOrder()) {
      final operations = groupedOperations[type];
      if (operations == null || operations.isEmpty) continue;

      switch (type) {
        case BatchOperationType.addPhotos:
          updatedState = await _processBatchAddPhotos(operations, updatedState);
          break;
        case BatchOperationType.deletePhotos:
          updatedState = await _processBatchDeletePhotos(operations, updatedState);
          break;
        case BatchOperationType.selectPhotos:
          updatedState = _processBatchSelectPhotos(operations, updatedState);
          break;
        case BatchOperationType.deselectPhotos:
          updatedState = _processBatchDeselectPhotos(operations, updatedState);
          break;
        case BatchOperationType.reorderPhotos:
          updatedState = await _processBatchReorderPhotos(operations, updatedState);
          break;
      }
    }

    // ENHANCED: Single state update for entire batch
    if (updatedState != state) {
      state = updatedState;
      if (kDebugMode) {
        debugPrint('📦 Batch: Applied single state update');
      }
    }
  }

  /// ENHANCED: Optimal processing order for batch operations
  List<BatchOperationType> _getOptimalProcessingOrder() {
    return [
      BatchOperationType.deletePhotos,    // Process deletions first
      BatchOperationType.addPhotos,       // Then additions
      BatchOperationType.reorderPhotos,   // Then reordering
      BatchOperationType.selectPhotos,    // Then selections
      BatchOperationType.deselectPhotos,  // Finally deselections
    ];
  }

  /// ENHANCED: Process batch add photos operations
  Future<PhotoState> _processBatchAddPhotos(
      List<BatchOperation> operations,
      PhotoState currentState
      ) async {
    final allNewImages = <File>[];
    final allNewThumbnails = <File>[];

    for (final operation in operations) {
      final images = operation.data['images'] as List<ProcessedImage>? ?? [];
      for (final processed in images) {
        allNewImages.add(processed.image);
        allNewThumbnails.add(processed.thumbnail);
      }
    }

    if (allNewImages.isEmpty) return currentState;

    // Insert all new images at the beginning
    final updatedImages = [...allNewImages.reversed, ...currentState.images];
    final updatedThumbnails = [...allNewThumbnails.reversed, ...currentState.thumbnails];

    // Save the new image order
    await _saveImageOrder();

    return currentState.copyWith(
      images: updatedImages,
      thumbnails: updatedThumbnails,
      imageCount: updatedImages.length,
      arraysInSync: updatedImages.length == updatedThumbnails.length,
    );
  }

  /// ENHANCED: Process batch delete photos operations
  Future<PhotoState> _processBatchDeletePhotos(
      List<BatchOperation> operations,
      PhotoState currentState
      ) async {
    final allIndexesToDelete = <int>{};

    for (final operation in operations) {
      final indexes = operation.data['indexes'] as List<int>? ?? [];
      allIndexesToDelete.addAll(indexes);
    }

    if (allIndexesToDelete.isEmpty) return currentState;

    final sorted = allIndexesToDelete.toList()..sort((a, b) => b.compareTo(a));

    final imagesToDelete = <File>[];
    final thumbnailsToDelete = <File>[];
    final newImages = List<File>.from(currentState.images);
    final newThumbnails = List<File>.from(currentState.thumbnails);

    // Collect files to delete and remove from arrays
    for (final i in sorted) {
      if (i >= 0 && i < newImages.length && i < newThumbnails.length) {
        imagesToDelete.add(newImages[i]);
        thumbnailsToDelete.add(newThumbnails[i]);
        newImages.removeAt(i);
        newThumbnails.removeAt(i);
      }
    }

    // Perform background operations
    if (imagesToDelete.isNotEmpty) {
      final deleteResult = await _repository.deleteImages(imagesToDelete, thumbnailsToDelete);
      debugPrint('Batch delete result: ${deleteResult.deletedCount}/${deleteResult.requestedCount} files deleted');

      // Save updated order and cleanup
      await _saveImageOrder();
      await _repository.cleanupOrphanedThumbnails(newImages.map((f) => f.path).toList());
    }

    return currentState.copyWith(
      images: newImages,
      thumbnails: newThumbnails,
      selectedIndexes: <int>{}, // Clear selections after delete
      imageCount: newImages.length,
      arraysInSync: newImages.length == newThumbnails.length,
    );
  }

  /// ENHANCED: Process batch select photos operations
  PhotoState _processBatchSelectPhotos(
      List<BatchOperation> operations,
      PhotoState currentState
      ) {
    final newSelection = Set<int>.from(currentState.selectedIndexes);

    for (final operation in operations) {
      final indexes = operation.data['indexes'] as List<int>? ?? [];
      for (final index in indexes) {
        if (index >= 0 && index < currentState.images.length) {
          newSelection.add(index);
        }
      }
    }

    return currentState.copyWith(selectedIndexes: newSelection);
  }

  /// ENHANCED: Process batch deselect photos operations
  PhotoState _processBatchDeselectPhotos(
      List<BatchOperation> operations,
      PhotoState currentState
      ) {
    final newSelection = Set<int>.from(currentState.selectedIndexes);

    for (final operation in operations) {
      final indexes = operation.data['indexes'] as List<int>? ?? [];
      for (final index in indexes) {
        newSelection.remove(index);
      }
    }

    return currentState.copyWith(selectedIndexes: newSelection);
  }

  /// ENHANCED: Process batch reorder photos operations
  Future<PhotoState> _processBatchReorderPhotos(
      List<BatchOperation> operations,
      PhotoState currentState
      ) async {
    var newImages = List<File>.from(currentState.images);
    var newThumbnails = List<File>.from(currentState.thumbnails);

    // Apply reorder operations sequentially
    for (final operation in operations) {
      final oldIndex = operation.data['oldIndex'] as int?;
      final newIndex = operation.data['newIndex'] as int?;

      if (oldIndex != null && newIndex != null &&
          oldIndex >= 0 && oldIndex < newImages.length &&
          newIndex >= 0 && newIndex < newImages.length &&
          oldIndex != newIndex) {

        final movedImage = newImages.removeAt(oldIndex);
        final movedThumbnail = newThumbnails.removeAt(oldIndex);

        newImages.insert(newIndex, movedImage);
        newThumbnails.insert(newIndex, movedThumbnail);
      }
    }

    await _saveImageOrder();

    return currentState.copyWith(
      images: newImages,
      thumbnails: newThumbnails,
      selectedIndexes: <int>{}, // Clear selection during reorder
    );
  }

  /// ENHANCED: Fallback for processing single operation without batching
  Future<void> _processSingleOperation(BatchOperation operation) async {
    try {
      switch (operation.type) {
        case BatchOperationType.addPhotos:
          final images = operation.data['images'] as List<ProcessedImage>? ?? [];
          await _applySingleAddPhotos(images);
          break;
        case BatchOperationType.deletePhotos:
          final indexes = operation.data['indexes'] as List<int>? ?? [];
          await _applySingleDeletePhotos(indexes);
          break;
        case BatchOperationType.selectPhotos:
          final indexes = operation.data['indexes'] as List<int>? ?? [];
          _applySingleSelectPhotos(indexes);
          break;
        case BatchOperationType.deselectPhotos:
          final indexes = operation.data['indexes'] as List<int>? ?? [];
          _applySingleDeselectPhotos(indexes);
          break;
        case BatchOperationType.reorderPhotos:
          final oldIndex = operation.data['oldIndex'] as int?;
          final newIndex = operation.data['newIndex'] as int?;
          if (oldIndex != null && newIndex != null) {
            await _applySingleReorderPhotos(oldIndex, newIndex);
          }
          break;
      }
    } catch (e) {
      debugPrint('Error processing single operation: $e');
    }
  }

  /// Load initial data (photos and header username) with error handling
  Future<void> _loadInitialData() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      // Start performance monitoring for initial data load
      PerformanceMonitor.instance.startOperation('load_initial_data');

      // Use error handler for safe async operations
      final results = await RepositoryErrorHandler.handleAsyncOperation(
            () async {
          // Debug: Print migration status
          if (kDebugMode) {
            await _repository.printMigrationStatus();
          }

          // Load photos and header username in parallel
          return await Future.wait([
            _repository.loadAllSavedPhotos(),
            _repository.loadHeaderUsername(),
          ]);
        },
        fallbackValue: [
          const LoadPhotosResult(
            images: <File>[],
            thumbnails: <File>[],
            validPaths: <String>[],
            migratedCount: 0,
            repairedCount: 0,
            error: 'Failed to load initial data',
          ),
          'tomazdrnovsek' // Default username
        ],
        context: 'Initial Data Load',
      );

      final loadResult = results[0] as LoadPhotosResult;
      final headerUsername = results[1] as String;

      if (loadResult.isSuccess) {
        state = state.copyWith(
          images: loadResult.images,
          thumbnails: loadResult.thumbnails,
          imageCount: loadResult.images.length,
          arraysInSync: loadResult.images.length == loadResult.thumbnails.length,
          headerUsername: headerUsername,
          isLoading: false,
          // Clear any invalid selections
          selectedIndexes: _validateSelectedIndexes(state.selectedIndexes, loadResult.images.length),
        );

        // Log migration and repair results
        if (loadResult.hasMigrations) {
          debugPrint('✅ Migrated ${loadResult.migratedCount} images to database');
        }
        if (loadResult.hasRepairs) {
          debugPrint('🔧 Repaired ${loadResult.repairedCount} missing thumbnails');
        }
      } else {
        debugPrint('Failed to load photos: ${loadResult.error}');
        state = state.copyWith(
          headerUsername: headerUsername,
          isLoading: false,
        );
      }

      // End performance monitoring
      PerformanceMonitor.instance.endOperation('load_initial_data');

    } catch (e) {
      debugPrint('Critical error in _loadInitialData: $e');
      PerformanceMonitor.instance.endOperation('load_initial_data');
      state = state.copyWith(
        isLoading: false,
        headerUsername: 'tomazdrnovsek', // Fallback username
      );
    }
  }

  /// Validates and cleans up selected indexes to ensure they're within bounds
  Set<int> _validateSelectedIndexes(Set<int> currentSelection, int maxCount) {
    if (currentSelection.isEmpty || maxCount == 0) return <int>{};

    final maxIndex = maxCount - 1;
    final validIndexes = currentSelection.where((index) => index >= 0 && index <= maxIndex).toSet();

    if (validIndexes.length != currentSelection.length) {
      debugPrint('Removed invalid selected indexes');
    }

    return validIndexes;
  }

  /// Save current image paths to storage with error handling
  Future<void> _saveImageOrder() async {
    await RepositoryErrorHandler.handleAsyncOperation(
          () async {
        final paths = state.images.map((f) => f.path).toList();
        final success = await _repository.saveImagePaths(paths);
        if (!success) {
          throw Exception('Failed to save image order to database');
        }
      },
      fallbackValue: null,
      context: 'Save Image Order',
    );
  }

  // ============================================================================
  // PUBLIC API METHODS - ENHANCED with batch operations
  // ============================================================================

  /// ENHANCED: Pick and add multiple photos with batch processing
  Future<void> addPhotos() async {
    if (state.isLoading) return;

    // Start performance monitoring
    PerformanceMonitor.instance.startOperation('add_photos');

    // Pick images with error handling
    PerformanceMonitor.instance.startOperation('pick_images');
    final pickedFiles = await RepositoryErrorHandler.handleAsyncOperation(
          () => _repository.pickMultipleImages(),
      fallbackValue: <XFile>[],
      context: 'Image Picker',
    );
    PerformanceMonitor.instance.endOperation('pick_images');

    if (pickedFiles.isEmpty) {
      PerformanceMonitor.instance.endOperation('add_photos');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // Process all picked images with error handling
      PerformanceMonitor.instance.startOperation('process_batch_images');
      final batchResult = await RepositoryErrorHandler.handleAsyncOperation(
            () => _repository.processBatchImages(pickedFiles),
        fallbackValue: const BatchImageResult(
          processedImages: <ProcessedImage>[],
          successCount: 0,
          failureCount: 0,
          errors: ['Failed to process images'],
        ),
        context: 'Batch Image Processing',
      );
      PerformanceMonitor.instance.endOperation('process_batch_images');

      if (batchResult.processedImages.isNotEmpty) {
        // ENHANCED: Use batch operation instead of direct state update
        _enqueueBatchOperation(BatchOperation.addPhotos(batchResult.processedImages));

        debugPrint('📦 Batch: Added ${batchResult.successCount} images to queue');
      }

      state = state.copyWith(isLoading: false);

      // Log any failures
      if (batchResult.failureCount > 0) {
        debugPrint('Failed to process ${batchResult.failureCount} images');
        for (final error in batchResult.errors) {
          debugPrint('  Error: $error');
        }
      }

      // End performance monitoring
      PerformanceMonitor.instance.endOperation('add_photos');

    } catch (e) {
      debugPrint('Critical error in addPhotos: $e');
      PerformanceMonitor.instance.endOperation('add_photos');
      state = state.copyWith(isLoading: false);
    }
  }

  /// ENHANCED: Toggle selection state with batch processing for rapid selections
  void toggleSelection(int index) {
    // Validate index with error handling
    final validatedIndex = RepositoryErrorHandler.handleSyncOperation(
          () {
        if (index < 0 || index >= state.images.length) {
          throw Exception('Invalid tap index: $index (max: ${state.images.length - 1})');
        }
        return index;
      },
      fallbackValue: -1,
      context: 'Toggle Selection Validation',
    );

    if (validatedIndex == -1) {
      debugPrint('Invalid selection index ignored: $index');
      return;
    }

    final currentSelection = Set<int>.from(state.selectedIndexes);
    if (currentSelection.contains(validatedIndex)) {
      // ENHANCED: Use batch operation for deselection
      _enqueueBatchOperation(BatchOperation.deselectPhotos([validatedIndex]));
    } else {
      // ENHANCED: Use batch operation for selection
      _enqueueBatchOperation(BatchOperation.selectPhotos([validatedIndex]));
    }
  }

  /// Clear all selections
  void clearSelection() {
    if (state.selectedIndexes.isNotEmpty) {
      // ENHANCED: Use batch operation for clearing selections
      _enqueueBatchOperation(BatchOperation.deselectPhotos(state.selectedIndexes.toList()));
    }
  }

  /// Show image preview modal for the given index with validation
  void showImagePreview(int index) {
    final validIndex = RepositoryErrorHandler.handleSyncOperation(
          () {
        if (index < 0 || index >= state.images.length) {
          throw Exception('Invalid preview index: $index');
        }
        return index;
      },
      fallbackValue: -1,
      context: 'Image Preview Validation',
    );

    if (validIndex >= 0) {
      state = state.copyWith(
        previewImageIndex: validIndex,
        showImagePreview: true,
      );
    }
  }

  /// Close image preview modal
  void closeImagePreview() {
    state = state.copyWith(
      showImagePreview: false,
      previewImageIndex: -1,
    );
  }

  /// ENHANCED: Reorder images IMMEDIATELY (no batching for smooth drag UX)
  Future<void> reorderImages(int oldIndex, int newIndex) async {
    // Validate indices with error handling
    final validation = RepositoryErrorHandler.handleSyncOperation(
          () {
        if (oldIndex < 0 || oldIndex >= state.images.length ||
            newIndex < 0 || newIndex >= state.images.length ||
            oldIndex == newIndex) {
          throw Exception('Invalid reorder indices: old=$oldIndex, new=$newIndex');
        }

        // Also check thumbnails array
        if (oldIndex >= state.thumbnails.length || newIndex >= state.thumbnails.length) {
          throw Exception('Thumbnail array out of sync with images array');
        }

        return true;
      },
      fallbackValue: false,
      context: 'Reorder Validation',
    );

    if (!validation) {
      debugPrint('Invalid reorder operation ignored');
      return;
    }

    // FIXED: Process reorder immediately for smooth drag UX (no batching)
    await _applySingleReorderPhotos(oldIndex, newIndex);
  }

  /// Show delete confirmation modal
  void showDeleteConfirmation() {
    state = state.copyWith(showDeleteConfirm: true);
  }

  /// Cancel delete operation
  void cancelDelete() {
    state = state.copyWith(showDeleteConfirm: false);
  }

  /// ENHANCED: Confirm and execute delete operation with batch processing
  Future<void> confirmDelete() async {
    state = state.copyWith(showDeleteConfirm: false);

    if (state.selectedIndexes.isEmpty) return;

    // Start performance monitoring
    PerformanceMonitor.instance.startOperation('delete_photos');

    try {
      // ENHANCED: Use batch operation for deleting
      _enqueueBatchOperation(BatchOperation.deletePhotos(state.selectedIndexes.toList()));

      // End performance monitoring
      PerformanceMonitor.instance.endOperation('delete_photos');

    } catch (e) {
      debugPrint('Critical error in confirmDelete: $e');
      PerformanceMonitor.instance.endOperation('delete_photos');
    }
  }

  /// Share the currently selected image (only works with single selection) with error handling
  Future<void> shareSelectedImage() async {
    if (!state.hasSingleSelection) return;

    await RepositoryErrorHandler.handleAsyncOperation(
          () async {
        final imageIndex = state.firstSelectedIndex;
        if (imageIndex >= state.images.length) {
          throw Exception('Invalid image index for sharing');
        }

        final imageFile = state.images[imageIndex];
        final shareResult = await _repository.shareImage(imageFile);

        if (!shareResult.success) {
          throw Exception('Share failed: ${shareResult.error}');
        }
      },
      fallbackValue: null,
      context: 'Share Image',
    );
  }

  /// Update scroll position state
  void updateScrollPosition(bool isAtTop) {
    if (state.isAtTop != isAtTop) {
      state = state.copyWith(isAtTop: isAtTop);
    }
  }

  /// Start editing header username
  void startEditingHeaderUsername() {
    state = state.copyWith(editingHeaderUsername: true);
  }

  /// Save header username with error handling
  Future<void> saveHeaderUsername(String username) async {
    PerformanceMonitor.instance.startOperation('save_header_username');

    await RepositoryErrorHandler.handleAsyncOperation(
          () async {
        final success = await _repository.saveHeaderUsername(username);
        if (success) {
          state = state.copyWith(
            headerUsername: username,
            editingHeaderUsername: false,
          );
        } else {
          throw Exception('Failed to save header username to database');
        }
      },
      fallbackValue: null,
      context: 'Save Header Username',
    );

    // End monitoring
    PerformanceMonitor.instance.endOperation('save_header_username');

    // Ensure editing state is cleared even if save fails
    if (state.editingHeaderUsername) {
      state = state.copyWith(editingHeaderUsername: false);
    }
  }

  /// Cancel header username editing
  void cancelHeaderUsernameEditing() {
    state = state.copyWith(editingHeaderUsername: false);
  }

  /// Force refresh/reload of all images with error handling
  Future<void> refreshImages() async {
    await RepositoryErrorHandler.handleAsyncOperation(
          () => _loadInitialData(),
      fallbackValue: null,
      context: 'Refresh Images',
    );
  }

  /// Get storage statistics with error handling
  Future<StorageStats> getStorageStats() async {
    return await RepositoryErrorHandler.handleAsyncOperation(
          () => _repository.getStorageStats(),
      fallbackValue: const StorageStats(
        totalImages: 0,
        totalBytes: 0,
        formattedSize: '0 B',
      ),
      context: 'Storage Statistics',
    );
  }

  // ============================================================================
  // FALLBACK METHODS - For single operation processing when batching fails
  // ============================================================================

  Future<void> _applySingleAddPhotos(List<ProcessedImage> images) async {
    final newImages = images.map((p) => p.image).toList();
    final newThumbnails = images.map((p) => p.thumbnail).toList();

    final updatedImages = [...newImages.reversed, ...state.images];
    final updatedThumbnails = [...newThumbnails.reversed, ...state.thumbnails];

    state = state.copyWith(
      images: updatedImages,
      thumbnails: updatedThumbnails,
      imageCount: updatedImages.length,
      arraysInSync: updatedImages.length == updatedThumbnails.length,
    );

    await _saveImageOrder();
  }

  Future<void> _applySingleDeletePhotos(List<int> indexes) async {
    final sorted = indexes.toList()..sort((a, b) => b.compareTo(a));

    final imagesToDelete = <File>[];
    final thumbnailsToDelete = <File>[];
    final newImages = List<File>.from(state.images);
    final newThumbnails = List<File>.from(state.thumbnails);

    for (final i in sorted) {
      if (i >= 0 && i < newImages.length && i < newThumbnails.length) {
        imagesToDelete.add(newImages[i]);
        thumbnailsToDelete.add(newThumbnails[i]);
        newImages.removeAt(i);
        newThumbnails.removeAt(i);
      }
    }

    state = state.copyWith(
      images: newImages,
      thumbnails: newThumbnails,
      selectedIndexes: <int>{},
      imageCount: newImages.length,
      arraysInSync: newImages.length == newThumbnails.length,
    );

    if (imagesToDelete.isNotEmpty) {
      await _repository.deleteImages(imagesToDelete, thumbnailsToDelete);
      await _saveImageOrder();
      await _repository.cleanupOrphanedThumbnails(newImages.map((f) => f.path).toList());
    }
  }

  void _applySingleSelectPhotos(List<int> indexes) {
    final newSelection = Set<int>.from(state.selectedIndexes);
    for (final index in indexes) {
      if (index >= 0 && index < state.images.length) {
        newSelection.add(index);
      }
    }
    state = state.copyWith(selectedIndexes: newSelection);
  }

  void _applySingleDeselectPhotos(List<int> indexes) {
    final newSelection = Set<int>.from(state.selectedIndexes);
    for (final index in indexes) {
      newSelection.remove(index);
    }
    state = state.copyWith(selectedIndexes: newSelection);
  }

  Future<void> _applySingleReorderPhotos(int oldIndex, int newIndex) async {
    final newImages = List<File>.from(state.images);
    final newThumbnails = List<File>.from(state.thumbnails);

    final movedImage = newImages.removeAt(oldIndex);
    final movedThumbnail = newThumbnails.removeAt(oldIndex);

    newImages.insert(newIndex, movedImage);
    newThumbnails.insert(newIndex, movedThumbnail);

    state = state.copyWith(
      images: newImages,
      thumbnails: newThumbnails,
      selectedIndexes: <int>{},
    );

    await _saveImageOrder();
  }

// ============================================================================
// NOTE: Riverpod AutoDisposeNotifier handles cleanup automatically
// The ref.onDispose() method ensures proper resource cleanup
// ============================================================================
}