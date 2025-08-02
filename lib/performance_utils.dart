// File: lib/performance_utils.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Utilities for optimizing performance on high refresh rate displays
class PerformanceUtils {

  /// Detect if the device has a high refresh rate display (90Hz+)
  static bool get isHighRefreshRateDevice {
    try {
      final refreshRate = SchedulerBinding.instance.platformDispatcher.displays.first.refreshRate;
      return refreshRate > 90;
    } catch (e) {
      // Fallback to false if detection fails
      return false;
    }
  }

  /// Get the actual refresh rate of the primary display
  static double get displayRefreshRate {
    try {
      return SchedulerBinding.instance.platformDispatcher.displays.first.refreshRate;
    } catch (e) {
      // Fallback to 60Hz if detection fails
      return 60.0;
    }
  }

  /// Get optimized animation duration based on refresh rate
  /// Returns duration that's a multiple of frame time for smooth animations
  static Duration getOptimizedAnimationDuration({
    Duration? lowRefreshDuration,
    Duration? highRefreshDuration,
  }) {
    final isHighRefresh = isHighRefreshRateDevice;

    if (isHighRefresh) {
      return highRefreshDuration ?? const Duration(milliseconds: 200);
    } else {
      return lowRefreshDuration ?? const Duration(milliseconds: 300);
    }
  }

  /// Get optimized batch size for processing operations
  /// Smaller batches for high refresh rate to maintain frame rate
  static int getOptimizedBatchSize({
    int? lowRefreshBatchSize,
    int? highRefreshBatchSize,
  }) {
    final isHighRefresh = isHighRefreshRateDevice;

    if (isHighRefresh) {
      return highRefreshBatchSize ?? 5;
    } else {
      return lowRefreshBatchSize ?? 10;
    }
  }

  /// Get optimized delay between operations
  /// Shorter delays for high refresh rate devices
  static Duration getOptimizedDelay({
    Duration? lowRefreshDelay,
    Duration? highRefreshDelay,
  }) {
    final isHighRefresh = isHighRefreshRateDevice;

    if (isHighRefresh) {
      return highRefreshDelay ?? Duration.zero;
    } else {
      return lowRefreshDelay ?? const Duration(milliseconds: 1);
    }
  }

  /// Calculate frame time in milliseconds for the current display
  static double get frameTimeMs {
    return 1000.0 / displayRefreshRate;
  }

  /// Get the ideal cache extent for smooth scrolling based on refresh rate
  static double getOptimizedCacheExtent() {
    final isHighRefresh = isHighRefreshRateDevice;
    return isHighRefresh ? 2000.0 : 1000.0;
  }

  /// Performance monitoring utility for debugging frame drops
  static void startPerformanceMonitoring() {
    if (kDebugMode) {
      SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
        for (final timing in timings) {
          final frameTime = timing.totalSpan.inMicroseconds / 1000.0;
          final targetFrameTime = frameTimeMs;

          if (frameTime > targetFrameTime * 1.5) {
            debugPrint('Performance Warning: Frame took ${frameTime.toStringAsFixed(1)}ms '
                '(target: ${targetFrameTime.toStringAsFixed(1)}ms) '
                'on ${displayRefreshRate.toStringAsFixed(0)}Hz display');
          }
        }
      });
    }
  }

  /// Stop performance monitoring
  static void stopPerformanceMonitoring() {
    if (kDebugMode) {
      SchedulerBinding.instance.removeTimingsCallback((List<FrameTiming> timings) {});
    }
  }

  /// Get device information for debugging
  static Map<String, dynamic> getDevicePerformanceInfo() {
    return {
      'refreshRate': displayRefreshRate,
      'isHighRefreshRate': isHighRefreshRateDevice,
      'targetFrameTime': frameTimeMs,
      'optimizedCacheExtent': getOptimizedCacheExtent(),
      'optimizedBatchSize': getOptimizedBatchSize(),
    };
  }

  /// Print performance info to debug console
  static void printPerformanceInfo() {
    if (kDebugMode) {
      final info = getDevicePerformanceInfo();
      debugPrint('=== Performance Configuration ===');
      debugPrint('Display Refresh Rate: ${info['refreshRate']}Hz');
      debugPrint('High Refresh Rate Device: ${info['isHighRefreshRate']}');
      debugPrint('Target Frame Time: ${info['targetFrameTime']}ms');
      debugPrint('Optimized Cache Extent: ${info['optimizedCacheExtent']}px');
      debugPrint('Optimized Batch Size: ${info['optimizedBatchSize']} items');
      debugPrint('===============================');
    }
  }
}