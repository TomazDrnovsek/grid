import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../file_utils.dart';
import 'profile_block.dart';
import 'photo_sliver_grid.dart';
import '../app_theme.dart';

class GridHomePage extends StatefulWidget {
  const GridHomePage({super.key});

  @override
  State<GridHomePage> createState() => _GridHomePageState();
}

class _GridHomePageState extends State<GridHomePage>
    with AutomaticKeepAliveClientMixin {
  final List<File> _images = [];
  final Set<int> _selectedIndexes = {};
  final ImagePicker _picker = ImagePicker();
  bool _showDeleteConfirm = false;
  bool _isLoading = false;

  // Keep the state alive to prevent rebuilds
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  /// Load saved paths, migrate external files into app storage if needed.
  Future<void> _loadSavedImages() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList('grid_image_paths');
      if (stored == null) return;

      final appDir = await FileUtils.getAppImagesDir();
      final List<String> migrated = [];

      // Process images in batches to avoid blocking UI
      const batchSize = 10;
      for (int i = 0; i < stored.length; i += batchSize) {
        final batch = stored.skip(i).take(batchSize);

        for (final path in batch) {
          final file = File(path);
          if (!file.existsSync()) continue;

          if (path.startsWith(appDir.path)) {
            migrated.add(path);
          } else {
            try {
              final compressed = await FileUtils.copyAndCompress(XFile(path));
              migrated.add(compressed.path);
            } catch (e) {
              debugPrint('Migration failed for $path: $e');
              migrated.add(path);
            }
          }
        }

        // Update UI after each batch
        if (mounted) {
          setState(() {
            _images
              ..clear()
              ..addAll(migrated.map((p) => File(p)));
          });
        }

        // Allow other operations to run
        await Future.delayed(const Duration(milliseconds: 1));
      }

      await prefs.setStringList('grid_image_paths', migrated);
    } catch (e) {
      debugPrint('Error loading/migrating images: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Save the current list of image file paths.
  Future<void> _saveImageOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paths = _images.map((f) => f.path).toList();
      await prefs.setStringList('grid_image_paths', paths);
    } catch (e) {
      debugPrint('Error saving image order: $e');
    }
  }

  /// Pick, copy to app storage, compress, and add to grid.
  Future<void> _addPhoto() async {
    if (_isLoading) return;

    final picks = await _picker.pickMultiImage();
    if (picks.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Process images one by one to avoid memory spikes
      for (final xfile in picks) {
        try {
          final compressed = await FileUtils.copyAndCompress(xfile);
          if (mounted) {
            setState(() => _images.insert(0, compressed));
          }
          // Small delay to prevent UI blocking
          await Future.delayed(const Duration(milliseconds: 10));
        } catch (e) {
          debugPrint('Error compressing ${xfile.path}: $e');
        }
      }

      await _saveImageOrder();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleTap(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    setState(() {
      _selectedIndexes.clear();
      if (oldIndex < newIndex) newIndex -= 1;
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
    await _saveImageOrder();
  }

  void _showDeleteModal() {
    setState(() {
      _showDeleteConfirm = true;
    });
  }

  void _onDeleteCancel() {
    setState(() {
      _showDeleteConfirm = false;
    });
  }

  Future<void> _onDeleteConfirm() async {
    setState(() {
      _showDeleteConfirm = false;
    });

    final sorted = _selectedIndexes.toList()..sort((a, b) => b.compareTo(a));

    // Delete files in background to avoid blocking UI
    final filesToDelete = <File>[];
    for (final i in sorted) {
      filesToDelete.add(_images[i]);
      _images.removeAt(i);
    }

    _selectedIndexes.clear();
    setState(() {});

    // Delete files asynchronously
    _deleteFilesInBackground(filesToDelete);
    await _saveImageOrder();
  }

  Future<void> _deleteFilesInBackground(List<File> files) async {
    for (final file in files) {
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Error deleting file ${file.path}: $e');
      }
      // Small delay to prevent blocking
      await Future.delayed(const Duration(milliseconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final hasSelection = _selectedIndexes.isNotEmpty;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: Container(
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFF7F7F7),
                  width: 1.0,
                ),
              ),
            ),
            child: Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _addPhoto,
                child: Opacity(
                  opacity: _isLoading ? 0.5 : 1.0,
                  child: SvgPicture.asset(
                    'assets/add_button.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ),
          body: CustomScrollView(
            // Add physics for better scrolling performance
            physics: const BouncingScrollPhysics(),
            cacheExtent: 1000, // Cache more items for smoother scrolling
            slivers: [
              // ProfileBlock as a sliver
              const SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    ProfileBlock(),
                  ],
                ),
              ),
              // Loading indicator
              if (_isLoading && _images.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              // Photo grid as a sliver
              if (_images.isNotEmpty)
                PhotoSliverGrid(
                  images: _images,
                  selectedIndexes: _selectedIndexes,
                  onTap: _handleTap,
                  onReorder: _handleReorder,
                  onLongPress: (_) {},
                ),
              // Bottom spacing for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 90),
              ),
            ],
          ),
          floatingActionButton: hasSelection
              ? GestureDetector(
            onTap: _showDeleteModal,
            child: SvgPicture.asset(
              'assets/delete_button.svg',
              width: 48,
              height: 48,
            ),
          )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        ),
        // Custom modal overlay with animation
        AnimatedOpacity(
          opacity: _showDeleteConfirm ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: _showDeleteConfirm
              ? _DeleteConfirmModal(
            onCancel: _onDeleteCancel,
            onDelete: _onDeleteConfirm,
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// Delete confirm modal remains the same
class _DeleteConfirmModal extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _DeleteConfirmModal({
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              color: AppColors.overlay80,
            ),
          ),
        ),
        Center(
          child: Semantics(
            label: 'Delete confirmation dialog',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Are you sure?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.4,
                      decoration: TextDecoration.none,
                      decorationColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 44,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.white),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            overlayColor: WidgetStateProperty.all(
                              AppColors.textPrimary.withAlpha(18),
                            ),
                          ),
                          onPressed: onCancel,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 1.29,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        height: 44,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(AppColors.brandPrimary),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            overlayColor: WidgetStateProperty.all(
                              AppColors.brandPrimary.withAlpha(229),
                            ),
                          ),
                          onPressed: onDelete,
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 1.29,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}