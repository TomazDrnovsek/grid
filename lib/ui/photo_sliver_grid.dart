// File: lib/ui/photo_sliver_grid.dart
import 'dart:io';
import 'dart:async';
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
          // Bounds checking
          if (index >= images.length) {
            return const SizedBox.shrink();
          }

          final thumbnail = index < thumbnails.length ? thumbnails[index] : images[index];

          return _PhotoGridItem(
            key: ValueKey('photo_${images[index].path}_$index'),
            file: images[index],
            thumbnail: thumbnail,
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

  // Track widget state to prevent race conditions
  bool _isDisposed = false;
  bool _isMounted = true;

  // Track current loading state
  String? _currentImagePath;
  bool _isLoadingImage = false;
  bool _hasError = false;
  bool _useFallback = false;
  Timer? _loadingTimeout;

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

      // Cancel any pending operations
      _currentImagePath = null;
      _isLoadingImage = false;
      _loadingTimeout?.cancel();

      if (_isMounted && !_isDisposed) {
        setState(() {
          _hasError = false;
          _useFallback = false;
          _fadeController.reset();
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isMounted = false;
    _loadingTimeout?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_isMounted && mounted && !_isDisposed) {
      setState(fn);
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.gridErrorBackground(widget.isDark),
      child: Icon(
        Icons.error_outline,
        color: AppColors.gridErrorIcon(widget.isDark),
        size: 24,
      ),
    );
  }

  Widget _buildLoadingWidget() {
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

  Widget _buildImageWidget(File imageFile) {
    final imagePath = imageFile.path;

    // Prevent multiple simultaneous loads of the same image
    if (_currentImagePath == imagePath && _isLoadingImage) {
      return _buildLoadingWidget();
    }

    // Reset state for new image
    if (_currentImagePath != imagePath) {
      _currentImagePath = imagePath;
      _isLoadingImage = true;
      _hasError = false;

      // Cancel any existing timeout
      _loadingTimeout?.cancel();

      // Set a timeout for image loading
      _loadingTimeout = Timer(const Duration(seconds: 10), () {
        if (_isLoadingImage && _isMounted && mounted && !_isDisposed) {
          debugPrint('Image loading timeout for: $imagePath');
          _safeSetState(() {
            _isLoadingImage = false;
            _hasError = true;
          });
        }
      });

      // Reset animation safely
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_isMounted && mounted && !_isDisposed) {
          _fadeController.reset();
        }
      });
    }

    return Image.file(
      imageFile,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      cacheWidth: 480, // Fixed cache width for consistency
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (_isDisposed || !_isMounted) {
          return const SizedBox.shrink();
        }

        if (wasSynchronouslyLoaded) {
          _isLoadingImage = false;
          _loadingTimeout?.cancel();
          return child;
        }

        if (frame != null) {
          // Image loaded successfully
          _isLoadingImage = false;
          _loadingTimeout?.cancel();

          // Safely trigger fade animation
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (_isMounted && mounted && !_isDisposed && !_hasError) {
              _fadeController.forward();
            }
          });

          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, animChild) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: animChild,
              );
            },
            child: child,
          );
        }

        // Still loading
        return _buildLoadingWidget();
      },
      errorBuilder: (context, error, stackTrace) {
        if (_isDisposed || !_isMounted) {
          return const SizedBox.shrink();
        }

        debugPrint('Image failed to load: ${imageFile.path}, error: $error');
        _isLoadingImage = false;
        _hasError = true;
        _loadingTimeout?.cancel();

        // Try fallback to full image if thumbnail fails and we haven't tried it yet
        if (!_useFallback && imageFile.path == widget.thumbnailFile.path) {
          debugPrint('Thumbnail failed, scheduling fallback to full image');

          // Use post frame callback to avoid setState during build
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _safeSetState(() {
              _useFallback = true;
              _currentImagePath = null;
              _isLoadingImage = false;
            });
          });

          // Show loading state while switching
          return _buildLoadingWidget();
        }

        // Show error if both thumbnail and full image fail
        return _buildErrorWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed || !_isMounted) {
      return const SizedBox.shrink();
    }

    try {
      final imageFile = _useFallback ? widget.fullImageFile : widget.thumbnailFile;

      // Quick existence check to fail fast
      if (!imageFile.existsSync()) {
        return _buildErrorWidget();
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'image_${widget.fullImageFile.path}',
            flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
                ) {
              // Custom flight animation to prevent glitches
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: animation.drive(
                      Tween<double>(begin: 1.0, end: 1.0),
                    ),
                    child: _buildImageWidget(widget.fullImageFile),
                  );
                },
              );
            },
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
    } catch (e) {
      debugPrint('Error building image widget: $e');
      return _buildErrorWidget();
    }
  }
}