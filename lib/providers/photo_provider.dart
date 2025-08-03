// File: lib/providers/photo_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/photo_state.dart';
import '../file_utils.dart';

part 'photo_provider.g.dart';

/// Riverpod provider for photo state management
/// Replaces the setState-based state management from grid_home.dart
@riverpod
class PhotoNotifier extends _$PhotoNotifier {
  @override
  PhotoState build() {
    // Initialize with empty state and start loading saved images
    _loadSavedImages();
    return const PhotoState();
  }

  /// Load saved paths, migrate external files into app storage if needed.
  /// Migrated from grid_home.dart _loadSavedImages method
  Future<void> _loadSavedImages() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList('grid_image_paths');
      if (stored == null || stored.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final appDir = await FileUtils.getAppImagesDir();
      final List<String> validPaths = [];
      final List<File> loadedImages = [];
      final List<File> loadedThumbnails = [];

      // Process all images without batching to avoid state issues
      for (final path in stored) {
        try {
          final file = File(path);
          if (!file.existsSync()) {
            debugPrint('Skipping non-existent file: $path');
            continue;
          }

          String finalPath = path;

          // Migrate if needed
          if (!path.startsWith(appDir.path)) {
            try {
              final result = await FileUtils.processImageWithThumbnail(XFile(path));
              finalPath = result['image']!.path;
              debugPrint('Migrated image to: $finalPath');
            } catch (e) {
              debugPrint('Migration failed for $path: $e');
              continue;
            }
          }

          // Verify the image file still exists
          final imageFile = File(finalPath);
          if (!await imageFile.exists()) {
            debugPrint('Image file not found after migration: $finalPath');
            continue;
          }

          // Try to get or generate thumbnail
          File thumbnailFile;
          try {
            final existingThumbnail = await FileUtils.getThumbnailForImage(finalPath);
            if (existingThumbnail != null && await existingThumbnail.exists()) {
              thumbnailFile = existingThumbnail;
            } else {
              debugPrint('Generating missing thumbnail for: $finalPath');
              thumbnailFile = await FileUtils.generateThumbnail(XFile(finalPath));
            }
          } catch (e) {
            debugPrint('Thumbnail handling failed for $finalPath: $e');
            // Use original image as fallback
            thumbnailFile = imageFile;
          }

          // Add to arrays
          loadedImages.add(imageFile);
          loadedThumbnails.add(thumbnailFile);
          validPaths.add(finalPath);

        } catch (e) {
          debugPrint('Error processing image at $path: $e');
          continue;
        }
      }

      // Save only valid paths
      if (validPaths.length != stored.length) {
        await prefs.setStringList('grid_image_paths', validPaths);
        debugPrint('Updated stored paths: ${validPaths.length} valid out of ${stored.length}');
      }

      // Repair any missing thumbnails
      debugPrint('Checking for missing thumbnails...');
      final repairedCount = await FileUtils.repairMissingThumbnails(validPaths);
      if (repairedCount > 0) {
        debugPrint('Repaired $repairedCount missing thumbnails');

        // Reload thumbnails after repair
        final repairedThumbnails = <File>[];
        for (final imagePath in validPaths) {
          final thumbnail = await FileUtils.getThumbnailForImage(imagePath);
          repairedThumbnails.add(thumbnail ?? File(imagePath));
        }
        loadedThumbnails.clear();
        loadedThumbnails.addAll(repairedThumbnails);
      }

      // Update state with loaded images
      state = state.copyWith(
        images: loadedImages,
        thumbnails: loadedThumbnails,
        imageCount: loadedImages.length,
        arraysInSync: loadedImages.length == loadedThumbnails.length,
        isLoading: false,
        // Clear any invalid selections
        selectedIndexes: _validateSelectedIndexes(state.selectedIndexes, loadedImages.length),
      );

    } catch (e) {
      debugPrint('Error loading images: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Validates and cleans up selected indexes to ensure they're within bounds
  Set<int> _validateSelectedIndexes(Set<int> currentSelection, int maxCount) {
    if (currentSelection.isEmpty || maxCount == 0) return {};

    final maxIndex = maxCount - 1;
    final validIndexes = currentSelection.where((index) => index >= 0 && index <= maxIndex).toSet();

    if (validIndexes.length != currentSelection.length) {
      debugPrint('Removed invalid selected indexes');
    }

    return validIndexes;
  }

  /// Save the current list of image file paths.
  /// Migrated from grid_home.dart _saveImageOrder method
  Future<void> _saveImageOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paths = state.images.map((f) => f.path).toList();
      await prefs.setStringList('grid_image_paths', paths);
    } catch (e) {
      debugPrint('Error saving image order: $e');
    }
  }

