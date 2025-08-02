// File: lib/ui/grid_home.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../file_utils.dart';
import 'profile_block.dart';
import 'photo_sliver_grid.dart';
import 'menu_screen.dart';
import '../app_theme.dart';

/// Premium scroll physics with controlled spring parameters for Instagram-like feel
class SmoothEasingScrollPhysics extends BouncingScrollPhysics {
  const SmoothEasingScrollPhysics({super.parent});

  @override
  SmoothEasingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothEasingScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
    mass: 0.6,       // Slightly heavier for stability
    stiffness: 120.0, // Reduced stiffness for gentler bounce
    ratio: 1.2,      // More damping for softer bounce
  );
}

class GridHomePage extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const GridHomePage({super.key, required this.themeNotifier});

  @override
  State<GridHomePage> createState() => _GridHomePageState();
}

class _GridHomePageState extends State<GridHomePage>
    with AutomaticKeepAliveClientMixin {
  final List<File> _images = [];
  final List<File> _thumbnails = [];
  final Set<int> _selectedIndexes = {};
  final ImagePicker _picker = ImagePicker();
  bool _showDeleteConfirm = false;
  bool _isLoading = false;

  // Full-screen image preview state
  bool _showImagePreview = false;
  int _previewImageIndex = -1;

  // ScrollController to manage scrolling and detect position
  final ScrollController _scrollController = ScrollController();
  // State to track if the scroll position is at the top
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
    // Listen to scroll events
    _scrollController.addListener(_onScroll);
    // Setup header username focus listener
    _headerUsernameFocus.addListener(() {
      if (!_headerUsernameFocus.hasFocus && _editingHeaderUsername) {
        _saveHeaderUsername();
        setState(() => _editingHeaderUsername = false);
      }
    });
  }

  @override
  void dispose() {
    // Dispose the scroll controller to prevent memory leaks
    _scrollController.dispose();
    _headerUsernameController.dispose();
    _headerUsernameFocus.dispose();
    super.dispose();
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

  /// Method to handle scroll events and update _isAtTop state.
  void _onScroll() {
    // Update _isAtTop based on scroll offset. A small buffer (100) is used
    // to account for slight bounces or overscrolling.
    if (_scrollController.offset <= 100 && !_isAtTop) {
      setState(() {
        _isAtTop = true;
      });
    } else if (_scrollController.offset > 100 && _isAtTop) {
      setState(() {
        _isAtTop = false;
      });
    }
  }

  /// Method to scroll the CustomScrollView back to the top.
  void _scrollToTop() {
    _scrollController.animateTo(
      0.0, // Scroll to the top
      duration: const Duration(milliseconds: 300), // Animation duration
      curve: Curves.easeOut, // Animation curve for smooth deceleration
    );
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
      final List<File> loadedImages = [];
      final List<File> loadedThumbnails = [];

      // Process images in batches to avoid blocking UI
      const batchSize = 10;
      for (int i = 0; i < stored.length; i += batchSize) {
        final batch = stored.skip(i).take(batchSize);

        for (final path in batch) {
          final file = File(path);
          if (!file.existsSync()) continue;

          String finalPath = path;
          if (!path.startsWith(appDir.path)) {
            try {
              // Migrate old external files using new thumbnail system
              final result = await FileUtils.processImageWithThumbnail(XFile(path));
              finalPath = result['image']!.path;
            } catch (e) {
              debugPrint('Migration failed for $path: $e');
              finalPath = path;
            }
          }

          migrated.add(finalPath);
          loadedImages.add(File(finalPath));

          // Try to load corresponding thumbnail
          final thumbnail = await FileUtils.getThumbnailForImage(finalPath);
          if (thumbnail != null) {
            loadedThumbnails.add(thumbnail);
          } else {
            // Create thumbnail if missing (for old images)
            try {
              final newThumbnail = await FileUtils.generateThumbnail(XFile(finalPath));
              loadedThumbnails.add(newThumbnail);
            } catch (e) {
              debugPrint('Failed to generate thumbnail for $finalPath: $e');
              // Use the full image as fallback
              loadedThumbnails.add(File(finalPath));
            }
          }
        }

        // Update UI after each batch
        if (mounted) {
          setState(() {
            _images
              ..clear()
              ..addAll(loadedImages);
            _thumbnails
              ..clear()
              ..addAll(loadedThumbnails);
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

  /// Pick, copy to app storage, compress, create thumbnails, and add to grid.
  Future<void> _addPhoto() async {
    if (_isLoading) return;

    final picks = await _picker.pickMultiImage();
    if (picks.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Process images one by one to avoid memory spikes
      for (final xfile in picks) {
        try {
          // Use the new thumbnail system for better performance
          final result = await FileUtils.processImageWithThumbnail(xfile);
          final compressed = result['image']!;
          final thumbnail = result['thumbnail']!;

          if (mounted) {
            setState(() {
              _images.insert(0, compressed);
              _thumbnails.insert(0, thumbnail);
            });
          }
          // Small delay to prevent UI blocking
          await Future.delayed(const Duration(milliseconds: 10));
          await File(xfile.path).delete();
        } catch (e) {
          debugPrint('Error processing ${xfile.path}: $e');
        }
      }

      await _saveImageOrder();
    } finally {
      if (mounted) {
        setState(() => _isLoading = true);
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

  void _handleDoubleTap(int index) {
    setState(() {
      _previewImageIndex = index;
      _showImagePreview = true;
    });
  }

  void _closeImagePreview() {
    setState(() {
      _showImagePreview = false;
      _previewImageIndex = -1;
    });
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    setState(() {
      _selectedIndexes.clear();
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

    final sorted = _selectedIndexes.toList()..sort((a, b) => b.compareTo(a));

    // Delete both image and thumbnail files in background to avoid blocking UI
    final imagesToDelete = <File>[];
    final thumbnailsToDelete = <File>[];

    for (final i in sorted) {
      imagesToDelete.add(_images[i]);
      thumbnailsToDelete.add(_thumbnails[i]);
      _images.removeAt(i);
      _thumbnails.removeAt(i);
    }

    _selectedIndexes.clear();
    setState(() {});

    // Delete files asynchronously
    _deleteFilesInBackground([...imagesToDelete, ...thumbnailsToDelete]);
    await _saveImageOrder();
    await FileUtils.cleanupOrphanedThumbnails(_images.map((f) => f.path).toList());
  }

  Future<void> _deleteFilesInBackground(List<File> files) async {
    for (final file in files) {
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Error deleting file ${file.path}: $e');
      }
      await Future.delayed(const Duration(milliseconds: 1));
    }
  }

  // Share single selected image
  Future<void> _shareSelectedImage() async {
    if (_selectedIndexes.length != 1) return; // Only works with exactly 1 image

    try {
      final imageIndex = _selectedIndexes.first;
      final imageFile = _images[imageIndex];

      // Share the high-quality image using system share dialog
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: 'Shared from Grid',
      );

    } catch (e) {
      debugPrint('Error sharing image: $e');
      // Show error message to user
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

  // Navigate to menu screen
  void _onMenuPressed() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MenuScreen(themeNotifier: widget.themeNotifier),
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Use a fade transition instead of the default slide
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
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
    final hasSelection = _selectedIndexes.isNotEmpty;

    return AnimatedBuilder(
      animation: widget.themeNotifier,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Unfocus header username if editing
            if (_editingHeaderUsername) _headerUsernameFocus.unfocus();
          },
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.scaffoldBackground(isDark),
                bottomNavigationBar: Container(
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
                      mainAxisAlignment: _selectedIndexes.length == 1
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
                            if (_selectedIndexes.length >= 2) ...[
                              const SizedBox(width: 16),
                              Text(
                                '${_selectedIndexes.length}',
                                style: AppTheme.bodyMedium(isDark).copyWith(
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_selectedIndexes.length == 1)
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
                ),
                body: CustomScrollView(
                  controller: _scrollController,
                  physics: const SmoothEasingScrollPhysics(),
                  cacheExtent: 1000,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24), // Add 24px margin
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
                      PhotoSliverGrid(
                        images: _images,
                        thumbnails: _thumbnails,
                        selectedIndexes: _selectedIndexes,
                        onTap: _handleTap,
                        onDoubleTap: _handleDoubleTap,
                        onLongPress: (_) {},
                        onReorder: _handleReorder,
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 90)),
                  ],
                ),
              ),

              // Custom modal overlay with animation
              AnimatedOpacity(
                opacity: _showDeleteConfirm ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _showDeleteConfirm
                    ? DeleteConfirmModal(
                  onCancel: _onDeleteCancel,
                  onDelete: _onDeleteConfirm,
                  isDark: isDark,
                )
                    : const SizedBox.shrink(),
              ),

              // Full-screen image preview
              if (_showImagePreview && _previewImageIndex >= 0)
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

// Full-screen image preview modal with blurred background
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

// Delete confirm modal
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
                                AppColors.deleteButtonBackground),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            overlayColor: WidgetStateProperty.all(
                              AppColors.deleteButtonOverlay,
                            ),
                          ),
                          onPressed: onDelete,
                          child: const Text(
                            'Delete',
                            style: AppTheme.dialogActionDanger,
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