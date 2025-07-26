import 'dart:io';
import 'package:flutter/material.dart';

class PhotoGrid extends StatelessWidget {
  final List<File> images;
  final Set<int> selectedIndexes;
  final void Function(int) onTap;
  final void Function(int) onLongPress;
  final void Function(int oldIndex, int newIndex) onReorder;

  const PhotoGrid({
    super.key,
    required this.images,
    required this.selectedIndexes,
    required this.onTap,
    required this.onLongPress,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          final isSelected = selectedIndexes.contains(index);

          return LongPressDraggable<int>(
            data: index,
            feedback: Material(
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
                    images[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
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
                          : null,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: isSelected
                              ? BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3.0),
                          )
                              : null,
                          child: Image.file(
                            images[index],
                            fit: BoxFit.cover,
                          ),
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
        },
      ),
    );
  }
}