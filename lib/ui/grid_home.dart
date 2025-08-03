// File: lib/ui/grid_home.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../file_utils.dart';
import '../core/app_config.dart';
import 'profile_block.dart';
import 'photo_sliver_grid.dart';
import 'menu_screen.dart';
import '../app_theme.dart';

/// High refresh rate optimized scroll physics that adapts to device capabilities
/// Provides buttery smooth scrolling on 120Hz+ displays while maintaining
/// excellent performance on standard 60Hz screens
class HighRefreshScrollPhysics extends BouncingScrollPhysics {
  const HighRefreshScrollPhysics({super.parent});

  @override
  HighRefreshScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return HighRefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring {
    // Use cached performance configuration
    return AppConfig().optimizedSpringDescription;
  }

  @override
  double get minFlingVelocity {
    // Use cached configuration
    return AppConfig().minFlingVelocity;
  }

  @override
  double get maxFlingVelocity {
    // Use cached configuration
    return AppConfig().maxFlingVelocity;
  }
}

class GridHomePage extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const GridHomePage({super.key, required this.themeNotifier});

  @override
  State<GridHomePage> createState() => _GridHomePageState();
}

class _GridHomePageState extends State<GridHomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final List<File> _images = [];
  final List<File> _thumbnails = [];

  // OPTIMIZED: Use ValueNotifier for selection state to avoid full rebuilds
  final ValueNotifier<Set<int>> _selectedIndexesNotifier = ValueNotifier<Set<int>>({});

  final ImagePicker _picker = ImagePicker();
  bool _showDeleteConfirm = false;
  bool _isLoading = false;

  // Full-screen image preview state
  bool _showImagePreview = false;
  int _previewImageIndex = -1;

  // ScrollController optimized for high refresh rate
  final ScrollController _scrollController = ScrollController();
  bool _isAtTop = true;

  // Header username editing
  bool _editingHeaderUsername = false;
  String _headerUsername = 'tomazdrnovsek';
  final TextEditingController _headerUsernameController = TextEditingController();
  final FocusNode _headerUsernameFocus = FocusNode();

  // Keep the state alive to prevent rebuilds
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
    _loadHeaderUsername();
    _setupScrollOptimizations();
    _setupHeaderUsernameListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerUsernameController.dispose();
    _headerUsernameFocus.dispose();
    _selectedIndexesNotifier.dispose(); // Dispose ValueNotifier
    super.dispose();
  }

  /// Setup scroll optimizations for high refresh rate displays
  void _setupScrollOptimizations() {
    _scrollController.addListener(() {
      // Optimize scroll position updates for high refresh rate
      final offset = _scrollController.offset;

      // Use cached scroll buffer setting
      final buffer = AppConfig().scrollBuffer;

      if (offset <= buffer && !_isAtTop) {
        setState(() => _isAtTop = true);
      } else if (offset > buffer && _isAtTop) {
        setState(() => _isAtTop = false);
      }
    });
  }

  void _setupHeaderUsernameListener() {
    _headerUsernameFocus.addListener(() {
      if (!_headerUsernameFocus.hasFocus && _editingHeaderUsername) {
        _saveHeaderUsername();
        setState(() => _editingHeaderUsername = false);
      }
    });
  }

  /// Load saved header username from SharedPreferences
  Future<void> _loadHeaderUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('header_username');
      if (savedUsername != null) {
        setState(() {
          _headerUsername = savedUsername;
        });
      }
    } catch (e) {
      debugPrint('Error loading header username: $e');
    }
  }

  /// Save header username to SharedPreferences
  Future<void> _saveHeaderUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('header_username', _headerUsernameController.text);
      setState(() {
        _headerUsername = _headerUsernameController.text;
      });
    } catch (e) {
      debugPrint('Error saving header username: $e');
    }
  }

  /// Start editing header username
  void _startEditingHeaderUsername() {
    setState(() {
      _editingHeaderUsername = true;
      _headerUsernameController.text = _headerUsername;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerUsernameFocus.requestFocus();
    });
  }

  /// Validates and cleans up selected indexes to ensure they're within bounds
  void _validateSelectedIndexes() {
    final currentSelection = _selectedIndexesNotifier.value;
    if (currentSelection.isEmpty) return;

    final maxIndex = _images.length - 1;
    final invalidIndexes = currentSelection.where((index) => index < 0 || index > maxIndex).toList();

    if (invalidIndexes.isNotEmpty) {
      debugPrint('Removing invalid selected indexes: $invalidIndexes');
      // OPTIMIZED: Update selection through ValueNotifier
      final newSelection = Set<int>.from(currentSelection);
      newSelection.removeAll(invalidIndexes);
      _selectedIndexesNotifier.value = newSelection;
    }
  }

  /// Optimized scroll to top for high refresh rate displays
  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: AppConfig().fastAnimationDuration,
      curve: Curves.easeOutCubic, // Smooth curve optimized for high refresh rate
    );
  }

  /// Load saved paths, migrate external files into app storage if needed.
  Future<void> _loadSavedImages() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList('grid_image_paths');
      if (stored == null || stored.isEmpty) {
        return;
      }

      final appDir = await FileUtils.getAppImagesDir();
      final List<String> validPaths = [];

      // Clear existing arrays
      _images.clear();
      _thumbnails.clear();

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
          _images.add(imageFile);
          _thumbnails.add(thumbnailFile);
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
        _thumbnails.clear();
        for (final imagePath in validPaths) {
          final thumbnail = await FileUtils.getThumbnailForImage(imagePath);
          _thumbnails.add(thumbnail ?? File(imagePath));
        }
      }

      // Final validation
      _validateSelectedIndexes();

    } catch (e) {
      debugPrint('Error loading images: $e');
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

  /// Pick, copy to app storage, compress, create thumbnails, and add to grid.
  Future<void> _addPhoto() async {
    if (_isLoading) return;

    List<XFile> picks = [];
    try {
      picks = await _picker.pickMultiImage();
      if (picks.isEmpty) return;
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick images'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    int successCount = 0;
    int failureCount = 0;
    final List<File> newImages = [];
    final List<File> newThumbnails = [];

    try {
      // Process all images first, then update UI once
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

      // Update UI with all new images at once
      if (newImages.isNotEmpty && mounted) {
        // First, add the images to the lists
        setState(() {
          // Insert all new images at the beginning
          _images.insertAll(0, newImages.reversed);
          _thumbnails.insertAll(0, newThumbnails.reversed);
        });

        // Save the new image order
        await _saveImageOrder();

        // Force a complete widget tree rebuild for large batches
        if (newImages.length > 10) {
          debugPrint('Large batch detected, forcing complete UI refresh...');

          // Small delay to ensure setState completes
          await Future.delayed(const Duration(milliseconds: 100));

          // Force the grid to rebuild by temporarily clearing and restoring
          if (mounted) {
            final tempImages = List<File>.from(_images);
            final tempThumbnails = List<File>.from(_thumbnails);

            setState(() {
              _images.clear();
              _thumbnails.clear();
            });

            // Wait for the clear to process
            await Future.delayed(const Duration(milliseconds: 50));

            if (mounted) {
              setState(() {
                _images.addAll(tempImages);
                _thumbnails.addAll(tempThumbnails);
              });
            }
          }
        }
      }

      // Show feedback if some images failed
      if (mounted && failureCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successCount > 0
                  ? 'Added $successCount images. $failureCount failed.'
                  : 'Failed to add images',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in _addPhoto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while adding photos'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // Always reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleTap(int index) {
    if (index < 0 || index >= _images.length) {
      debugPrint('Invalid tap index: $index');
      return;
    }

    // OPTIMIZED: Update selection without setState - only selection UI rebuilds
    final currentSelection = Set<int>.from(_selectedIndexesNotifier.value);
    if (currentSelection.contains(index)) {
      currentSelection.remove(index);
    } else {
      currentSelection.add(index);
    }
    _selectedIndexesNotifier.value = currentSelection;
  }

  void _handleDoubleTap(int index) {
    if (index >= 0 && index < _images.length) {
      setState(() {
        _previewImageIndex = index;
        _showImagePreview = true;
      });
    }
  }

  void _closeImagePreview() {
    setState(() {
      _showImagePreview = false;
      _previewImageIndex = -1;
    });
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    // Validate indices
    if (oldIndex < 0 || oldIndex >= _images.length ||
        newIndex < 0 || newIndex >= _images.length ||
        oldIndex == newIndex) {
      debugPrint('Invalid reorder indices: old=$oldIndex, new=$newIndex');
      return;
    }

    // Also check thumbnails array
    if (oldIndex >= _thumbnails.length || newIndex >= _thumbnails.length) {
      debugPrint('Thumbnail array out of sync with images array');
      return;
    }

    // OPTIMIZED: Clear selection without setState, then reorder
    _selectedIndexesNotifier.value = <int>{};

    setState(() {
      final item = _images.removeAt(oldIndex);
      final thumbnail = _thumbnails.removeAt(oldIndex);
      _images.insert(newIndex, item);
      _thumbnails.insert(newIndex, thumbnail);
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

    try {
      // FIXED: Use cascade operator to avoid void assignment error
      final sorted = _selectedIndexesNotifier.value.toList()..sort((a, b) => b.compareTo(a));

      final imagesToDelete = <File>[];
      final thumbnailsToDelete = <File>[];

      for (final i in sorted) {
        if (i >= 0 && i < _images.length && i < _thumbnails.length) {
          imagesToDelete.add(_images[i]);
          thumbnailsToDelete.add(_thumbnails[i]);
          _images.removeAt(i);
          _thumbnails.removeAt(i);
        } else {
          debugPrint('Warning: Invalid index $i for deletion');
        }
      }

      // OPTIMIZED: Clear selection without setState
      _selectedIndexesNotifier.value = <int>{};
      setState(() {}); // Only rebuild for image list changes

      // Ensure arrays are still in sync after deletion
      if (_thumbnails.length != _images.length) {
        debugPrint('Arrays out of sync after deletion, resyncing...');
        while (_thumbnails.length > _images.length) {
          _thumbnails.removeLast();
        }
        while (_thumbnails.length < _images.length) {
          _thumbnails.add(_images[_thumbnails.length]);
        }
      }

      if (imagesToDelete.isNotEmpty) {
        _deleteFilesInBackground([...imagesToDelete, ...thumbnailsToDelete]);
        await _saveImageOrder();
        await FileUtils.cleanupOrphanedThumbnails(_images.map((f) => f.path).toList());
      }
    } catch (e) {
      debugPrint('Error in _onDeleteConfirm: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while deleting images'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteFilesInBackground(List<File> files) async {
    try {
      final deletedCount = await FileUtils.deleteFilesSafely(files);
      debugPrint('Deleted $deletedCount of ${files.length} files');

      // Use cached batch delay setting
      final delay = AppConfig().batchDelay;
      if (delay.inMilliseconds > 0) {
        await Future.delayed(delay);
      }
    } catch (e) {
      debugPrint('Error in background file deletion: $e');
    }
  }

  Future<void> _shareSelectedImage() async {
    final selectedIndexes = _selectedIndexesNotifier.value;
    if (selectedIndexes.length != 1) return;

    try {
      final imageIndex = selectedIndexes.first;
      if (imageIndex >= _images.length) {
        throw Exception('Invalid image index');
      }

      final imageFile = _images[imageIndex];

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share image'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onMenuPressed() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MenuScreen(themeNotifier: widget.themeNotifier),
        transitionDuration: AppConfig().animationDuration,
        reverseTransitionDuration: AppConfig().animationDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic, // Smooth curve optimized for high refresh rate
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: widget.themeNotifier,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_editingHeaderUsername) _headerUsernameFocus.unfocus();
          },
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.scaffoldBackground(isDark),
                // OPTIMIZED: Use ValueListenableBuilder for bottom bar to avoid full rebuilds
                bottomNavigationBar: ValueListenableBuilder<Set<int>>(
                  valueListenable: _selectedIndexesNotifier,
                  builder: (context, selectedIndexes, child) {
                    final hasSelection = selectedIndexes.isNotEmpty;

                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.bottomBarBackground(isDark),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.sheetDivider(isDark),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: hasSelection
                            ? Row(
                          mainAxisAlignment: selectedIndexes.length == 1
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _showDeleteModal,
                                  child: SvgPicture.asset(
                                    'assets/delete_icon.svg',
                                    width: 24,
                                    height: 24,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.textPrimary(isDark),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                if (selectedIndexes.length >= 2) ...[
                                  const SizedBox(width: 16),
                                  Text(
                                    '${selectedIndexes.length}',
                                    style: AppTheme.bodyMedium(isDark).copyWith(
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (selectedIndexes.length == 1)
                              GestureDetector(
                                onTap: _shareSelectedImage,
                                child: SvgPicture.asset(
                                  'assets/share_icon.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.textPrimary(isDark),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _scrollToTop,
                              child: SvgPicture.asset(
                                _isAtTop ? 'assets/home_icon-fill.svg' : 'assets/home_icon-outline.svg',
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  AppColors.textPrimary(isDark),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                body: CustomScrollView(
                  controller: _scrollController,
                  physics: const HighRefreshScrollPhysics(), // Use our optimized physics
                  cacheExtent: AppConfig().optimalCacheExtent, // Use cached optimal cache extent
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: _editingHeaderUsername
                                    ? TextField(
                                  controller: _headerUsernameController,
                                  focusNode: _headerUsernameFocus,
                                  style: AppTheme.headlineSm(isDark),
                                  maxLines: 1,
                                  maxLength: 20,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                )
                                    : GestureDetector(
                                  onTap: _startEditingHeaderUsername,
                                  child: Text(
                                    _headerUsername,
                                    style: AppTheme.headlineSm(isDark),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: _isLoading ? null : _addPhoto,
                                  child: Opacity(
                                    opacity: _isLoading ? 0.5 : 1.0,
                                    child: SvgPicture.asset(
                                      'assets/add_button.svg',
                                      width: 24,
                                      height: 24,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.textPrimary(isDark),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: _onMenuPressed,
                                  child: SvgPicture.asset(
                                    'assets/menu_icon.svg',
                                    width: 24,
                                    height: 24,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.textPrimary(isDark),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: ProfileBlock(),
                    ),
                    if (_isLoading && _images.isEmpty)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    if (_images.isNotEmpty)
                    // OPTIMIZED: Use ValueListenableBuilder for grid selection state
                      ValueListenableBuilder<Set<int>>(
                        valueListenable: _selectedIndexesNotifier,
                        builder: (context, selectedIndexes, child) {
                          return PhotoSliverGrid(
                            images: _images,
                            thumbnails: _thumbnails.length == _images.length
                                ? _thumbnails
                                : List<File>.from(_images), // Fallback if thumbnails out of sync
                            selectedIndexes: selectedIndexes,
                            onTap: _handleTap,
                            onDoubleTap: _handleDoubleTap,
                            onLongPress: (_) {},
                            onReorder: _handleReorder,
                          );
                        },
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 90)),
                  ],
                ),
              ),

              // Modal overlays with optimized animations
              AnimatedOpacity(
                opacity: _showDeleteConfirm ? 1.0 : 0.0,
                duration: AppConfig().fastAnimationDuration, // Use cached fast animation duration
                curve: Curves.easeInOutCubic,
                child: _showDeleteConfirm
                    ? DeleteConfirmModal(
                  onCancel: _onDeleteCancel,
                  onDelete: _onDeleteConfirm,
                  isDark: isDark,
                )
                    : const SizedBox.shrink(),
              ),

              if (_showImagePreview && _previewImageIndex >= 0 && _previewImageIndex < _images.length)
                ImagePreviewModal(
                  image: _images[_previewImageIndex],
                  onClose: _closeImagePreview,
                ),
            ],
          ),
        );
      },
    );
  }
}

// Optimized image preview modal
class ImagePreviewModal extends StatelessWidget {
  final File image;
  final VoidCallback onClose;

  const ImagePreviewModal({
    super.key,
    required this.image,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.imagePreviewOverlay,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Hero(
              tag: 'image_${image.path}',
              child: Image.file(
                image,
                fit: BoxFit.contain,
                gaplessPlayback: true, // Prevent blinking on high refresh rate
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.imagePreviewErrorIcon,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Unable to load image',
                          style: AppTheme.imagePreviewError,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Optimized delete confirm modal
class DeleteConfirmModal extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final bool isDark;

  const DeleteConfirmModal({
    super.key,
    required this.onCancel,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              color: AppColors.modalOverlayBackground(isDark),
            ),
          ),
        ),
        Center(
          child: Semantics(
            label: 'Delete confirmation dialog',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.modalContentBackground(isDark),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure?',
                    textAlign: TextAlign.center,
                    style: AppTheme.dialogTitle(isDark),
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
                            backgroundColor: WidgetStateProperty.all(
                                AppColors.cancelButtonBackground(isDark)),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            overlayColor: WidgetStateProperty.all(
                              AppColors.textPrimary(isDark).withAlpha(18),
                            ),
                          ),
                          onPressed: onCancel,
                          child: Text(
                            'Cancel',
                            style: AppTheme.dialogActionPrimary(isDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        height: 44,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                AppColors.deleteButtonBackground(isDark)),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            overlayColor: WidgetStateProperty.all(
                              AppColors.deleteButtonOverlay(isDark),
                            ),
                          ),
                          onPressed: onDelete,
                          child: Text(
                            'Delete',
                            style: AppTheme.dialogActionDanger(isDark),
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