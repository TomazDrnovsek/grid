import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../file_utils.dart';
import 'profile_block.dart';
import 'photo_grid.dart';

class GridHomePage extends StatefulWidget {
  const GridHomePage({super.key});

  @override
  State<GridHomePage> createState() => _GridHomePageState();
}

class _GridHomePageState extends State<GridHomePage> {
  final List<File> _images = [];
  final Set<int> _selectedIndexes = {};
  final ImagePicker _picker = ImagePicker();

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
        // ▶️ Off the UI isolate; compression runs in background
        final compressed = await FileUtils.copyAndCompress(xfile);
        setState(() => _images.insert(0, compressed));
      } catch (e) {
        debugPrint('Error compressing ${xfile.path}: $e');
        // Optionally: fall back to raw File(xfile.path)
        // setState(() => _images.insert(0, File(xfile.path)));
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

  /// Confirm deletion, remove from both grid and disk.
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete photos?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final sorted = _selectedIndexes.toList()
                ..sort((a, b) => b.compareTo(a));
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
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedIndexes.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SizedBox(
        height: 48,
        child: BottomAppBar(
          color: Colors.white,
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            // no horizontal padding; grid needs full-width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const ProfileBlock(),
                PhotoGrid(
                  images: _images,
                  selectedIndexes: _selectedIndexes,
                  onTap: _handleTap,
                  onReorder: _handleReorder,
                  onLongPress: (_) {},
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
      // Move delete button outside of body Stack to fix positioning
      floatingActionButton: hasSelection
          ? GestureDetector(
        onTap: _confirmDelete,
        child: SvgPicture.asset(
          'assets/delete_button.svg',
          width: 48,
          height: 48, // Good practice to explicitly define height
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}