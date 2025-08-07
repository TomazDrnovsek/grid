// File: lib/services/performance_monitor.dart
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/painting.dart';
import '../core/app_config.dart';

/// Comprehensive performance monitoring system for real-time metrics tracking
/// Provides frame rate monitoring, memory tracking, and operation timing
/// Optimized for both 60Hz and 120Hz displays with adaptive thresholds
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._internal();
  PerformanceMonitor._internal();

  // Monitoring state
  bool _isMonitoring = false;
  bool _isFrameMonitoringActive = false;

  // Frame performance tracking
  final List<void Function(FramePerformanceData)> _frameCallbacks = [];
  final Queue<FramePerformanceData> _recentFrames = Queue();
  static const int _maxRecentFrames = 100;

  // Operation timing tracking
  final Map<String, List<Duration>> _operationTimings = {};
  final Map<String, DateTime> _activeOperations = {};

  // Performance statistics
  int _totalFrames = 0;
  int _slowFrames = 0;
  Duration _totalFrameTime = Duration.zero;
  DateTime? _monitoringStartTime;

  // Memory tracking
  Timer? _memoryTimer;
  final Queue<MemorySnapshot> _memoryHistory = Queue();
  static const int _maxMemoryHistory = 50;

  // Performance thresholds (adaptive based on refresh rate)
  late double _targetFrameTimeMs;
  late double _slowFrameThresholdMs;
  late double _criticalFrameThresholdMs;

  /// Initialize performance monitoring with device-specific thresholds
  void initialize() {
    try {
      // Get device-specific performance targets from AppConfig
      final config = AppConfig();
      if (!config.isReady) {
        if (kDebugMode) {
          debugPrint('⚠️ PerformanceMonitor: AppConfig not ready, using fallback thresholds');
        }
        _setFallbackThresholds();
      } else {
        _setOptimizedThresholds(config);
      }

      if (kDebugMode) {
        debugPrint('PerformanceMonitor initialized:');
        debugPrint('  Target frame time: ${_targetFrameTimeMs.toStringAsFixed(1)}ms');
        debugPrint('  Slow frame threshold: ${_slowFrameThresholdMs.toStringAsFixed(1)}ms');
        debugPrint('  Critical frame threshold: ${_criticalFrameThresholdMs.toStringAsFixed(1)}ms');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing PerformanceMonitor: $e');
      }
      _setFallbackThresholds();
    }
  }

  /// Set optimized thresholds based on device capabilities
  void _setOptimizedThresholds(AppConfig config) {
    _targetFrameTimeMs = config.frameTimeMs;
    _slowFrameThresholdMs = _targetFrameTimeMs * 1.5; // 1.5x target
    _criticalFrameThresholdMs = _targetFrameTimeMs * 2.0; // 2x target
  }

  /// Set fallback thresholds for 60Hz displays
  void _setFallbackThresholds() {
    _targetFrameTimeMs = 16.67; // 60Hz
    _slowFrameThresholdMs = 25.0; // ~40fps
    _criticalFrameThresholdMs = 33.33; // ~30fps
  }

  /// Start comprehensive performance monitoring
  void startMonitoring() {
    if (_isMonitoring) {
      if (kDebugMode) {
        debugPrint('PerformanceMonitor already running');
      }
      return;
    }

    try {
      _isMonitoring = true;
      _monitoringStartTime = DateTime.now();

      // Start frame performance monitoring
      _startFrameMonitoring();

      // Start memory monitoring
      _startMemoryMonitoring();

      if (kDebugMode) {
        debugPrint('🚀 PerformanceMonitor started');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting PerformanceMonitor: $e');
      }
      _isMonitoring = false;
    }
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;

    try {
      _isMonitoring = false;

      // Stop frame monitoring
      if (_isFrameMonitoringActive) {
        SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
        _isFrameMonitoringActive = false;
      }

      // Stop memory monitoring
      _memoryTimer?.cancel();
      _memoryTimer = null;

      if (kDebugMode) {
        debugPrint('🛑 PerformanceMonitor stopped');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping PerformanceMonitor: $e');
      }
    }
  }

  /// Start frame performance monitoring with 120Hz awareness
  void _startFrameMonitoring() {
    if (_isFrameMonitoringActive) return;

    try {
      SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
      _isFrameMonitoringActive = true;
      if (kDebugMode) {
        debugPrint('Frame monitoring active');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting frame monitoring: $e');
      }
    }
  }

  /// Handle frame timing data with adaptive thresholds
  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_isMonitoring) return;

    try {
      for (final timing in timings) {
        final frameData = _processFrameTiming(timing);

        // Track frame statistics
        _totalFrames++;
        _totalFrameTime += frameData.totalDuration;

        if (frameData.isSlow) {
          _slowFrames++;
        }

        // Store recent frame data
        _recentFrames.add(frameData);
        if (_recentFrames.length > _maxRecentFrames) {
          _recentFrames.removeFirst();
        }

        // Notify callbacks
        for (final callback in _frameCallbacks) {
          try {
            callback(frameData);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error in frame callback: $e');
            }
          }
        }

        // Log performance issues
        if (frameData.isCritical && kDebugMode) {
          _logSlowFrame(frameData);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error processing frame timings: $e');
      }
    }
  }

  /// Process individual frame timing data
  FramePerformanceData _processFrameTiming(FrameTiming timing) {
    final totalMs = timing.totalSpan.inMicroseconds / 1000.0;
    final buildMs = timing.buildDuration.inMicroseconds / 1000.0;
    final rasterMs = timing.rasterDuration.inMicroseconds / 1000.0;

    return FramePerformanceData(
      totalDuration: timing.totalSpan,
      buildDuration: timing.buildDuration,
      rasterDuration: timing.rasterDuration,
      totalMs: totalMs,
      buildMs: buildMs,
      rasterMs: rasterMs,
      isSlow: totalMs > _slowFrameThresholdMs,
      isCritical: totalMs > _criticalFrameThresholdMs,
      timestamp: DateTime.now(),
    );
  }

  /// Log slow frame information for debugging
  void _logSlowFrame(FramePerformanceData frame) {
    if (!kDebugMode) return;

    debugPrint('🐌 Slow frame detected (${frame.totalMs.toStringAsFixed(1)}ms):');
    debugPrint('  Target: ${_targetFrameTimeMs.toStringAsFixed(1)}ms');
    debugPrint('  Build: ${frame.buildMs.toStringAsFixed(1)}ms');
    debugPrint('  Raster: ${frame.rasterMs.toStringAsFixed(1)}ms');
    debugPrint('  Frames dropped: ${(frame.totalMs / _targetFrameTimeMs - 1).round()}');
  }

  /// Start memory monitoring with periodic snapshots
  void _startMemoryMonitoring() {
    _memoryTimer?.cancel();

    // Take memory snapshots every 5 seconds
    _memoryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _takeMemorySnapshot();
    });

    // Take initial snapshot
    _takeMemorySnapshot();
  }

  /// Take memory snapshot and store in history
  void _takeMemorySnapshot() {
    try {
      // Get memory info from various sources
      final imageCache = PaintingBinding.instance.imageCache;
      final vmMemory = _getVMMemoryUsage();

      final snapshot = MemorySnapshot(
        timestamp: DateTime.now(),
        imageCacheSize: imageCache.currentSize,
        imageCacheSizeBytes: imageCache.currentSizeBytes,
        imageCacheMaxSize: imageCache.maximumSize,
        imageCacheMaxSizeBytes: imageCache.maximumSizeBytes,
        vmMemoryMB: vmMemory,
      );

      _memoryHistory.add(snapshot);
      if (_memoryHistory.length > _maxMemoryHistory) {
        _memoryHistory.removeFirst();
      }

      // Log memory warnings
      if (snapshot.isImageCacheNearLimit && kDebugMode) {
        debugPrint('⚠️ Image cache near limit: ${snapshot.imageCacheUsagePercent.toStringAsFixed(1)}%');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error taking memory snapshot: $e');
      }
    }
  }

  /// Get VM memory usage (approximate)
  double _getVMMemoryUsage() {
    try {
      // This is an approximation - exact memory tracking requires platform channels
      return 0.0; // Would need platform-specific implementation
    } catch (e) {
      return 0.0;
    }
  }

  /// Start timing an operation
  void startOperation(String operationName) {
    try {
      _activeOperations[operationName] = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting operation timing: $e');
      }
    }
  }

  /// End timing an operation and record duration
  void endOperation(String operationName) {
    try {
      final startTime = _activeOperations.remove(operationName);
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);

        _operationTimings.putIfAbsent(operationName, () => []);
        _operationTimings[operationName]!.add(duration);

        // Keep only recent timings
        if (_operationTimings[operationName]!.length > 50) {
          _operationTimings[operationName]!.removeAt(0);
        }

        // Log slow operations
        if (duration.inMilliseconds > 100 && kDebugMode) {
          debugPrint('⏱️ Slow operation: $operationName took ${duration.inMilliseconds}ms');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error ending operation timing: $e');
      }
    }
  }

  /// Add frame performance callback
  void addFrameCallback(void Function(FramePerformanceData) callback) {
    _frameCallbacks.add(callback);
  }

  /// Remove frame performance callback
  void removeFrameCallback(void Function(FramePerformanceData) callback) {
    _frameCallbacks.remove(callback);
  }

  /// Get current performance statistics
  PerformanceStatistics getStatistics() {
    try {
      final currentTime = DateTime.now();
      final monitoringDuration = _monitoringStartTime != null
          ? currentTime.difference(_monitoringStartTime!)
          : Duration.zero;

      final avgFrameTime = _totalFrames > 0
          ? _totalFrameTime.inMicroseconds / _totalFrames / 1000.0
          : 0.0;

      final frameDropRate = _totalFrames > 0
          ? _slowFrames / _totalFrames
          : 0.0;

      final currentFPS = avgFrameTime > 0
          ? 1000.0 / avgFrameTime
          : 0.0;

      return PerformanceStatistics(
        isMonitoring: _isMonitoring,
        monitoringDuration: monitoringDuration,
        totalFrames: _totalFrames,
        slowFrames: _slowFrames,
        avgFrameTimeMs: avgFrameTime,
        currentFPS: currentFPS,
        frameDropRate: frameDropRate,
        targetFrameTimeMs: _targetFrameTimeMs,
        recentFramesCount: _recentFrames.length,
        memorySnapshotsCount: _memoryHistory.length,
        activeOperationsCount: _activeOperations.length,
        trackedOperationsCount: _operationTimings.length,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting performance statistics: $e');
      }
      return PerformanceStatistics.empty();
    }
  }

  /// Get operation timing statistics
  Map<String, OperationStats> getOperationStats() {
    try {
      final stats = <String, OperationStats>{};

      for (final entry in _operationTimings.entries) {
        final durations = entry.value;
        if (durations.isNotEmpty) {
          durations.sort();

          final avgMs = durations.map((d) => d.inMicroseconds).reduce((a, b) => a + b) / durations.length / 1000.0;
          final medianMs = durations[durations.length ~/ 2].inMicroseconds / 1000.0;
          final maxMs = durations.last.inMicroseconds / 1000.0;
          final minMs = durations.first.inMicroseconds / 1000.0;

          stats[entry.key] = OperationStats(
            operationName: entry.key,
            callCount: durations.length,
            avgDurationMs: avgMs,
            medianDurationMs: medianMs,
            maxDurationMs: maxMs,
            minDurationMs: minMs,
          );
        }
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting operation stats: $e');
      }
      return {};
    }
  }

  /// Get recent memory snapshots
  List<MemorySnapshot> getRecentMemorySnapshots() {
    return List.from(_memoryHistory);
  }

  /// Get recent frame performance data
  List<FramePerformanceData> getRecentFrames() {
    return List.from(_recentFrames);
  }

  /// Print comprehensive performance report
  void printPerformanceReport() {
    if (!kDebugMode) return;

    try {
      final stats = getStatistics();
      final opStats = getOperationStats();

      debugPrint('═══════════════════════════════════════');
      debugPrint('         PERFORMANCE REPORT           ');
      debugPrint('═══════════════════════════════════════');
      debugPrint('Monitoring Duration: ${stats.monitoringDuration.inSeconds}s');
      debugPrint('Target Frame Time: ${stats.targetFrameTimeMs.toStringAsFixed(1)}ms');
      debugPrint('');
      debugPrint('📊 FRAME PERFORMANCE:');
      debugPrint('  Total Frames: ${stats.totalFrames}');
      debugPrint('  Slow Frames: ${stats.slowFrames}');
      debugPrint('  Frame Drop Rate: ${(stats.frameDropRate * 100).toStringAsFixed(1)}%');
      debugPrint('  Average Frame Time: ${stats.avgFrameTimeMs.toStringAsFixed(1)}ms');
      debugPrint('  Current FPS: ${stats.currentFPS.toStringAsFixed(1)}');
      debugPrint('');

      if (_memoryHistory.isNotEmpty) {
        final latestMemory = _memoryHistory.last;
        debugPrint('💾 MEMORY USAGE:');
        debugPrint('  Image Cache: ${latestMemory.imageCacheSize}/${latestMemory.imageCacheMaxSize} images');
        debugPrint('  Cache Memory: ${(latestMemory.imageCacheSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB/${(latestMemory.imageCacheMaxSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB');
        debugPrint('  Cache Usage: ${latestMemory.imageCacheUsagePercent.toStringAsFixed(1)}%');
        debugPrint('');
      }

      if (opStats.isNotEmpty) {
        debugPrint('⏱️ OPERATION TIMINGS:');
        for (final op in opStats.values) {
          debugPrint('  ${op.operationName}:');
          debugPrint('    Calls: ${op.callCount}');
          debugPrint('    Avg: ${op.avgDurationMs.toStringAsFixed(1)}ms');
          debugPrint('    Median: ${op.medianDurationMs.toStringAsFixed(1)}ms');
          debugPrint('    Max: ${op.maxDurationMs.toStringAsFixed(1)}ms');
        }
        debugPrint('');
      }

      debugPrint('═══════════════════════════════════════');

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error printing performance report: $e');
      }
    }
  }

  /// Clear all performance data
  void clearData() {
    try {
      _recentFrames.clear();
      _memoryHistory.clear();
      _operationTimings.clear();
      _activeOperations.clear();
      _totalFrames = 0;
      _slowFrames = 0;
      _totalFrameTime = Duration.zero;
      _monitoringStartTime = DateTime.now();

      if (kDebugMode) {
        debugPrint('Performance data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing performance data: $e');
      }
    }
  }
}

/// Frame performance data structure
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
}

/// Memory snapshot data structure
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

  double get imageCacheUsagePercent =>
      imageCacheMaxSizeBytes > 0 ? (imageCacheSizeBytes / imageCacheMaxSizeBytes * 100) : 0.0;

  bool get isImageCacheNearLimit => imageCacheUsagePercent > 80.0;
}

/// Performance statistics summary
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

/// Operation timing statistics
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
}