import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid/app_theme.dart';
import 'package:grid/widgets/error_boundary.dart';
import 'package:grid/services/scroll_optimization_service.dart';
import 'package:grid/services/image_cache_service.dart';
import 'package:grid/services/dominant_color_service.dart';
import 'package:grid/services/drag_scroll_service.dart';
import 'package:grid/providers/photo_provider.dart';

// Edge zone enum for drag-to-scroll
enum EdgeZone { none, top, bottom }

class PhotoSliverGrid extends StatefulWidget {
  final List<File> images;
  final List<File> thumbnails;
  final Set<int> selectedIndexes;
  final void Function(int) onTap;
  final void Function(int) onDoubleTap;
  final void Function(int) onLongPress;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ScrollController? scrollController;

  const PhotoSliverGrid({
    super.key,
    required this.images,
    required this.thumbnails,
    required this.selectedIndexes,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onReorder,
    this.scrollController,
  });

  @override
  State<PhotoSliverGrid> createState() => _PhotoSliverGridState();
}

class _PhotoSliverGridState extends State<PhotoSliverGrid> {
  final ScrollOptimizationService _scrollOptimizer = ScrollOptimizationService();
  final ImageCacheService _cacheService = ImageCacheService();

  // PHASE 3: Drag-to-edge scroll service
  final DragScrollService _dragScrollService = DragScrollService();
  Timer? _autoScrollTimer;

  // Track drag state and position
  bool _isDragging = false;
  Offset? _currentDragPosition;

  @override
  void initState() {
    super.initState();
    _scrollOptimizer.initialize();

    // Listen to scroll events for optimization
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    widget.scrollController?.removeListener(_onScroll);
    _scrollOptimizer.dispose();
    super.dispose();
  }

  void _onScroll() {
    try {
      final scrollOffset = widget.scrollController?.offset ?? 0.0;
      final viewportHeight = MediaQuery.of(context).size.height;

      const itemsPerRow = 3;
      final itemHeight = MediaQuery.of(context).size.width / itemsPerRow * 4 / 3;

      final visibleStartRow = (scrollOffset / itemHeight).floor().clamp(0, 999);
      final visibleEndRow = ((scrollOffset + viewportHeight) / itemHeight).ceil().clamp(0, 999);

      final visibleStart = (visibleStartRow * itemsPerRow).clamp(0, widget.images.length);
      final visibleEnd = (visibleEndRow * itemsPerRow).clamp(0, widget.images.length - 1);

      final imagePaths = widget.images.map((f) => f.path).toList();
      _scrollOptimizer.updateVisibleRange(imagePaths, visibleStart, visibleEnd);

    } catch (e) {
      // Silent error handling
    }
  }

  // PHASE 3: Enhanced drag callbacks with position tracking
  void _onDragStarted() {
    _isDragging = true;
    _dragScrollService.onDragStart();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || widget.scrollController == null) return;

    _currentDragPosition = details.globalPosition;

    // Check if drag activation delay has passed (150ms)
    if (!_dragScrollService.canActivateAutoScroll()) return;

    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final dragY = details.globalPosition.dy;

    // Determine edge zone using proper detection
    EdgeZone zone = EdgeZone.none;

    // Check if in top edge zone (80px from top)
    if (dragY < 80.0) {
      zone = EdgeZone.top;
      // Debug: Print distance from edge
      debugPrint('Drag in TOP zone - Distance from edge: $dragY px');
    }
    // Check if in bottom edge zone (80px from bottom)
    else if (dragY > screenHeight - 80.0) {
      zone = EdgeZone.bottom;
      final distanceFromBottom = screenHeight - dragY;
      debugPrint('Drag in BOTTOM zone - Distance from edge: $distanceFromBottom px');
    }

