// File: lib/providers/photo_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/photo_state.dart';
import '../repositories/photo_repository.dart';

part 'photo_provider.g.dart';

/// Riverpod provider for photo state management
/// Now uses repository layer for all business logic
@riverpod
class PhotoNotifier extends _$PhotoNotifier {
  late final PhotoRepository _repository;

  @override
  PhotoState build() {
    // Initialize repository
    _repository = PhotoRepository();

    // Load saved images and header username
    _loadInitialData();

    return const PhotoState();
  }

  /// Load initial data (photos and header username)
  Future<void> _loadInitialData() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      // Load photos and header username in parallel
      final results = await Future.wait([
        _repository.loadAllSavedPhotos(),
        _repository.loadHeaderUsername(),
      ]);

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
          debugPrint('Migrated ${loadResult.migratedCount} images to app storage');
        }
        if (loadResult.hasRepairs) {
          debugPrint('Repaired ${loadResult.repairedCount} missing thumbnails');
        }
      } else {
        debugPrint('Failed to load photos: ${loadResult.error}');
        state = state.copyWith(
          headerUsername: headerUsername,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Error in _loadInitialData: $e');
      state = state.copyWith(isLoading: false);
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

  /// Save current image paths to storage
  Future<void> _saveImageOrder() async {
    try {
      final paths = state.images.map((f) => f.path).toList();
      final success = await _repository.saveImagePaths(paths);
      if (!success) {
        debugPrint('Failed to save image order');
      }
    } catch (e) {
      debugPrint('Error saving image order: $e');
    }
  }

  /// Pick and add multiple photos to the grid
  Future<void> addPhotos() async {
    if (state.isLoading) return;

    // Pick images
    final pickedFiles = await _repository.pickMultipleImages();
    if (pickedFiles.isEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      // Process all picked images
      final batchResult = await _repository.processBatchImages(pickedFiles);

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

        // Save the new image order
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

    } catch (e) {
      debugPrint('Error in addPhotos: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Toggle selection state for an image at the given index
  void toggleSelection(int index) {
    if (index < 0 || index >= state.images.length) {
      debugPrint('Invalid tap index: $index');
      return;
    }

    final currentSelection = Set<int>.from(state.selectedIndexes);
    if (currentSelection.contains(index)) {
      currentSelection.remove(index);
    } else {
      currentSelection.add(index);
    }

    state = state.copyWith(selectedIndexes: currentSelection);
  }

  /// Clear all selections
  void clearSelection() {
    state = state.copyWith(selectedIndexes: <int>{});
  }

  /// Show image preview modal for the given index
  void showImagePreview(int index) {
    if (index >= 0 && index < state.images.length) {
      state = state.copyWith(
        previewImageIndex: index,
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

  /// Reorder images by moving from oldIndex to newIndex
  Future<void> reorderImages(int oldIndex, int newIndex) async {
    // Validate indices
    if (oldIndex < 0 || oldIndex >= state.images.length ||
        newIndex < 0 || newIndex >= state.images.length ||
        oldIndex == newIndex) {
      debugPrint('Invalid reorder indices: old=$oldIndex, new=$newIndex');
      return;
    }

    // Also check thumbnails array
    if (oldIndex >= state.thumbnails.length || newIndex >= state.thumbnails.length) {
      debugPrint('Thumbnail array out of sync with images array');
      return;
    }

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
  }

  /// Show delete confirmation modal
  void showDeleteConfirmation() {
    state = state.copyWith(showDeleteConfirm: true);
  }

  /// Cancel delete operation
  void cancelDelete() {
    state = state.copyWith(showDeleteConfirm: false);
  }

  /// Confirm and execute delete operation
  Future<void> confirmDelete() async {
    state = state.copyWith(showDeleteConfirm: false);

    if (state.selectedIndexes.isEmpty) return;

    try {
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
    } catch (e) {
      debugPrint('Error in confirmDelete: $e');
    }
  }

  /// Share the currently selected image (only works with single selection)
  Future<void> shareSelectedImage() async {
    if (!state.hasSingleSelection) return;

    try {
      final imageIndex = state.firstSelectedIndex;
      if (imageIndex >= state.images.length) {
        throw Exception('Invalid image index');
      }

      final imageFile = state.images[imageIndex];
      final shareResult = await _repository.shareImage(imageFile);

      if (!shareResult.success) {
        debugPrint('Share failed: ${shareResult.error}');
      }

    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
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

  /// Save header username
  Future<void> saveHeaderUsername(String username) async {
    try {
      final success = await _repository.saveHeaderUsername(username);
      if (success) {
        state = state.copyWith(
          headerUsername: username,
          editingHeaderUsername: false,
        );
      } else {
        debugPrint('Failed to save header username');
        state = state.copyWith(editingHeaderUsername: false);
      }
    } catch (e) {
      debugPrint('Error saving header username: $e');
      state = state.copyWith(editingHeaderUsername: false);
    }
  }

  /// Cancel header username editing
  void cancelHeaderUsernameEditing() {
    state = state.copyWith(editingHeaderUsername: false);
  }

  /// Force refresh/reload of all images
  Future<void> refreshImages() async {
    await _loadInitialData();
  }

  /// Get storage statistics
  Future<StorageStats> getStorageStats() async {
    try {
      return await _repository.getStorageStats();
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return const StorageStats(
        totalImages: 0,
        totalBytes: 0,
        formattedSize: '0 B',
      );
    }
  }
}