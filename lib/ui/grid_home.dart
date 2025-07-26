import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Load saved file paths, rebuild File objects, ignore missing files
  Future<void> _loadSavedImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? paths = prefs.getStringList('grid_image_paths');
      if (paths != null) {
        final valid = paths.where((p) => File(p).existsSync()).toList();
        setState(() {
          _images.clear();
          _images.addAll(valid.map((p) => File(p)));
        });
      }
    } catch (e) {
      debugPrint('Error loading saved images: $e');
    }
  }

  // Persist current order of file paths
  Future<void> _saveImageOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paths = _images.map((f) => f.path).toList();
      await prefs.setStringList('grid_image_paths', paths);
    } catch (e) {
      debugPrint('Error saving image order: $e');
    }
  }

  Future<void> _addPhoto() async {
    final pickedList = await _picker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      setState(() {
        _images.insertAll(0, pickedList.map((x) => File(x.path)));
      });
      await _saveImageOrder();
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

  void _handleLongPress(int index) {
    // This is now handled by the ReorderableBuilder
    // Long press initiates drag & drop
  }

  void _handleReorder(int oldIndex, int newIndex) async {
    setState(() {
      // Clear selections during reorder to avoid confusion
      _selectedIndexes.clear();

      // Adjust newIndex if necessary
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      // Reorder the images list
      final File item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
    await _saveImageOrder();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete photos?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              setState(() {
                // Sort selected indexes in descending order to avoid index shifting issues
                final sortedIndexes = _selectedIndexes.toList()..sort((a, b) => b.compareTo(a));

                for (final index in sortedIndexes) {
                  _images.removeAt(index);
                }

                _selectedIndexes.clear();
              });
              await _saveImageOrder();
              navigator.pop();
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

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24), // top margin for username
                  const ProfileBlock(),
                  PhotoGrid(
                    images: _images,
                    selectedIndexes: _selectedIndexes,
                    onLongPress: _handleLongPress,
                    onTap: _handleTap,
                    onReorder: _handleReorder,
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
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
        ),
        if (hasSelection)
          Positioned(
            bottom: 64, // adjusted to match bottom-left position above bottom bar
            left: 16,
            child: GestureDetector(
              onTap: _confirmDelete,
              child: SvgPicture.asset(
                'assets/delete_button.svg',
                width: 48,
              ),
            ),
          ),
      ],
    );
  }
}