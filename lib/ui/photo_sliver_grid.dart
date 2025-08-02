import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grid/app_theme.dart';

class PhotoSliverGrid extends StatelessWidget {
  final List<File> images;
  final List<File> thumbnails;
  final Set<int> selectedIndexes;
  final void Function(int) onTap;
  final void Function(int) onDoubleTap;
  final void Function(int) onLongPress;
  final void Function(int oldIndex, int newIndex) onReorder;

  const PhotoSliverGrid({
    super.key,
    required this.images,
    required this.thumbnails,
    required this.selectedIndexes,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 3 / 4,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return _PhotoGridItem(
            key: ValueKey('photo_$index'),
            file: images[index],
            thumbnail: thumbnails.length > index ? thumbnails[index] : images[index],
            index: index,
            isSelected: selectedIndexes.contains(index),
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onReorder: onReorder,
          );
        },
        childCount: images.length,
        // Better memory management without sacrificing quality
        addAutomaticKeepAlives: true,   // Keep visible items alive for better UX
        addRepaintBoundaries: true,     // Isolate repaints for better performance
        addSemanticIndexes: false,      // Skip semantic indexing for performance
      ),
    );
  }
}

class _PhotoGridItem extends StatefulWidget {
  final File file;
  final File thumbnail;
  final int index;
  final bool isSelected;
  final void Function(int) onTap;
  final void Function(int) onDoubleTap;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _PhotoGridItem({
    super.key,
    required this.file,
    required this.thumbnail,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.onDoubleTap,
    required this.onReorder,
  });

  @override
  State<_PhotoGridItem> createState() => _PhotoGridItemState();
}

class _PhotoGridItemState extends State<_PhotoGridItem>
    with AutomaticKeepAliveClientMixin {

  // Keep grid items alive for better UX while managing memory properly
  @override
  bool get wantKeepAlive => true; // Back to true for smooth scrolling

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Memory-optimized image widget
    final optimizedImage = _MemoryOptimizedImage(
      thumbnailFile: widget.thumbnail,
      fullImageFile: widget.file,
      isSelected: widget.isSelected,
      isDark: isDark,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final itemSize = Size(constraints.maxWidth, constraints.maxHeight);

        return LongPressDraggable<int>(
          data: widget.index,
          feedback: _buildOptimizedDragFeedback(itemSize, optimizedImage),
          childWhenDragging: Container(
            decoration: BoxDecoration(
              color: AppColors.gridDragPlaceholder(isDark),
              border: widget.isSelected
                  ? Border.all(
                  color: AppColors.gridSelectionBorder(isDark),
                  width: 4.0
              )
                  : null,
            ),
          ),
          child: DragTarget<int>(
            onWillAcceptWithDetails: (details) => details.data != widget.index,
            onAcceptWithDetails: (details) {
              widget.onReorder(details.data, widget.index);
            },
            builder: (context, candidateData, rejectedData) {
              final isTarget = candidateData.isNotEmpty;

              return GestureDetector(
                onTap: () => widget.onTap(widget.index),
                onDoubleTap: () => widget.onDoubleTap(widget.index),
                child: Container(
                  decoration: BoxDecoration(
                    border: isTarget
                        ? Border.all(color: AppColors.gridDragTargetBorder, width: 2)
                        : widget.isSelected
                        ? Border.all(
                        color: AppColors.gridSelectionBorder(isDark),
                        width: 4.0
                    )
                        : null,
                  ),
                  child: optimizedImage,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Optimized drag feedback for high refresh rate displays
  Widget _buildOptimizedDragFeedback(Size size, Widget content) {
    return Material(
      color: AppColors.pureTransparent,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.gridDragShadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: content,
        ),
      ),
    );
  }
}

/// Memory-optimized image widget that handles loading issues better
class _MemoryOptimizedImage extends StatefulWidget {
  final File thumbnailFile;
  final File fullImageFile;
  final bool isSelected;
  final bool isDark;

  const _MemoryOptimizedImage({
    required this.thumbnailFile,
    required this.fullImageFile,
    required this.isSelected,
    required this.isDark,
  });

  @override
  State<_MemoryOptimizedImage> createState() => _MemoryOptimizedImageState();
}

class _MemoryOptimizedImageState extends State<_MemoryOptimizedImage>
    with SingleTickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _imageLoaded = false;
  bool _useFallback = false;
  bool _isDisposed = false;
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();

    // Detect refresh rate for optimized animation timing
    final refreshRate = SchedulerBinding.instance.platformDispatcher.displays.first.refreshRate;
    final frameDuration = refreshRate > 90
        ? const Duration(milliseconds: 8)  // ~1 frame at 120Hz
        : const Duration(milliseconds: 16); // ~1 frame at 60Hz

    _fadeController = AnimationController(
      duration: frameDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(_MemoryOptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset state if the image files change
    if (oldWidget.thumbnailFile.path != widget.thumbnailFile.path ||
        oldWidget.fullImageFile.path != widget.fullImageFile.path) {
      setState(() {
        _imageLoaded = false;
        _useFallback = false;
        _currentImagePath = null;
        _fadeController.reset();
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildImageWidget(File imageFile) {
    // Track current image path to detect changes
    final imagePath = imageFile.path;

    // Reset loaded state if image changed
    if (_currentImagePath != imagePath) {
      _currentImagePath = imagePath;
      _imageLoaded = false;
      _fadeController.reset();
    }

    return Image.file(
      imageFile,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (_isDisposed) return const SizedBox.shrink();

        if (wasSynchronouslyLoaded) {
          _imageLoaded = true;
          return child;
        }

        if (frame != null && !_imageLoaded) {
          _imageLoaded = true;
          if (!_isDisposed && mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!_isDisposed && mounted) {
                _fadeController.forward();
              }
            });
          }
        }

        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: frame == null ? 0.0 : _fadeAnimation.value,
              child: child,
            );
          },
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (_isDisposed) return const SizedBox.shrink();

        debugPrint('Image failed to load: ${imageFile.path}, error: $error');

        // Try fallback to full image if thumbnail fails and we haven't tried it yet
        if (!_useFallback && imageFile.path == widget.thumbnailFile.path) {
          debugPrint('Thumbnail failed, trying full image: ${widget.fullImageFile.path}');

          // Schedule state update after current build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed && mounted) {
              setState(() {
                _useFallback = true;
                _imageLoaded = false;
                _currentImagePath = null;
              });
            }
          });

          // Show loading state while switching
          return Container(
            color: AppColors.gridErrorBackground(widget.isDark),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.gridErrorIcon(widget.isDark),
                  ),
                ),
              ),
            ),
          );
        }

        // Show error if both thumbnail and full image fail
        return Container(
          color: AppColors.gridErrorBackground(widget.isDark),
          child: Icon(
            Icons.error_outline,
            color: AppColors.gridErrorIcon(widget.isDark),
            size: 24,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox.shrink();

    final imageFile = _useFallback ? widget.fullImageFile : widget.thumbnailFile;

    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'image_${widget.fullImageFile.path}',
          child: _buildImageWidget(imageFile),
        ),

        // Selection indicator
        if (widget.isSelected)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textPrimaryLight,
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: AppColors.pureWhite,
              ),
            ),
          ),
      ],
    );
  }
}