    // Start or stop auto-scroll based on zone
    if (zone != EdgeZone.none && _autoScrollTimer == null) {
      debugPrint('Starting auto-scroll in $zone zone');
      _startAutoScroll(zone, dragY, screenHeight);
    } else if (zone == EdgeZone.none && _autoScrollTimer != null) {
      debugPrint('Stopping auto-scroll - out of edge zones');
      _stopAutoScroll();
    }
  }

  void _onDragEnded() {
    _isDragging = false;
    _currentDragPosition = null;
    _stopAutoScroll();
    _dragScrollService.onDragEnd();
  }

  void _startAutoScroll(EdgeZone zone, double dragY, double screenHeight) {
    _autoScrollTimer?.cancel();

    // Debug flag for velocity logging
    int frameCount = 0;

    // Start timer for smooth scrolling
    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 16), // 60 FPS
          (timer) {
        if (widget.scrollController == null || !widget.scrollController!.hasClients) {
          timer.cancel();
          _autoScrollTimer = null;
          return;
        }

        // Get current drag position for dynamic speed calculation
        final currentDragY = _currentDragPosition?.dy ?? dragY;

        // Recalculate velocity on each frame based on current position
        double velocity = 0.0;
        EdgeZone currentZone = EdgeZone.none;
        String speedZoneName = '';

        if (currentDragY < 80.0) {
          currentZone = EdgeZone.top;
          // Distance from top edge
          final distanceFromEdge = currentDragY;
          if (distanceFromEdge < 20) {
            velocity = 800.0; // Ultra fast zone (0-20px)
            speedZoneName = 'ULTRA FAST';
          } else if (distanceFromEdge < 40) {
            velocity = 500.0; // Fast zone (20-40px)
            speedZoneName = 'FAST';
          } else if (distanceFromEdge < 60) {
            velocity = 300.0; // Medium zone (40-60px)
            speedZoneName = 'MEDIUM';
          } else {
            velocity = 150.0; // Slow zone (60-80px)
            speedZoneName = 'SLOW';
          }
        } else if (currentDragY > screenHeight - 80.0) {
          currentZone = EdgeZone.bottom;
          // Distance from bottom edge
          final distanceFromEdge = screenHeight - currentDragY;
          if (distanceFromEdge < 20) {
            velocity = 800.0; // Ultra fast zone (0-20px)
            speedZoneName = 'ULTRA FAST';
          } else if (distanceFromEdge < 40) {
            velocity = 500.0; // Fast zone (20-40px)
            speedZoneName = 'FAST';
          } else if (distanceFromEdge < 60) {
            velocity = 300.0; // Medium zone (40-60px)
            speedZoneName = 'MEDIUM';
          } else {
            velocity = 150.0; // Slow zone (60-80px)
            speedZoneName = 'SLOW';
          }
        }

        // Log velocity every 10 frames (about 6 times per second)
        if (frameCount % 10 == 0) {
          final distFromEdge = currentZone == EdgeZone.top
              ? currentDragY
              : screenHeight - currentDragY;
          debugPrint('Auto-scroll: $speedZoneName - Velocity: ${velocity.toStringAsFixed(0)}px/s - Distance from edge: ${distFromEdge.toStringAsFixed(0)}px');
        }
        frameCount++;

        // Stop if no longer in edge zone
        if (currentZone == EdgeZone.none) {
          debugPrint('Auto-scroll stopped - left edge zone');
          timer.cancel();
          _autoScrollTimer = null;
          return;
        }

        final currentOffset = widget.scrollController!.offset;
        final minExtent = widget.scrollController!.position.minScrollExtent;
        final maxExtent = widget.scrollController!.position.maxScrollExtent;

        // Calculate frame delta with easing for smoother acceleration
        final delta = velocity * 0.016; // 16ms = 0.016 seconds

        // Calculate target offset
        double targetOffset;
        if (currentZone == EdgeZone.top) {
          targetOffset = currentOffset - delta; // Scroll up
        } else {
          targetOffset = currentOffset + delta; // Scroll down
        }

        // Clamp to bounds
        targetOffset = targetOffset.clamp(minExtent, maxExtent);

        // Check if reached boundary
        if ((currentZone == EdgeZone.top && targetOffset <= minExtent) ||
            (currentZone == EdgeZone.bottom && targetOffset >= maxExtent)) {
          debugPrint('Auto-scroll stopped - reached boundary');
          timer.cancel();
          _autoScrollTimer = null;
          return;
        }

        // Animate to new position
        widget.scrollController!.jumpTo(targetOffset);
      },
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final showHueMap = ref.watch(photoNotifierProvider.select((state) => state.showHueMap));

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 3 / 4,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (index < 0 || index >= widget.images.length) {
                return const SizedBox.shrink();
              }

              final thumbnail = (index < widget.thumbnails.length && index >= 0)
                  ? widget.thumbnails[index]
                  : widget.images[index];

              return GridItemErrorBoundary(
                onRetry: () {
                  debugPrint('Retrying grid item $index');
                },
                child: _PerformanceOptimizedGridItem(
                  key: ValueKey('photo_${index}_${widget.images[index].path.hashCode}'),
                  file: widget.images[index],
                  thumbnail: thumbnail,
                  index: index,
                  isSelected: widget.selectedIndexes.contains(index),
                  showHueMap: showHueMap,
                  onTap: widget.onTap,
                  onDoubleTap: widget.onDoubleTap,
                  onReorder: widget.onReorder,
                  cacheService: _cacheService,
                  onDragStarted: _onDragStarted,
                  onDragUpdate: _onDragUpdate,
                  onDragEnded: _onDragEnded,
                ),
              );
            },
            childCount: widget.images.length,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            addSemanticIndexes: false,
          ),
        );
      },
    );
  }
}

/// Performance optimized grid item
class _PerformanceOptimizedGridItem extends StatefulWidget {
  final File file;
  final File thumbnail;
  final int index;
  final bool isSelected;
  final bool showHueMap;
  final void Function(int) onTap;
  final void Function(int) onDoubleTap;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ImageCacheService cacheService;
  final VoidCallback onDragStarted;
  final void Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragEnded;

