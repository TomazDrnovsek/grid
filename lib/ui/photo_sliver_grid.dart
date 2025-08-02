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
        // Optimizations for high refresh rate scrolling
        addAutomaticKeepAlives: true,  // Keep images alive for smoother scrolling
        addRepaintBoundaries: true,    // Isolate repaints for better performance
        addSemanticIndexes: false,     // Skip semantic indexing for performance
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

  // Keep grid items alive for smoother high refresh rate scrolling
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Optimized image widget with high refresh rate support
    final optimizedImage = _HighRefreshImage(
      file: widget.thumbnail,
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
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight,
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
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight,
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

/// High refresh rate optimized image widget with frame-perfect loading
class _HighRefreshImage extends StatefulWidget {
  final File file;
  final bool isSelected;
  final bool isDark;

  const _HighRefreshImage({
    required this.file,
    required this.isSelected,
    required this.isDark,
  });

  @override
  State<_HighRefreshImage> createState() => _HighRefreshImageState();
}

class _HighRefreshImageState extends State<_HighRefreshImage>
    with SingleTickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _imageLoaded = false;

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
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'image_${widget.file.path}',
          child: Image.file(
            widget.file,
            fit: BoxFit.cover,
            gaplessPlayback: true, // Critical for high refresh rate stability
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              // Handle frame-perfect loading for high refresh rate displays
              if (wasSynchronouslyLoaded) {
                _imageLoaded = true;
                return child;
              }

              if (frame != null && !_imageLoaded) {
                _imageLoaded = true;
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _fadeController.forward();
                  }
                });
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
              return Container(
                color: AppColors.gridErrorBackground(widget.isDark),
                child: Icon(
                    Icons.error,
                    color: AppColors.gridErrorIcon(widget.isDark)
                ),
              );
            },
          ),
        ),

        // Selection indicator with optimized rendering
        if (widget.isSelected)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textPrimaryLight, // Always black circle
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: AppColors.pureWhite, // Always white checkmark
              ),
            ),
          ),
      ],
    );
  }
}