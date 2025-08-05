// File: lib/widgets/adaptive_image.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/app_config.dart';
import '../app_theme.dart';
import '../services/image_cache_service.dart';
import '../services/performance_monitor.dart';
import 'error_boundary.dart';

/// Adaptive image widget that loads different quality based on scroll state
/// TASK 3.3: Prevents frame drops during scrolling by using low-quality images during scroll
class AdaptiveImage extends StatefulWidget {
  final File imageFile;
  final File thumbnailFile;
  final bool isScrolling;
  final bool isSelected;
  final bool isDark;
  final String heroTag;

  const AdaptiveImage({
    super.key,
    required this.imageFile,
    required this.thumbnailFile,
    required this.isScrolling,
    required this.isSelected,
    required this.isDark,
    required this.heroTag,
  });

  @override
  State<AdaptiveImage> createState() => _AdaptiveImageState();
}

class _AdaptiveImageState extends State<AdaptiveImage>
    with AutomaticKeepAliveClientMixin {

  // Keep image widgets alive across scrolling and theme changes
  @override
  bool get wantKeepAlive => true;

  Timer? _qualityUpgradeTimer;
  bool _useHighQuality = false;
  bool _isUpgrading = false;

  // Track image access for cache management
  final _imageCacheService = ImageCacheService();

  @override
  void initState() {
    super.initState();
    // Start with low quality for fast initial render
    _useHighQuality = false;
  }

  @override
  void didUpdateWidget(AdaptiveImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect scroll state changes
    if (!widget.isScrolling && oldWidget.isScrolling) {
      // 🛑 SCROLLING STOPPED - Schedule high quality upgrade
      _scheduleQualityUpgrade();
    } else if (widget.isScrolling && !oldWidget.isScrolling) {
      // 🚀 SCROLLING STARTED - Switch to low quality immediately
      _cancelQualityUpgrade();
      if (_useHighQuality) {
        setState(() {
          _useHighQuality = false;
          _isUpgrading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _qualityUpgradeTimer?.cancel();
    super.dispose();
  }

  /// Schedule quality upgrade after scrolling stops
  void _scheduleQualityUpgrade() {
    _cancelQualityUpgrade();

    // Use AppConfig for optimized timing
    final delay = AppConfig().isHighRefreshRate
        ? const Duration(milliseconds: 150)  // Faster upgrade on 120Hz
        : const Duration(milliseconds: 200); // Standard delay on 60Hz

    _qualityUpgradeTimer = Timer(delay, () {
      if (mounted && !widget.isScrolling) {
        _upgradeToHighQuality();
      }
    });
  }

  /// Cancel pending quality upgrade
  void _cancelQualityUpgrade() {
    _qualityUpgradeTimer?.cancel();
    _qualityUpgradeTimer = null;
  }

  /// Upgrade to high quality image
  void _upgradeToHighQuality() {
    if (_useHighQuality || _isUpgrading) return;

    setState(() {
      _isUpgrading = true;
    });

    // Start performance monitoring for quality upgrade
    PerformanceMonitor.instance.startOperation('adaptive_quality_upgrade');

    // Track image access for cache management
    _imageCacheService.trackImageAccess(widget.imageFile.path);

    setState(() {
      _useHighQuality = true;
      _isUpgrading = false;
    });

    PerformanceMonitor.instance.endOperation('adaptive_quality_upgrade');

    debugPrint('🔄 Quality upgraded: ${widget.imageFile.path}');
  }

  /// Get current image file based on quality setting
  File get _currentImageFile {
    return _useHighQuality ? widget.imageFile : widget.thumbnailFile;
  }

  /// Get cache width for current quality
  int? get _currentCacheWidth {
    if (_useHighQuality) {
      return null; // Full resolution
    } else {
      return AppConfig().thumbnailCacheWidth; // Optimized thumbnail width
    }
  }

  /// Build error widget with theme support
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

  /// Build image with optimized error handling
  Widget _buildImageWidget(File imageFile) {
    return Image.file(
      imageFile,
      fit: BoxFit.cover,
      gaplessPlayback: true, // Critical for smooth transitions
      cacheWidth: _currentCacheWidth,
      filterQuality: _useHighQuality ? FilterQuality.high : FilterQuality.low,
      isAntiAlias: _useHighQuality, // Only antialias high-quality images
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Adaptive image error for ${imageFile.path}: $error');

        // Try fallback: if thumbnail fails, try full image; if full image fails, try thumbnail
        if (imageFile.path == widget.thumbnailFile.path &&
            widget.thumbnailFile.path != widget.imageFile.path) {
          return ErrorBoundary(
            errorContext: 'Adaptive Image Fallback',
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              cacheWidth: _currentCacheWidth,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Full image fallback error for ${widget.imageFile.path}: $error');
                return _buildErrorWidget();
              },
            ),
          );
        }

        return _buildErrorWidget();
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        // Optimized frame builder for adaptive loading
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }

        // Show placeholder while loading
        return Container(
          color: AppColors.gridErrorBackground(widget.isDark),
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  AppColors.textSecondary(widget.isDark),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Stack(
      fit: StackFit.expand,
      children: [
        // Main image with error boundary and hero animation
        ErrorBoundary(
          errorContext: 'Adaptive Image',
          child: Hero(
            tag: widget.heroTag,
            flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
                ) {
              // Optimized hero animation with adaptive quality
              return ErrorBoundary(
                errorContext: 'Hero Flight Animation',
                child: FadeTransition(
                  opacity: animation,
                  child: _buildImageWidget(widget.imageFile), // Always show full quality in hero
                ),
              );
            },
            child: _buildImageWidget(_currentImageFile),
          ),
        ),

        // Quality indicator (debug mode only)
        if (kDebugMode && _isUpgrading)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                '⬆',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        // Selection indicator with error boundary
        if (widget.isSelected)
          ErrorBoundary(
            errorContext: 'Selection Indicator',
            child: Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gridSelectionTickBg(widget.isDark),
                  border: Border.all(
                    color: AppColors.gridSelectionBorder(widget.isDark),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: AppColors.pureWhite,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Adaptive image extension methods for easier integration
extension AdaptiveImageExtensions on Widget {
  /// Wrap with adaptive image error boundary
  Widget withAdaptiveErrorBoundary({VoidCallback? onRetry}) {
    return ErrorBoundary(
      errorContext: 'Adaptive Image Container',
      showRetryButton: onRetry != null,
      onRetry: onRetry,
      child: this,
    );
  }
}

/// Adaptive loading statistics for monitoring
class AdaptiveImageStats {
  final int totalImages;
  final int highQualityImages;
  final int lowQualityImages;
  final int upgradesInProgress;
  final double upgradePercentage;

  const AdaptiveImageStats({
    required this.totalImages,
    required this.highQualityImages,
    required this.lowQualityImages,
    required this.upgradesInProgress,
    required this.upgradePercentage,
  });

  @override
  String toString() {
    return 'AdaptiveImageStats(total: $totalImages, high: $highQualityImages, low: $lowQualityImages, upgrading: $upgradesInProgress, upgrade%: ${upgradePercentage.toStringAsFixed(1)}%)';
  }
}

/// Static utility for tracking adaptive image statistics
class AdaptiveImageTracker {
  static int _totalImages = 0;
  static int _highQualityImages = 0;
  static int _lowQualityImages = 0;
  static int _upgradesInProgress = 0;

  static void incrementTotal() => _totalImages++;
  static void incrementHighQuality() => _highQualityImages++;
  static void incrementLowQuality() => _lowQualityImages++;
  static void incrementUpgrading() => _upgradesInProgress++;
  static void decrementUpgrading() => _upgradesInProgress--;

  static AdaptiveImageStats getStats() {
    final upgradePercentage = _totalImages > 0
        ? (_highQualityImages / _totalImages) * 100
        : 0.0;

    return AdaptiveImageStats(
      totalImages: _totalImages,
      highQualityImages: _highQualityImages,
      lowQualityImages: _lowQualityImages,
      upgradesInProgress: _upgradesInProgress,
      upgradePercentage: upgradePercentage,
    );
  }

  static void reset() {
    _totalImages = 0;
    _highQualityImages = 0;
    _lowQualityImages = 0;
    _upgradesInProgress = 0;
  }
}