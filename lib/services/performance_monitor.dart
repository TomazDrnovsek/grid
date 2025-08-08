// File: lib/services/performance_monitor.dart
import 'package:flutter/foundation.dart';

/// Lightweight no-op performance monitoring system
/// Maintains the exact same API as the full version but with zero overhead
/// Perfect for production builds where monitoring is not needed
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._internal();
  PerformanceMonitor._internal();

  /// Initialize performance monitoring (no-op)
  void initialize() {
    // No-op: No initialization needed
  }

  /// Start comprehensive performance monitoring (no-op)
  void startMonitoring() {
    // No-op: No monitoring started
  }

  /// Stop performance monitoring (no-op)
  void stopMonitoring() {
    // No-op: No monitoring to stop
  }

  /// Start timing an operation (no-op)
  void startOperation(String operationName) {
    // No-op: No timing started
  }

  /// End timing an operation (no-op)
  void endOperation(String operationName) {
    // No-op: No timing to end
  }

  /// Add frame performance callback (no-op)
  void addFrameCallback(void Function(FramePerformanceData) callback) {
    // No-op: No callbacks stored
  }

  /// Remove frame performance callback (no-op)
  void removeFrameCallback(void Function(FramePerformanceData) callback) {
    // No-op: No callbacks to remove
  }

  /// Get current performance statistics (returns default/empty data)
  PerformanceStatistics getStatistics() {
    return PerformanceStatistics.empty();
  }

  /// Get operation timing statistics (returns empty map)
  Map<String, OperationStats> getOperationStats() {
    return {};
  }

  /// Get recent memory snapshots (returns empty list)
  List<MemorySnapshot> getRecentMemorySnapshots() {
    return [];
  }

  /// Get recent frame performance data (returns empty list)
  List<FramePerformanceData> getRecentFrames() {
    return [];
  }

  /// Print comprehensive performance report (no-op in release, minimal in debug)
  void printPerformanceReport() {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('    LIGHTWEIGHT PERFORMANCE MONITOR    ');
      debugPrint('═══════════════════════════════════════');
      debugPrint('Status: Monitoring disabled for performance');
      debugPrint('All monitoring calls are no-op for optimal performance');
      debugPrint('═══════════════════════════════════════');
    }
  }

  /// Clear all performance data (no-op)
  void clearData() {
    // No-op: No data to clear
  }
}

/// Lightweight frame performance data structure
class FramePerformanceData {
  final Duration totalDuration;
  final Duration buildDuration;
  final Duration rasterDuration;
  final double totalMs;
  final double buildMs;
  final double rasterMs;
  final bool isSlow;
  final bool isCritical;
  final DateTime timestamp;

  const FramePerformanceData({
    required this.totalDuration,
    required this.buildDuration,
    required this.rasterDuration,
    required this.totalMs,
    required this.buildMs,
    required this.rasterMs,
    required this.isSlow,
    required this.isCritical,
    required this.timestamp,
  });

  /// Create empty/default frame data
  factory FramePerformanceData.empty() => FramePerformanceData(
    totalDuration: Duration.zero,
    buildDuration: Duration.zero,
    rasterDuration: Duration.zero,
    totalMs: 0.0,
    buildMs: 0.0,
    rasterMs: 0.0,
    isSlow: false,
    isCritical: false,
    timestamp: DateTime.now(),
  );
}

/// Lightweight memory snapshot data structure
class MemorySnapshot {
  final DateTime timestamp;
  final int imageCacheSize;
  final int imageCacheSizeBytes;
  final int imageCacheMaxSize;
  final int imageCacheMaxSizeBytes;
  final double vmMemoryMB;

  const MemorySnapshot({
    required this.timestamp,
    required this.imageCacheSize,
    required this.imageCacheSizeBytes,
    required this.imageCacheMaxSize,
    required this.imageCacheMaxSizeBytes,
    required this.vmMemoryMB,
  });

  double get imageCacheUsagePercent => 0.0;
  bool get isImageCacheNearLimit => false;

  /// Create empty/default memory snapshot
  factory MemorySnapshot.empty() => MemorySnapshot(
    timestamp: DateTime.now(),
    imageCacheSize: 0,
    imageCacheSizeBytes: 0,
    imageCacheMaxSize: 0,
    imageCacheMaxSizeBytes: 0,
    vmMemoryMB: 0.0,
  );
}

/// Lightweight performance statistics summary
class PerformanceStatistics {
  final bool isMonitoring;
  final Duration monitoringDuration;
  final int totalFrames;
  final int slowFrames;
  final double avgFrameTimeMs;
  final double currentFPS;
  final double frameDropRate;
  final double targetFrameTimeMs;
  final int recentFramesCount;
  final int memorySnapshotsCount;
  final int activeOperationsCount;
  final int trackedOperationsCount;

  const PerformanceStatistics({
    required this.isMonitoring,
    required this.monitoringDuration,
    required this.totalFrames,
    required this.slowFrames,
    required this.avgFrameTimeMs,
    required this.currentFPS,
    required this.frameDropRate,
    required this.targetFrameTimeMs,
    required this.recentFramesCount,
    required this.memorySnapshotsCount,
    required this.activeOperationsCount,
    required this.trackedOperationsCount,
  });

  /// Create empty/default performance statistics
  factory PerformanceStatistics.empty() => const PerformanceStatistics(
    isMonitoring: false,
    monitoringDuration: Duration.zero,
    totalFrames: 0,
    slowFrames: 0,
    avgFrameTimeMs: 0.0,
    currentFPS: 0.0,
    frameDropRate: 0.0,
    targetFrameTimeMs: 16.67,
    recentFramesCount: 0,
    memorySnapshotsCount: 0,
    activeOperationsCount: 0,
    trackedOperationsCount: 0,
  );
}

/// Lightweight operation timing statistics
class OperationStats {
  final String operationName;
  final int callCount;
  final double avgDurationMs;
  final double medianDurationMs;
  final double maxDurationMs;
  final double minDurationMs;

  const OperationStats({
    required this.operationName,
    required this.callCount,
    required this.avgDurationMs,
    required this.medianDurationMs,
    required this.maxDurationMs,
    required this.minDurationMs,
  });

  /// Create empty/default operation stats
  factory OperationStats.empty(String operationName) => OperationStats(
    operationName: operationName,
    callCount: 0,
    avgDurationMs: 0.0,
    medianDurationMs: 0.0,
    maxDurationMs: 0.0,
    minDurationMs: 0.0,
  );
}