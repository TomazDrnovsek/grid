import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grid/app_theme.dart';

class PhotoSliverGrid extends StatelessWidget {
  final List<File> images;
  final List<File> thumbnails;
  final Set<int> selectedIndexes;
  final void Function(int) onTap;
  final void Function(int) onLongPress;
  final void Function(int oldIndex, int newIndex) onReorder;

  const PhotoSliverGrid({
    super.key,
    required this.images,
    required this.thumbnails,
    required this.selectedIndexes,
    required this.onTap,
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
            onReorder: onReorder,
          );
        },
        childCount: images.length,
        // Add these for better performance
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,
      ),
    );
  }
}

class _PhotoGridItem extends StatelessWidget {
  final File file;
  final File thumbnail;
  final int index;
  final bool isSelected;
  final void Function(int) onTap;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _PhotoGridItem({
    super.key,
    required this.file,
    required this.thumbnail,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    // This is the actual content of the grid item, which will be reused for child, childWhenDragging, and feedback
    final gridItemVisualContent = Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          thumbnail, // Use thumbnail for better performance and quality
          fit: BoxFit.cover,
          // Removed cacheWidth since thumbnails are already optimized size
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.gridErrorBackground,
              child: const Icon(Icons.error, color: AppColors.gridErrorIcon),
            );
          },
        ),
        if (isSelected)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gridSelectionTickBg,
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );

    // Use LayoutBuilder to get the size of the _PhotoGridItem
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final itemSize = Size(constraints.maxWidth, constraints.maxHeight);

        return LongPressDraggable<int>(
          data: index,
          // MODIFIED: Pass the calculated itemSize directly to _buildDragFeedback
          feedback: _buildDragFeedback(itemSize, gridItemVisualContent),
          // MODIFIED: childWhenDragging now mirrors the actual item's appearance
          childWhenDragging: Container(
            decoration: BoxDecoration(
              color: AppColors.gridDragPlaceholder, // This color will now be visible
              border: isSelected
                  ? Border.all(color: AppColors.gridSelectionBorder, width: 4.0)
                  : null,
            ),
            // The 'child' property showing the image has been removed.
          ),
          child: DragTarget<int>(
            onWillAcceptWithDetails: (details) => details.data != index,
            onAcceptWithDetails: (details) {
              onReorder(details.data, index);
            },
            builder: (context, candidateData, rejectedData) {
              final isTarget = candidateData.isNotEmpty;

              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: isTarget
                        ? Border.all(color: AppColors.gridDragTargetBorder, width: 2)
                        : isSelected
                        ? Border.all(color: AppColors.gridSelectionBorder, width: 4.0)
                        : null,
                  ),
                  child: gridItemVisualContent, // Use the shared visual content
                ),
              );
            },
          ),
        );
      },
    );
  }

  // MODIFIED: _buildDragFeedback now accepts the Size of the original widget and its content
  Widget _buildDragFeedback(Size size, Widget content) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: size.width, // Set width to match the original item
        height: size.height, // Set height to match the original item
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: AppColors.gridDragShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: content, // Use the passed content
        ),
      ),
    );
  }
}