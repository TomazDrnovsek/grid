// File: lib/services/image_cache_service.dart
import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../core/app_config.dart';

/// Advanced image cache management service with LRU eviction and smart preloading
/// Integrates with AppConfig performance settings and provides monitoring capabilities
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // LRU tracking for smart eviction
  final LinkedHashMap<String, CacheEntry> _accessHistory = LinkedHashMap();
  final Map<String, int> _accessCounts = {};
  final Set<String> _preloadingQueue = {};

  // Cache statistics
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _evictions = 0;
  DateTime? _lastCleanup;

  bool _isInitialized = false;
  bool _memoryPressureMode = false;

  /// Initialize and configure the image cache with AppConfig settings
  void configureCache() {
    if (_isInitialized) {
      debugPrint('ImageCacheService already configured');
      return;
    }

    try {
      final imageCache = PaintingBinding.instance.imageCache;

      // Use AppConfig settings as foundation
      final config = AppConfig();
      final cacheSize = config.isHighRefreshRate ? 250 : 200; // Slightly higher for high refresh rate
      final cacheSizeBytes = config.isHighRefreshRate
          ? 350 * 1024 * 1024  // 350MB for high refresh rate devices
          : 300 * 1024 * 1024; // 300MB for standard devices

      // Configure cache limits
      imageCache.maximumSize = cacheSize;
      imageCache.maximumSizeBytes = cacheSizeBytes;

      // Setup memory pressure handling
      _setupMemoryPressureHandling();

      _isInitialized = true;

      debugPrint('ImageCacheService configured:');
      debugPrint('  Max images: $cacheSize');
      debugPrint('  Max memory: ${(cacheSizeBytes / 1024 / 1024).round()}MB');
      debugPrint('  High refresh rate: ${config.isHighRefreshRate}');

    } catch (e) {
      debugPrint('Error configuring ImageCacheService: $e');
      // Fallback to basic configuration
      _configureFallbackCache();
      _isInitialized = true;
    }
  }

  /// Setup memory pressure handling for automatic cache management
  void _setupMemoryPressureHandling() {
    // Note: Flutter doesn't have direct memory pressure APIs, but we can monitor
    // cache size and implement proactive cleanup
    _schedulePeriodicCleanup();
  }

  /// Schedule periodic cache cleanup and optimization
  void _schedulePeriodicCleanup() {
    // Perform cleanup every 2 minutes during active use
    Future.delayed(const Duration(minutes: 2), () {
      if (_isInitialized) {
        _performMaintenanceCleanup();
        _schedulePeriodicCleanup(); // Reschedule
      }
    });
  }

  /// Fallback cache configuration if AppConfig fails
  void _configureFallbackCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = 200;
    imageCache.maximumSizeBytes = 300 * 1024 * 1024; // 300MB
    debugPrint('ImageCacheService: Using fallback configuration');
  }

  /// Track image access for LRU management
  void trackImageAccess(String imagePath) {
    if (!_isInitialized) return;

    try {
      final now = DateTime.now();

      // Update access history (LRU tracking)
      _accessHistory.remove(imagePath); // Remove if exists
      _accessHistory[imagePath] = CacheEntry(
        path: imagePath,
        lastAccessed: now,
        accessCount: (_accessCounts[imagePath] ?? 0) + 1,
      );

      // Update access count
      _accessCounts[imagePath] = (_accessCounts[imagePath] ?? 0) + 1;

      // Track cache hit
      _cacheHits++;

      // Trim access history if it gets too large
      if (_accessHistory.length > 500) {
        _trimAccessHistory();
      }

    } catch (e) {
      debugPrint('Error tracking image access: $e');
    }
  }

  /// Record cache miss for statistics
  void trackCacheMiss(String imagePath) {
    if (!_isInitialized) return;
    _cacheMisses++;
  }

  /// Preload images that are likely to be accessed soon
  Future<void> preloadImages(List<String> imagePaths, {int priority = 0}) async {
    if (!_isInitialized || _memoryPressureMode) return;

    try {
      // Limit concurrent preloading to avoid memory pressure
      const maxConcurrentPreloads = 5;
      int activePreloads = 0;

      for (final imagePath in imagePaths) {
        if (activePreloads >= maxConcurrentPreloads) break;
        if (_preloadingQueue.contains(imagePath)) continue;

        _preloadingQueue.add(imagePath);
        activePreloads++;

        // Preload in background without blocking
        _preloadImage(imagePath).catchError((e) {
          debugPrint('Preload failed for $imagePath: $e');
        }).whenComplete(() {
          _preloadingQueue.remove(imagePath);
        });
      }

    } catch (e) {
      debugPrint('Error in preloadImages: $e');
    }
  }

  /// Preload a single image
  Future<void> _preloadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return;

      final imageProvider = FileImage(file);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);

      // Force image into cache
      final completer = Completer<void>();
      late ImageStreamListener listener;

      listener = ImageStreamListener(
            (ImageInfo info, bool synchronousCall) {
          completer.complete();
          imageStream.removeListener(listener);
        },
        onError: (exception, stackTrace) {
          completer.completeError(exception);
          imageStream.removeListener(listener);
        },
      );

      imageStream.addListener(listener);
      await completer.future.timeout(const Duration(seconds: 5));

    } catch (e) {
      // Preload failures are not critical
      debugPrint('Preload timeout/error for $imagePath: $e');
    }
  }

  /// Evict specific image from cache
  void evictImage(String imagePath) {
    if (!_isInitialized) return;

    try {
      final imageProvider = FileImage(File(imagePath));
      final imageCache = PaintingBinding.instance.imageCache;

      imageCache.evict(imageProvider);

      // Remove from tracking
      _accessHistory.remove(imagePath);
      _accessCounts.remove(imagePath);

      _evictions++;

      debugPrint('Evicted image: $imagePath');

    } catch (e) {
      debugPrint('Error evicting image: $e');
    }
  }

  /// Evict multiple images (batch operation)
  void evictImages(List<String> imagePaths) {
    if (!_isInitialized) return;

    try {
      final imageCache = PaintingBinding.instance.imageCache;

      for (final imagePath in imagePaths) {
        try {
          final imageProvider = FileImage(File(imagePath));
          imageCache.evict(imageProvider);

          // Remove from tracking
          _accessHistory.remove(imagePath);
          _accessCounts.remove(imagePath);

          _evictions++;
        } catch (e) {
          debugPrint('Error evicting image $imagePath: $e');
        }
      }

      debugPrint('Batch evicted ${imagePaths.length} images');

    } catch (e) {
      debugPrint('Error in batch eviction: $e');
    }
  }

  /// Perform smart cache cleanup based on LRU and access patterns
  void performSmartCleanup() {
    if (!_isInitialized) return;

    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final currentSize = imageCache.currentSize;
      final maxSize = imageCache.maximumSize;

      // Only clean if we're approaching capacity
      if (currentSize < maxSize * 0.8) return;

      final now = DateTime.now();
      final candidates = <String>[];

      // Find LRU candidates for eviction
      for (final entry in _accessHistory.entries) {
        final age = now.difference(entry.value.lastAccessed);
        final accessCount = entry.value.accessCount;

        // Evict if old and not frequently accessed
        if (age.inMinutes > 30 && accessCount < 3) {
          candidates.add(entry.key);
        }
      }

      // Sort by least recently used
      candidates.sort((a, b) {
        final aEntry = _accessHistory[a]!;
        final bEntry = _accessHistory[b]!;
        return aEntry.lastAccessed.compareTo(bEntry.lastAccessed);
      });

      // Evict up to 25% of candidates to free space
      final evictCount = (candidates.length * 0.25).ceil();
      final toEvict = candidates.take(evictCount).toList();

      if (toEvict.isNotEmpty) {
        evictImages(toEvict);
        debugPrint('Smart cleanup: evicted ${toEvict.length} images');
      }

    } catch (e) {
      debugPrint('Error in smart cleanup: $e');
    }
  }

  /// Perform maintenance cleanup (called periodically)
  void _performMaintenanceCleanup() {
    try {
      _lastCleanup = DateTime.now();

      // Trim access history
      _trimAccessHistory();

      // Perform smart cleanup if needed
      performSmartCleanup();

      // Clean up preloading queue
      _preloadingQueue.clear();

      if (kDebugMode) {
        debugPrint('Cache maintenance completed');
      }

    } catch (e) {
      debugPrint('Error in maintenance cleanup: $e');
    }
  }

  /// Trim access history to prevent memory buildup
  void _trimAccessHistory() {
    try {
      const maxHistorySize = 300;

      if (_accessHistory.length <= maxHistorySize) return;

      // Keep most recently accessed entries
      final entries = _accessHistory.entries.toList();
      entries.sort((a, b) => b.value.lastAccessed.compareTo(a.value.lastAccessed));

      _accessHistory.clear();
      _accessCounts.clear();

      for (final entry in entries.take(maxHistorySize)) {
        _accessHistory[entry.key] = entry.value;
        _accessCounts[entry.key] = entry.value.accessCount;
      }

      debugPrint('Trimmed access history to $maxHistorySize entries');

    } catch (e) {
      debugPrint('Error trimming access history: $e');
    }
  }

  /// Enter memory pressure mode (reduce cache aggressiveness)
  void enterMemoryPressureMode() {
    if (_memoryPressureMode) return;

    _memoryPressureMode = true;

    try {
      final imageCache = PaintingBinding.instance.imageCache;

      // Reduce cache size temporarily
      final reducedSize = (imageCache.maximumSize * 0.6).round();
      final reducedBytes = (imageCache.maximumSizeBytes * 0.6).round();

      imageCache.maximumSize = reducedSize;
      imageCache.maximumSizeBytes = reducedBytes;

      // Aggressive cleanup
      performSmartCleanup();

      debugPrint('Entered memory pressure mode');
      debugPrint('  Reduced cache: $reducedSize images, ${(reducedBytes / 1024 / 1024).round()}MB');

    } catch (e) {
      debugPrint('Error entering memory pressure mode: $e');
    }
  }

  /// Exit memory pressure mode (restore normal cache limits)
  void exitMemoryPressureMode() {
    if (!_memoryPressureMode) return;

    _memoryPressureMode = false;

    try {
      // Restore original cache configuration
      configureCache();

      debugPrint('Exited memory pressure mode - cache restored');

    } catch (e) {
      debugPrint('Error exiting memory pressure mode: $e');
    }
  }

  /// Clear entire cache
  void clearCache() {
    if (!_isInitialized) return;

    try {
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.clear();
      imageCache.clearLiveImages();

      // Clear tracking data
      _accessHistory.clear();
      _accessCounts.clear();
      _preloadingQueue.clear();

      // Reset statistics
      _cacheHits = 0;
      _cacheMisses = 0;
      _evictions = 0;

      debugPrint('Image cache cleared completely');

    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Get cache statistics for monitoring
  CacheStatistics getStatistics() {
    if (!_isInitialized) {
      return CacheStatistics(
        isInitialized: false,
        currentSize: 0,
        maximumSize: 0,
        currentSizeBytes: 0,
        maximumSizeBytes: 0,
        cacheHits: 0,
        cacheMisses: 0,
        evictions: 0,
        hitRate: 0.0,
        accessHistorySize: 0,
        memoryPressureMode: false,
      );
    }

    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final totalAccesses = _cacheHits + _cacheMisses;
      final hitRate = totalAccesses > 0 ? _cacheHits / totalAccesses : 0.0;

      return CacheStatistics(
        isInitialized: true,
        currentSize: imageCache.currentSize,
        maximumSize: imageCache.maximumSize,
        currentSizeBytes: imageCache.currentSizeBytes,
        maximumSizeBytes: imageCache.maximumSizeBytes,
        cacheHits: _cacheHits,
        cacheMisses: _cacheMisses,
        evictions: _evictions,
        hitRate: hitRate,
        accessHistorySize: _accessHistory.length,
        memoryPressureMode: _memoryPressureMode,
        lastCleanup: _lastCleanup,
      );

    } catch (e) {
      debugPrint('Error getting cache statistics: $e');
      return CacheStatistics(
        isInitialized: true,
        currentSize: -1,
        maximumSize: -1,
        currentSizeBytes: -1,
        maximumSizeBytes: -1,
        cacheHits: _cacheHits,
        cacheMisses: _cacheMisses,
        evictions: _evictions,
        hitRate: 0.0,
        accessHistorySize: 0,
        memoryPressureMode: false,
      );
    }
  }

  /// Print cache statistics to debug console
  void printStatistics() {
    if (!kDebugMode) return;

    final stats = getStatistics();
    debugPrint('=== Image Cache Statistics ===');
    debugPrint('Initialized: ${stats.isInitialized}');
    debugPrint('Current Size: ${stats.currentSize}/${stats.maximumSize} images');
    debugPrint('Memory Usage: ${(stats.currentSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB/${(stats.maximumSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB');
    debugPrint('Cache Hits: ${stats.cacheHits}');
    debugPrint('Cache Misses: ${stats.cacheMisses}');
    debugPrint('Hit Rate: ${(stats.hitRate * 100).toStringAsFixed(1)}%');
    debugPrint('Evictions: ${stats.evictions}');
    debugPrint('Access History: ${stats.accessHistorySize} entries');
    debugPrint('Memory Pressure Mode: ${stats.memoryPressureMode}');
    if (stats.lastCleanup != null) {
      debugPrint('Last Cleanup: ${stats.lastCleanup}');
    }
    debugPrint('==============================');
  }
}

/// Data class for cache entry tracking
class CacheEntry {
  final String path;
  final DateTime lastAccessed;
  final int accessCount;

  CacheEntry({
    required this.path,
    required this.lastAccessed,
    required this.accessCount,
  });
}

/// Data class for cache statistics
class CacheStatistics {
  final bool isInitialized;
  final int currentSize;
  final int maximumSize;
  final int currentSizeBytes;
  final int maximumSizeBytes;
  final int cacheHits;
  final int cacheMisses;
  final int evictions;
  final double hitRate;
  final int accessHistorySize;
  final bool memoryPressureMode;
  final DateTime? lastCleanup;

  CacheStatistics({
    required this.isInitialized,
    required this.currentSize,
    required this.maximumSize,
    required this.currentSizeBytes,
    required this.maximumSizeBytes,
    required this.cacheHits,
    required this.cacheMisses,
    required this.evictions,
    required this.hitRate,
    required this.accessHistorySize,
    required this.memoryPressureMode,
    this.lastCleanup,
  });
}