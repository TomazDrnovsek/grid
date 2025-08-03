// File: lib/ui/photo_sliver_grid.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grid/app_theme.dart';
import 'package:grid/core/app_config.dart';

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
            key: ValueKey('photo_${images[index].path}'), // Stable key for image caching
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
        // Optimized for smooth scrolling and image persistence
        addAutomaticKeepAlives: true,   // Critical: Keep visible items alive
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

  // Critical: Keep grid items alive for better scrolling performance
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Simple, stable image widget
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

/// Simple, reliable image widget with clean lifecycle management
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
    with AutomaticKeepAliveClientMixin {

  // Keep image widgets alive across theme changes and scrolling
  @override
  bool get wantKeepAlive => true;

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

  Widget _buildImageWidget(File imageFile) {
    return Image.file(
      imageFile,
      fit: BoxFit.cover,
      gaplessPlayback: true, // Critical for preventing flicker during rebuilds
      cacheWidth: AppConfig().thumbnailCacheWidth, // Use cached optimal width
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image error for ${imageFile.path}: $error');

        // Try fallback to full image if thumbnail fails
        if (imageFile.path == widget.thumbnailFile.path &&
            widget.thumbnailFile.path != widget.fullImageFile.path) {
          return Image.file(
            widget.fullImageFile,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            cacheWidth: AppConfig().thumbnailCacheWidth,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Full image error for ${widget.fullImageFile.path}: $error');
              return _buildErrorWidget();
            },
          );
        }

        return _buildErrorWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
            // Stable hero animation
            return FadeTransition(
              opacity: animation,
              child: _buildImageWidget(widget.fullImageFile),
            );
          },
          child: _buildImageWidget(widget.thumbnailFile),
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