  /// Pick, copy to app storage, compress, create thumbnails, and add to grid.
  /// Migrated from grid_home.dart _addPhoto method
  Future<void> addPhotos() async {
    if (state.isLoading) return;

    final ImagePicker picker = ImagePicker();
    List<XFile> picks = [];

    try {
      picks = await picker.pickMultiImage();
      if (picks.isEmpty) return;
    } catch (e) {
      debugPrint('Error picking images: $e');
      return;
    }

    state = state.copyWith(isLoading: true);

    int successCount = 0;
    int failureCount = 0;
    final List<File> newImages = [];
    final List<File> newThumbnails = [];

    try {
      // Process all images first, then update state once
      for (int i = 0; i < picks.length; i++) {
        final xfile = picks[i];
        try {
          debugPrint('Processing image ${i + 1}/${picks.length}: ${xfile.path}');

          final result = await FileUtils.processImageWithThumbnail(xfile);
          final compressed = result['image']!;
          final thumbnail = result['thumbnail']!;

          // Verify files were created successfully
          if (!await compressed.exists()) {
            throw Exception('Compressed image was not created');
          }
          if (!await thumbnail.exists()) {
            throw Exception('Thumbnail was not created');
          }

          // Verify files are valid
          if (!await FileUtils.verifyImageFile(compressed)) {
            throw Exception('Compressed image is corrupted');
          }
          if (!await FileUtils.verifyImageFile(thumbnail)) {
            throw Exception('Thumbnail is corrupted');
          }

          newImages.add(compressed);
          newThumbnails.add(thumbnail);
          successCount++;

          debugPrint('Successfully processed: ${compressed.path}');

          // Add small delay between operations to prevent file system overload
          if (i < picks.length - 1) {
            await Future.delayed(const Duration(milliseconds: 50));
          }

          // Try to delete original file
          try {
            await File(xfile.path).delete();
          } catch (e) {
            debugPrint('Failed to delete original file ${xfile.path}: $e');
          }
        } catch (e) {
          debugPrint('Error processing ${xfile.path}: $e');
          failureCount++;
        }
      }

      // Update state with all new images at once
      if (newImages.isNotEmpty) {
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
      } else {
        state = state.copyWith(isLoading: false);
      }

      // Log results
      if (failureCount > 0) {
        debugPrint('Added $successCount images. $failureCount failed.');
      }

    } catch (e) {
      debugPrint('Error in addPhotos: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Handle image tap for selection/deselection
  /// Migrated from grid_home.dart _handleTap method
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
    state = state.copyWith(selectedIndexes: {});
  }

  /// Handle double tap to show image preview
  /// Migrated from grid_home.dart _handleDoubleTap method
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

  /// Handle image reordering
  /// Migrated from grid_home.dart _handleReorder method
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
      selectedIndexes: {}, // Clear selection during reorder
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

  /// Confirm delete operation
  /// Migrated from grid_home.dart _onDeleteConfirm method
  Future<void> confirmDelete() async {
    state = state.copyWith(showDeleteConfirm: false);

    try {
      final sorted = state.selectedIndexes.toList()..sort((a, b) => b.compareTo(a));

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
        } else {
          debugPrint('Warning: Invalid index $i for deletion');
        }
      }

      // Update state
      state = state.copyWith(
        images: newImages,
        thumbnails: newThumbnails,
        selectedIndexes: {},
        imageCount: newImages.length,
        arraysInSync: newImages.length == newThumbnails.length,
      );

      // Ensure arrays are still in sync after deletion
      if (state.thumbnails.length != state.images.length) {
        debugPrint('Arrays out of sync after deletion, resyncing...');
        final syncedThumbnails = List<File>.from(state.thumbnails);
        while (syncedThumbnails.length > state.images.length) {
          syncedThumbnails.removeLast();
        }
        while (syncedThumbnails.length < state.images.length) {
          syncedThumbnails.add(state.images[syncedThumbnails.length]);
        }
        state = state.copyWith(thumbnails: syncedThumbnails, arraysInSync: true);
      }

      if (imagesToDelete.isNotEmpty) {
        _deleteFilesInBackground([...imagesToDelete, ...thumbnailsToDelete]);
        await _saveImageOrder();
        await FileUtils.cleanupOrphanedThumbnails(state.images.map((f) => f.path).toList());
      }
    } catch (e) {
      debugPrint('Error in confirmDelete: $e');
    }
  }

  /// Delete files in background without blocking UI
  Future<void> _deleteFilesInBackground(List<File> files) async {
    try {
      final deletedCount = await FileUtils.deleteFilesSafely(files);
      debugPrint('Deleted $deletedCount of ${files.length} files');
    } catch (e) {
      debugPrint('Error in background file deletion: $e');
    }
  }

  /// Share selected image (only works with single selection)
  /// Migrated from grid_home.dart _shareSelectedImage method
  Future<void> shareSelectedImage() async {
    if (!state.hasSingleSelection) return;

    try {
      final imageIndex = state.firstSelectedIndex;
      if (imageIndex >= state.images.length) {
        throw Exception('Invalid image index');
      }

      final imageFile = state.images[imageIndex];

      // Verify file exists before sharing
      if (!await imageFile.exists()) {
        throw Exception('Image file no longer exists');
      }

      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: 'Shared from Grid',
      );

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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('header_username', username);
      state = state.copyWith(
        headerUsername: username,
        editingHeaderUsername: false,
      );
    } catch (e) {
      debugPrint('Error saving header username: $e');
      state = state.copyWith(editingHeaderUsername: false);
    }
  }

  /// Cancel header username editing
  void cancelHeaderUsernameEditing() {
    state = state.copyWith(editingHeaderUsername: false);
  }

  /// Load header username from storage
  Future<void> loadHeaderUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('header_username');
      if (savedUsername != null) {
        state = state.copyWith(headerUsername: savedUsername);
      }
    } catch (e) {
      debugPrint('Error loading header username: $e');
    }
  }

  /// Force refresh/reload of all images
  Future<void> refreshImages() async {
    await _loadSavedImages();
  }
}