  const _PerformanceOptimizedGridItem({
    super.key,
    required this.file,
    required this.thumbnail,
    required this.index,
    required this.isSelected,
    required this.showHueMap,
    required this.onTap,
    required this.onDoubleTap,
    required this.onReorder,
    required this.cacheService,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnded,
  });

  @override
  State<_PerformanceOptimizedGridItem> createState() => _PerformanceOptimizedGridItemState();
}

class _PerformanceOptimizedGridItemState extends State<_PerformanceOptimizedGridItem>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  Timer? _doubleTapTimer;
  bool _waitingForSecondTap = false;
  static const Duration _doubleTapWindow = Duration(milliseconds: 300);

  @override
  void dispose() {
    _doubleTapTimer?.cancel();
    super.dispose();
  }

  void _handleInstantTap() {
    if (_waitingForSecondTap) {
      _doubleTapTimer?.cancel();
      _waitingForSecondTap = false;
      widget.onDoubleTap(widget.index);
    } else {
      widget.onTap(widget.index);
      _waitingForSecondTap = true;
      _doubleTapTimer = Timer(_doubleTapWindow, () {
        _waitingForSecondTap = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final optimizedImage = ImageErrorBoundary(
      imagePath: widget.thumbnail.path,
      onRetry: () {
        if (mounted) {
          setState(() {});
        }
      },
      child: _MemoryAwareImage(
        thumbnailFile: widget.thumbnail,
        fullImageFile: widget.file,
        isSelected: widget.isSelected,
        showHueMap: widget.showHueMap,
        isDark: isDark,
        cacheService: widget.cacheService,
      ),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final itemSize = Size(constraints.maxWidth, constraints.maxHeight);

        return LongPressDraggable<int>(
          data: widget.index,
          onDragStarted: widget.onDragStarted,
          onDragUpdate: widget.onDragUpdate, // Track drag position
          onDragEnd: (details) => widget.onDragEnded(),
          feedback: _buildLightweightDragFeedback(itemSize, optimizedImage),
          // FIX 1: Proper gray placeholder without the image
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
            // REMOVED the optimizedImage child - now shows only gray placeholder
          ),
          child: DragTarget<int>(
            onWillAcceptWithDetails: (details) => details.data != widget.index,
            onAcceptWithDetails: (details) {
              widget.onReorder(details.data, widget.index);
            },
            builder: (context, candidateData, rejectedData) {
              final isTarget = candidateData.isNotEmpty;

              return GestureDetector(
                onTap: _handleInstantTap,
                child: Container(
                  decoration: BoxDecoration(
                    border: isTarget
                        ? Border.all(color: Theme.of(context).primaryColor, width: 2)
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

  Widget _buildLightweightDragFeedback(Size size, Widget content) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: content,
        ),
      ),
    );
  }
}

/// Memory optimized image widget
class _MemoryAwareImage extends StatefulWidget {
  final File thumbnailFile;
  final File fullImageFile;
  final bool isSelected;
  final bool showHueMap;
  final bool isDark;
  final ImageCacheService cacheService;

  const _MemoryAwareImage({
    required this.thumbnailFile,
    required this.fullImageFile,
    required this.isSelected,
    required this.showHueMap,
    required this.isDark,
    required this.cacheService,
  });

  @override
  State<_MemoryAwareImage> createState() => _MemoryAwareImageState();
}

class _MemoryAwareImageState extends State<_MemoryAwareImage>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.cacheService.trackImageAccess(widget.thumbnailFile.path);
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

  Widget _buildMemoryOptimizedImageWidget(File imageFile) {
    return Image.file(
      imageFile,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      cacheWidth: 360,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame != null) {
          widget.cacheService.trackImageAccess(imageFile.path);
        } else {
          widget.cacheService.trackCacheMiss(imageFile.path);
        }

        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }

        return Container(
          color: AppColors.gridErrorBackground(widget.isDark).withValues(alpha: 0.1),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        widget.cacheService.trackCacheMiss(imageFile.path);
        return _buildErrorWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ErrorBoundary(
            errorContext: 'Hero Animation',
            child: Hero(
              tag: 'image_${widget.fullImageFile.path}',
              child: _buildMemoryOptimizedImageWidget(widget.thumbnailFile),
            ),
          ),

          if (widget.showHueMap)
            FutureBuilder<Color>(
              future: DominantColorService().getDominantColor(widget.thumbnailFile.path),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == Colors.transparent) {
                  return const SizedBox.shrink();
                }

                return Container(
                  decoration: BoxDecoration(
                    color: snapshot.data!.withValues(alpha: 0.8),
                  ),
                );
              },
            ),

          if (widget.isSelected)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}