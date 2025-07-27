import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../file_utils.dart';
import 'profile_block.dart';
import 'photo_grid.dart';
import '../app_theme.dart';

class GridHomePage extends StatefulWidget {
  const GridHomePage({super.key});

  @override
  State<GridHomePage> createState() => _GridHomePageState();
}

class _GridHomePageState extends State<GridHomePage> {
  final List<File> _images = [];
  final Set<int> _selectedIndexes = {};
  final ImagePicker _picker = ImagePicker();

  // ADDED: Modal visibility state for custom delete confirm
  bool _showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  /// Load saved paths, migrate external files into app storage if needed.
  Future<void> _loadSavedImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList('grid_image_paths');
      if (stored == null) return;

      final appDir = await FileUtils.getAppImagesDir();
      final List<String> migrated = [];

      for (final path in stored) {
        final file = File(path);
        if (!file.existsSync()) continue;

        if (path.startsWith(appDir.path)) {
          // Already in app storage
          migrated.add(path);
        } else {
          // Migrate external image into our storage
          try {
            final compressed = await FileUtils.copyAndCompress(XFile(path));
            migrated.add(compressed.path);
          } catch (e) {
            // on failure, keep original so UI still works
            debugPrint('Migration failed for $path: $e');
            migrated.add(path);
          }
        }
      }

      // Persist any new paths
      await prefs.setStringList('grid_image_paths', migrated);

      setState(() {
        _images
          ..clear()
          ..addAll(migrated.map((p) => File(p)));
      });
    } catch (e) {
      debugPrint('Error loading/migrating images: $e');
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
    final picks = await _picker.pickMultiImage();
    if (picks.isEmpty) return;

    for (final xfile in picks) {
      try {
        final compressed = await FileUtils.copyAndCompress(xfile);
        setState(() => _images.insert(0, compressed));
      } catch (e) {
        debugPrint('Error compressing ${xfile.path}: $e');
      }
    }
    await _saveImageOrder();
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

  /// Show custom modal confirm, remove from both grid and disk on confirm.
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
    for (final i in sorted) {
      final file = _images.removeAt(i);
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Error deleting file ${file.path}: $e');
      }
    }
    _selectedIndexes.clear();
    setState(() {});
    await _saveImageOrder();
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Color(0xFFF7F7F7), // Light gray color
                  width: 1.0,
                ),
              ),
            ),
            child: Center(
              child: GestureDetector(
                onTap: _addPhoto,
                child: SvgPicture.asset(
                  'assets/add_button.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              // ProfileBlock as a sliver
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 40),
                    ProfileBlock(),
                  ],
                ),
              ),
              // Photo grid as a sliver
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
          // Delete button shows modal instead of system dialog
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

// --- ADDED: Custom Delete Confirm Modal ---

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
        // Dark overlay with tap-to-dismiss
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              color: AppColors.overlay80,
            ),
          ),
        ),
        // Centered modal
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
                  Text(
                    'Are you sure?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
                      // Cancel button
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
                      // Delete button
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