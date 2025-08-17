import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class _PhotoSliverGridState extends State<PhotoSliverGrid>
    with TickerProviderStateMixin {  // Changed from SingleTickerProviderStateMixin to TickerProviderStateMixin
  final ScrollOptimizationService _scrollOptimizer = ScrollOptimizationService();
  final ImageCacheService _cacheService = ImageCacheService();
  final DragScrollService _dragScrollService = DragScrollService();

  // Ticker for smooth vsync-aligned scrolling
  Ticker? _autoScrollTicker;
  Duration _autoScrollLastTs = Duration.zero;

  // Track drag state and position
  bool _isDragging = false;
  Offset? _currentDragPosition;

  // Track if auto-scroll has been activated before (eliminates delay on subsequent drags)
  bool _hasActivatedAutoScrollBefore = false;

  @override
  void initState() {
    super.initState();
    _scrollOptimizer.initialize();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _autoScrollTicker?.dispose();
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

  void _onDragStarted() {
    _isDragging = true;
    _dragScrollService.onDragStart();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || widget.scrollController == null) return;

    _currentDragPosition = details.globalPosition;

    // Check if drag activation delay has passed (150ms) - but allow immediate activation on subsequent drags
    if (!_dragScrollService.canActivateAutoScroll() && !_hasActivatedAutoScrollBefore) return;

    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final dragY = details.globalPosition.dy;

    // Determine edge zone
    EdgeZone zone = EdgeZone.none;

    if (dragY < 80.0) {
      zone = EdgeZone.top;
      if (kDebugMode) {
        debugPrint('Drag in TOP zone - Distance from edge: $dragY px');
      }
    } else if (dragY > screenHeight - 80.0) {
      zone = EdgeZone.bottom;
      final distanceFromBottom = screenHeight - dragY;
      if (kDebugMode) {
        debugPrint('Drag in BOTTOM zone - Distance from edge: $distanceFromBottom px');
      }
    }

    // Start or stop auto-scroll based on zone
    if (zone != EdgeZone.none && _autoScrollTicker == null) {
      if (kDebugMode) {
        debugPrint('Starting auto-scroll in $zone zone');
      }
      _hasActivatedAutoScrollBefore = true;
      _startAutoScroll(zone, dragY, screenHeight);
    } else if (zone == EdgeZone.none && _autoScrollTicker != null) {
      if (kDebugMode) {
        debugPrint('Stopping auto-scroll - out of edge zones');
      }
      _stopAutoScroll();
    }
  }

  void _onDragEnded() {
    _isDragging = false;
    _currentDragPosition = null;
    _stopAutoScroll();
    _dragScrollService.onDragEnd();
  }

  void _startAutoScroll(EdgeZone initialZone, double initialDragY, double screenHeight) {
    _autoScrollTicker?.dispose();
    _autoScrollLastTs = Duration.zero;

    int frameCount = 0;
    final cachedScreenHeight = screenHeight;

    _autoScrollTicker = createTicker((elapsed) {
      // Calculate actual delta time
      final dt = _autoScrollLastTs == Duration.zero
          ? 0.0  // First frame: no movement
          : (elapsed - _autoScrollLastTs).inMicroseconds / 1e6;
      _autoScrollLastTs = elapsed;

      final controller = widget.scrollController;
      if (controller == null || !controller.hasClients) {
        _stopAutoScroll();
        return;
      }

      final dragY = _currentDragPosition?.dy ?? initialDragY;

      // Calculate zone and velocity
      EdgeZone zone = EdgeZone.none;
      double v = 0.0;
      if (dragY < 80.0) {
        zone = EdgeZone.top;
        final d = dragY;
        v = d < 20 ? 1070.0 : d < 40 ? 665.0 : d < 60 ? 400.0 : 200.0;
      } else if (dragY > cachedScreenHeight - 80.0) {
        zone = EdgeZone.bottom;
        final d = cachedScreenHeight - dragY;
        v = d < 20 ? 1070.0 : d < 40 ? 665.0 : d < 60 ? 400.0 : 200.0;
      }

      if (zone == EdgeZone.none) {
        _stopAutoScroll();
        return;
      }

      // Log velocity periodically
      if (kDebugMode && frameCount % 10 == 0) {
        final distFromEdge = zone == EdgeZone.top
            ? dragY
            : cachedScreenHeight - dragY;
        debugPrint('Auto-scroll: Velocity: ${v.toStringAsFixed(0)}px/s - Distance from edge: ${distFromEdge.toStringAsFixed(0)}px');
      }
      frameCount++;

      final min = controller.position.minScrollExtent;
      final max = controller.position.maxScrollExtent;
      final current = controller.offset;

      final delta = v * dt;
      double target = zone == EdgeZone.top ? current - delta : current + delta;
      target = target.clamp(min, max);

      if ((zone == EdgeZone.top && target <= min) ||
          (zone == EdgeZone.bottom && target >= max)) {
        _stopAutoScroll();
        return;
      }

      controller.jumpTo(target);
    });

    _autoScrollTicker!.start();
  }

  void _stopAutoScroll() {
    _autoScrollTicker?.stop();
    _autoScrollTicker?.dispose();
    _autoScrollTicker = null;
    _autoScrollLastTs = Duration.zero;
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
                  if (kDebugMode) {
                    debugPrint('Retrying grid item $index');
                  }
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
          onDragUpdate: widget.onDragUpdate,
          onDragEnd: (details) => widget.onDragEnded(),
          feedback: _buildLightweightDragFeedback(itemSize, isDark),
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

  Widget _buildLightweightDragFeedback(Size size, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Container(
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Simple thumbnail image - NO Hero, NO ErrorBoundary
                Image.file(
                  widget.thumbnail,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  cacheWidth: 360,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.gridErrorBackground(isDark),
                      child: Icon(
                        Icons.error_outline,
                        color: AppColors.gridErrorIcon(isDark),
                        size: 24,
                      ),
                    );
                  },
                ),

                // Hue map overlay if enabled
                if (widget.showHueMap)
                  FutureBuilder<Color>(
                    future: DominantColorService().getDominantColor(widget.thumbnail.path),
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

                // Selection checkmark if selected
                if (widget.isSelected)
                  Positioned(
                    bottom: 4,
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
          ),
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
              bottom: 4,
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