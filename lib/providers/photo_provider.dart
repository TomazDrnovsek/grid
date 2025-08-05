// File: lib/providers/photo_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/photo_state.dart';
import '../repositories/photo_repository.dart';
import '../widgets/error_boundary.dart';
import '../services/performance_monitor.dart';

part 'photo_provider.g.dart';

/// Riverpod provider for photo state management with comprehensive error handling
/// Now uses repository layer for all business logic with error boundaries
@riverpod
class PhotoNotifier extends _$PhotoNotifier {
  late final PhotoRepository _repository;

  @override
  PhotoState build() {
    // Initialize repository
    _repository = PhotoRepository();

    // Schedule initial data loading after provider is built
    Future.microtask(() => _loadInitialData());

    // Return initial empty state
    return const PhotoState();
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

  /// Pick and add multiple photos to the grid with comprehensive error handling
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
        // Extract images and thumbnails
        final newImages = batchResult.processedImages.map((p) => p.image).toList();
        final newThumbnails = batchResult.processedImages.map((p) => p.thumbnail).toList();

        // Insert all new images at the beginning
        final updatedImages = [...newImages.reversed, ...state.images];
        final updatedThumbnails = [...newThumbnails.reversed, ...state.thumbnails];

        state = state.copyWith(
          images: updatedImages,
          thumbnails: updatedThumbnails,
          imageCount: updatedImages.length,
          arraysInSync: updatedImages.length == updatedThumbnails.length,
          isLoading: false,
        );

        // Save the new image order with error handling
        await _saveImageOrder();

        debugPrint('Added ${batchResult.successCount} images successfully');
      } else {
        state = state.copyWith(isLoading: false);
      }

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

  /// Toggle selection state for an image at the given index
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
      currentSelection.remove(validatedIndex);
    } else {
      currentSelection.add(validatedIndex);
    }

    state = state.copyWith(selectedIndexes: currentSelection);
  }

  /// Clear all selections
  void clearSelection() {
    state = state.copyWith(selectedIndexes: <int>{});
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

  /// Reorder images by moving from oldIndex to newIndex with error handling
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

    try {
      // Clear selection and reorder
      final newImages = List<File>.from(state.images);
      final newThumbnails = List<File>.from(state.thumbnails);

      final movedImage = newImages.removeAt(oldIndex);
      final movedThumbnail = newThumbnails.removeAt(oldIndex);

      newImages.insert(newIndex, movedImage);
      newThumbnails.insert(newIndex, movedThumbnail);

      state = state.copyWith(
        images: newImages,
        thumbnails: newThumbnails,
        selectedIndexes: <int>{}, // Clear selection during reorder
      );

      await _saveImageOrder();
    } catch (e) {
      debugPrint('Error in reorderImages: $e');
    }
  }

  /// Show delete confirmation modal
  void showDeleteConfirmation() {
    state = state.copyWith(showDeleteConfirm: true);
  }

  /// Cancel delete operation
  void cancelDelete() {
    state = state.copyWith(showDeleteConfirm: false);
  }

  /// Confirm and execute delete operation with comprehensive error handling
  Future<void> confirmDelete() async {
    state = state.copyWith(showDeleteConfirm: false);

    if (state.selectedIndexes.isEmpty) return;

    // Start performance monitoring
    PerformanceMonitor.instance.startOperation('delete_photos');

    try {
      await RepositoryErrorHandler.handleAsyncOperation(
            () async {
          final sorted = state.selectedIndexes.toList()..sort((a, b) => b.compareTo(a));

          final imagesToDelete = <File>[];
          final thumbnailsToDelete = <File>[];
          final newImages = List<File>.from(state.images);
          final newThumbnails = List<File>.from(state.thumbnails);

          // Collect files to delete and remove from arrays
          for (final i in sorted) {
            if (i >= 0 && i < newImages.length && i < newThumbnails.length) {
              imagesToDelete.add(newImages[i]);
              thumbnailsToDelete.add(newThumbnails[i]);
              newImages.removeAt(i);
              newThumbnails.removeAt(i);
            } else {
              debugPrint('Warning: Invalid index $i for deletion');
            }
          }

          // Update state immediately
          state = state.copyWith(
            images: newImages,
            thumbnails: newThumbnails,
            selectedIndexes: <int>{},
            imageCount: newImages.length,
            arraysInSync: newImages.length == newThumbnails.length,
          );

          // Perform background operations
          if (imagesToDelete.isNotEmpty) {
            // Delete files using repository
            final deleteResult = await _repository.deleteImages(imagesToDelete, thumbnailsToDelete);
            debugPrint('Delete result: ${deleteResult.deletedCount}/${deleteResult.requestedCount} files deleted');

            if (!deleteResult.success) {
              debugPrint('Delete operation had issues: ${deleteResult.error}');
            }

            // Save updated order and cleanup
            await _saveImageOrder();
            await _repository.cleanupOrphanedThumbnails(state.images.map((f) => f.path).toList());
          }
        },
        fallbackValue: null,
        context: 'Delete Operation',
      );

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
}