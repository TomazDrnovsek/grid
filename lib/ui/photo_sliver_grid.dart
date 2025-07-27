import 'dart:io';
import 'package:flutter/material.dart';

class PhotoSliverGrid extends StatelessWidget {
  final List<File> images;
  final Set<int> selectedIndexes;
  final void Function(int) onTap;
  final void Function(int) onLongPress;
  final void Function(int oldIndex, int newIndex) onReorder;

  const PhotoSliverGrid({
    super.key,
    required this.images,
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
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        childAspectRatio: 3 / 4,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return _PhotoGridItem(
            key: ValueKey('photo_$index'),
            file: images[index],
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
  final int index;
  final bool isSelected;
  final void Function(int) onTap;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _PhotoGridItem({
    super.key,
    required this.file,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: index,
      feedback: _buildDragFeedback(),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
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
                    ? Border.all(color: Colors.blue, width: 2)
                    : isSelected
                    ? Border.all(color: Colors.black, width: 3.0)
                    : null,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Use memory-efficient image loading
                  Image.file(
                    file,
                    fit: BoxFit.cover,
                    // Reduce memory usage - these values are more reasonable
                    cacheWidth: 360, // Reduced from 200
                    // cacheHeight: 480, // Reduced from 267
                    // Add error handling
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.grey),
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
                          color: Colors.black,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragFeedback() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 118,
        height: 157,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            cacheWidth: 150,
            cacheHeight: 200,
          ),
        ),
      ),
    );
  }
}