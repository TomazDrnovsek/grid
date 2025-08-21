// File: lib/core/app_config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Singleton configuration manager for app-wide performance settings
/// Caches device capabilities and optimized parameters to avoid repeated queries
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Performance configuration
  late final double displayRefreshRate;
  late final bool isHighRefreshRate;
  late final double optimalCacheExtent;
  late final Duration animationDuration;
  late final Duration fastAnimationDuration;
  late final int optimalBatchSize;
  late final Duration batchDelay;
  late final double minFlingVelocity;
  late final double maxFlingVelocity;
  late final double scrollBuffer;

  // Physics configuration
  late final double springMass;
  late final double springStiffness;
  late final double springRatio;

  // Image cache configuration
  late final int imageCacheSize;
  late final int imageCacheSizeBytes;
  late final int thumbnailCacheWidth;

  // âœ… NEW: Feature flags
  static const bool enableCloudBackup = true;  // Feature flag for cloud backup functionality

  bool _isInitialized = false;

  /// Initialize all performance configuration based on device capabilities
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('AppConfig already initialized, skipping...');
      return;
    }

    try {
      // Get display refresh rate
      displayRefreshRate = _getRefreshRate();
      isHighRefreshRate = displayRefreshRate > 90;

      // Configure cache settings based on refresh rate
      optimalCacheExtent = isHighRefreshRate ? 2500.0 : 2000.0;

      // Animation durations optimized for refresh rate
      animationDuration = isHighRefreshRate
          ? const Duration(milliseconds: 200)   // Faster for 120Hz
          : const Duration(milliseconds: 300);  // Standard for 60Hz

      fastAnimationDuration = isHighRefreshRate
          ? const Duration(milliseconds: 150)   // Very fast for 120Hz
          : const Duration(milliseconds: 200);  // Fast for 60Hz

      // Batch processing settings
      optimalBatchSize = isHighRefreshRate ? 5 : 10;
      batchDelay = isHighRefreshRate
          ? Duration.zero
          : const Duration(milliseconds: 1);

      // Scroll physics settings
      minFlingVelocity = isHighRefreshRate ? 30.0 : 50.0;
      maxFlingVelocity = isHighRefreshRate ? 12000.0 : 8000.0;
      scrollBuffer = isHighRefreshRate ? 50.0 : 100.0;

      // Spring physics configuration
      if (isHighRefreshRate) {
        // Optimized for 120Hz+ displays
        springMass = 0.4;        // Lighter for more responsive feel
        springStiffness = 200.0; // Higher stiffness for smoothness
        springRatio = 1.1;       // Slight damping for fluid motion
      } else {
        // Optimized for 60Hz displays
        springMass = 0.6;        // Slightly heavier for stability
        springStiffness = 120.0; // Perfect for 60Hz
        springRatio = 1.2;       // More damping for softer bounce
      }

      // Image cache configuration
      imageCacheSize = isHighRefreshRate ? 75 : 50;  // Number of images
      imageCacheSizeBytes = isHighRefreshRate
          ? 150 * 1024 * 1024  // 150MB for high refresh rate
          : 100 * 1024 * 1024; // 100MB for standard refresh rate

      // Thumbnail cache width for sharp display
      final devicePixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
      thumbnailCacheWidth = (360 * devicePixelRatio).round();

      _isInitialized = true;

      if (kDebugMode) {
        _printConfiguration();
      }

    } catch (e) {
      debugPrint('Error initializing AppConfig: $e');
      // Set fallback values for 60Hz
      _setFallbackConfiguration();
      _isInitialized = true;
    }
  }

  /// Get the actual refresh rate of the primary display
  double _getRefreshRate() {
    try {
      final displays = SchedulerBinding.instance.platformDispatcher.displays;
      if (displays.isNotEmpty) {
        return displays.first.refreshRate;
      }
      return 60.0;
    } catch (e) {
      debugPrint('Error getting refresh rate: $e');
      return 60.0; // Safe fallback
    }
  }

  /// Set fallback configuration for error cases
  void _setFallbackConfiguration() {
    displayRefreshRate = 60.0;
    isHighRefreshRate = false;
    optimalCacheExtent = 2000.0;
    animationDuration = const Duration(milliseconds: 300);
    fastAnimationDuration = const Duration(milliseconds: 200);
    optimalBatchSize = 10;
    batchDelay = const Duration(milliseconds: 1);
    minFlingVelocity = 50.0;
    maxFlingVelocity = 8000.0;
    scrollBuffer = 100.0;
    springMass = 0.6;
    springStiffness = 120.0;
    springRatio = 1.2;
    imageCacheSize = 50;
    imageCacheSizeBytes = 100 * 1024 * 1024;
    thumbnailCacheWidth = 1080; // 3x density fallback
  }

  /// Print configuration to debug console
  void _printConfiguration() {
    debugPrint('=== AppConfig Performance Settings ===');
    debugPrint('Display Refresh Rate: ${displayRefreshRate.toStringAsFixed(1)}Hz');
    debugPrint('High Refresh Rate Device: $isHighRefreshRate');
    debugPrint('Optimal Cache Extent: ${optimalCacheExtent.toStringAsFixed(0)}px');
    debugPrint('Animation Duration: ${animationDuration.inMilliseconds}ms');
    debugPrint('Fast Animation Duration: ${fastAnimationDuration.inMilliseconds}ms');
    debugPrint('Optimal Batch Size: $optimalBatchSize items');
    debugPrint('Batch Delay: ${batchDelay.inMilliseconds}ms');
    debugPrint('Min Fling Velocity: ${minFlingVelocity.toStringAsFixed(1)}');
    debugPrint('Max Fling Velocity: ${maxFlingVelocity.toStringAsFixed(1)}');
    debugPrint('Scroll Buffer: ${scrollBuffer.toStringAsFixed(1)}px');
    debugPrint('Spring Physics: mass=$springMass, stiffness=$springStiffness, ratio=$springRatio');
    debugPrint('Image Cache: $imageCacheSize images, ${(imageCacheSizeBytes / 1024 / 1024).toStringAsFixed(0)}MB');
    debugPrint('Thumbnail Cache Width: ${thumbnailCacheWidth}px');
    debugPrint('ðŸ†• Cloud Backup Enabled: $enableCloudBackup');
    debugPrint('=====================================');
  }

  /// Get optimized frame time in milliseconds
  double get frameTimeMs => 1000.0 / displayRefreshRate;

  /// Check if configuration is ready for use
  bool get isReady => _isInitialized;

  /// Force re-initialization (useful for testing or config changes)
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }

  /// Get device information for debugging
  Map<String, dynamic> getDeviceInfo() {
    return {
      'refreshRate': displayRefreshRate,
      'isHighRefreshRate': isHighRefreshRate,
      'frameTimeMs': frameTimeMs,
      'optimalCacheExtent': optimalCacheExtent,
      'optimalBatchSize': optimalBatchSize,
      'thumbnailCacheWidth': thumbnailCacheWidth,
      'imageCacheSize': imageCacheSize,
      'imageCacheMB': (imageCacheSizeBytes / 1024 / 1024).round(),
      'enableCloudBackup': enableCloudBackup,
    };
  }

  /// Get optimized spring description for scroll physics
  SpringDescription get optimizedSpringDescription {
    return SpringDescription.withDampingRatio(
      mass: springMass,
      stiffness: springStiffness,
      ratio: springRatio,
    );
  }

  /// Get target frame time for performance monitoring
  Duration get targetFrameTime => Duration(microseconds: (frameTimeMs * 1000).round());

  /// Check if current frame time exceeds target (for performance monitoring)
  bool isFrameTimeSlow(Duration frameTime) {
    return frameTime.inMicroseconds > (targetFrameTime.inMicroseconds * 1.5);
  }
}