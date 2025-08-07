// File: lib/services/image_cache_service.dart
import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../core/app_config.dart';

/// ENHANCED: Advanced image cache management service with aggressive memory control
/// FIXES: 99% memory usage (346MB/350MB) with only 63 images (5.5MB per image)
/// TARGETS: <80% memory usage, <2MB per image average
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // LRU tracking for smart eviction
  final LinkedHashMap<String, CacheEntry> _accessHistory = LinkedHashMap();
  final Map<String, int> _accessCounts = {};
  final Set<String> _preloadingQueue = {};

  // ENHANCED: Aggressive cache statistics and monitoring
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _evictions = 0;
  int _memoryPressureEvents = 0;
  int _aggressiveCleanups = 0;
  DateTime? _lastCleanup;

  bool _isInitialized = false;
  bool _memoryPressureMode = false;

  // ENHANCED: More aggressive memory thresholds
  static const double _memoryWarningThreshold = 0.70; // 70% instead of 80%
  static const double _memoryCriticalThreshold = 0.85; // 85% instead of 90%
  static const double _memoryEmergencyThreshold = 0.95; // 95%

  /// ENHANCED: Configure cache with aggressive memory management for 79-image grid
  void configureCache() {
    if (_isInitialized) {
      debugPrint('ImageCacheService already configured');
      return;
    }

    try {
      final imageCache = PaintingBinding.instance.imageCache;

      // REDUCED: More conservative cache limits to prevent 99% usage
      final config = AppConfig();

      // FIXED: Significantly reduced cache sizes to prevent memory crisis
      final cacheSize = config.isHighRefreshRate ? 120 : 100; // Reduced from 250→120, 200→100
      final cacheSizeBytes = config.isHighRefreshRate
          ? 200 * 1024 * 1024  // Reduced from 350MB → 200MB for high refresh rate
          : 150 * 1024 * 1024; // Reduced from 300MB → 150MB for standard

      // Configure cache limits
      imageCache.maximumSize = cacheSize;
      imageCache.maximumSizeBytes = cacheSizeBytes;

      // ENHANCED: Setup aggressive memory pressure handling
      _setupAggressiveMemoryHandling();

      _isInitialized = true;

      debugPrint('🔧 Enhanced ImageCacheService configured:');
      debugPrint('  Max images: $cacheSize (REDUCED)');
      debugPrint('  Max memory: ${(cacheSizeBytes / 1024 / 1024).round()}MB (REDUCED)');
      debugPrint('  High refresh rate: ${config.isHighRefreshRate}');
      debugPrint('  Memory thresholds: Warning ${(_memoryWarningThreshold * 100)}%, Critical ${(_memoryCriticalThreshold * 100)}%');

    } catch (e) {
      debugPrint('Error configuring Enhanced ImageCacheService: $e');
      // Fallback to basic configuration
      _configureFallbackCache();
      _isInitialized = true;
    }
  }

  /// ENHANCED: Setup aggressive memory pressure handling
  void _setupAggressiveMemoryHandling() {
    // More frequent cleanup - every 30 seconds instead of 2 minutes
    _scheduleAggressiveCleanup();
  }

  /// ENHANCED: Schedule frequent aggressive cache cleanup
  void _scheduleAggressiveCleanup() {
    Future.delayed(const Duration(seconds: 30), () {
      if (_isInitialized) {
        _performAggressiveMaintenanceCleanup();
        _scheduleAggressiveCleanup(); // Reschedule
      }
    });
  }

  /// ENHANCED: Fallback cache configuration with conservative limits
  void _configureFallbackCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = 80;  // Reduced from 200
    imageCache.maximumSizeBytes = 120 * 1024 * 1024; // Reduced from 300MB → 120MB
    debugPrint('Enhanced ImageCacheService: Using conservative fallback configuration');
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

      // ENHANCED: Immediate memory check after access
      _checkMemoryPressureImmediate();

      // Trim access history if it gets too large
      if (_accessHistory.length > 300) { // Reduced from 500
        _trimAccessHistory();
      }

    } catch (e) {
      debugPrint('Error tracking image access: $e');
    }
  }

  /// ENHANCED: Immediate memory pressure check
  void _checkMemoryPressureImmediate() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final usageRatio = imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

      if (usageRatio > _memoryEmergencyThreshold) {
        // EMERGENCY: 95%+ usage
        debugPrint('🚨 MEMORY EMERGENCY: ${(usageRatio * 100).toStringAsFixed(1)}% usage');
        _handleEmergencyMemoryPressure();
      } else if (usageRatio > _memoryCriticalThreshold) {
        // CRITICAL: 85%+ usage
        debugPrint('🔥 MEMORY CRITICAL: ${(usageRatio * 100).toStringAsFixed(1)}% usage');
        _handleCriticalMemoryPressure();
      } else if (usageRatio > _memoryWarningThreshold) {
        // WARNING: 70%+ usage
        debugPrint('⚠️ MEMORY WARNING: ${(usageRatio * 100).toStringAsFixed(1)}% usage');
        _handleMemoryWarning();
      }

    } catch (e) {
      debugPrint('Error in immediate memory check: $e');
    }
  }

  /// ENHANCED: Emergency memory pressure (95%+) - aggressive eviction
  void _handleEmergencyMemoryPressure() {
    try {
      _memoryPressureEvents++;
      _memoryPressureMode = true;

      final imageCache = PaintingBinding.instance.imageCache;

      // AGGRESSIVE: Clear 60% of cache immediately
      final targetEvictions = (imageCache.currentSize * 0.6).round();
      _evictLeastRecentlyUsed(targetEvictions);

      debugPrint('🚨 Emergency cleanup: Evicted $targetEvictions images');

    } catch (e) {
      debugPrint('Error in emergency memory pressure handling: $e');
    }
  }

  /// ENHANCED: Critical memory pressure (85%+) - significant eviction
  void _handleCriticalMemoryPressure() {
    try {
      _memoryPressureEvents++;

      final imageCache = PaintingBinding.instance.imageCache;

      // SIGNIFICANT: Clear 40% of cache
      final targetEvictions = (imageCache.currentSize * 0.4).round();
      _evictLeastRecentlyUsed(targetEvictions);

      debugPrint('🔥 Critical cleanup: Evicted $targetEvictions images');

    } catch (e) {
      debugPrint('Error in critical memory pressure handling: $e');
    }
  }

  /// ENHANCED: Memory warning (70%+) - moderate eviction
  void _handleMemoryWarning() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;

      // MODERATE: Clear 25% of cache
      final targetEvictions = (imageCache.currentSize * 0.25).round();
      _evictLeastRecentlyUsed(targetEvictions);

      debugPrint('⚠️ Warning cleanup: Evicted $targetEvictions images');

    } catch (e) {
      debugPrint('Error in memory warning handling: $e');
    }
  }

  /// ENHANCED: Evict least recently used images
  void _evictLeastRecentlyUsed(int count) {
    try {
      if (count <= 0) return;

      // Sort access history by least recently used
      final sortedEntries = _accessHistory.entries.toList();
      sortedEntries.sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

      // Evict least recently used
      final toEvict = sortedEntries.take(count).map((e) => e.key).toList();

      for (final imagePath in toEvict) {
        try {
          final imageProvider = FileImage(File(imagePath));
          final imageCache = PaintingBinding.instance.imageCache;
          imageCache.evict(imageProvider);

          // Remove from tracking
          _accessHistory.remove(imagePath);
          _accessCounts.remove(imagePath);
          _evictions++;

        } catch (e) {
          debugPrint('Error evicting $imagePath: $e');
        }
      }

      debugPrint('LRU evicted: ${toEvict.length} images');

    } catch (e) {
      debugPrint('Error in LRU eviction: $e');
    }
  }

  /// Record cache miss for statistics
  void trackCacheMiss(String imagePath) {
    if (!_isInitialized) return;
    _cacheMisses++;
  }

  /// ENHANCED: Preload with immediate memory check
  Future<void> preloadImages(List<String> imagePaths, {int priority = 0}) async {
    if (!_isInitialized || _memoryPressureMode) return;

    // ENHANCED: Check memory before preloading
    final imageCache = PaintingBinding.instance.imageCache;
    final usageRatio = imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

    if (usageRatio > _memoryWarningThreshold) {
      debugPrint('Skipping preload - memory usage at ${(usageRatio * 100).toStringAsFixed(1)}%');
      return;
    }

    try {
      // Limit concurrent preloading more aggressively
      const maxConcurrentPreloads = 3; // Reduced from 5
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
      debugPrint('Error in enhanced preloadImages: $e');
    }
  }

  /// Preload a single image with memory checks
  Future<void> _preloadImage(String imagePath) async {
    try {
      // Double-check memory before loading
      final imageCache = PaintingBinding.instance.imageCache;
      final usageRatio = imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

      if (usageRatio > _memoryCriticalThreshold) {
        debugPrint('Aborting preload - memory critical');
        return;
      }

      final file = File(imagePath);
      if (!await file.exists()) return;

      final imageProvider = FileImage(file);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);

      // Force image into cache with timeout
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
      await completer.future.timeout(const Duration(seconds: 3)); // Reduced timeout

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

  /// ENHANCED: Aggressive cache cleanup based on LRU and memory pressure
  void performSmartCleanup() {
    if (!_isInitialized) return;

    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final usageRatio = imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

      // ENHANCED: More aggressive cleanup thresholds
      if (usageRatio > _memoryWarningThreshold) {
        final now = DateTime.now();
        final candidates = <String>[];

        // Find LRU candidates for eviction with more aggressive criteria
        for (final entry in _accessHistory.entries) {
          final age = now.difference(entry.value.lastAccessed);
          final accessCount = entry.value.accessCount;

          // ENHANCED: More aggressive eviction criteria
          if (age.inMinutes > 15 && accessCount < 5) { // Reduced from 30 min, 3 access
            candidates.add(entry.key);
          }
        }

        // Sort by least recently used
        candidates.sort((a, b) {
          final aEntry = _accessHistory[a]!;
          final bEntry = _accessHistory[b]!;
          return aEntry.lastAccessed.compareTo(bEntry.lastAccessed);
        });

        // ENHANCED: Evict more aggressively based on memory pressure
        final evictPercentage = usageRatio > _memoryCriticalThreshold ? 0.5 : 0.3;
        final evictCount = (candidates.length * evictPercentage).ceil();
        final toEvict = candidates.take(evictCount).toList();

        if (toEvict.isNotEmpty) {
          evictImages(toEvict);
          _aggressiveCleanups++;
          debugPrint('🧹 Aggressive cleanup: evicted ${toEvict.length} images (${(usageRatio * 100).toStringAsFixed(1)}% usage)');
        }
      }

    } catch (e) {
      debugPrint('Error in smart cleanup: $e');
    }
  }

  /// ENHANCED: Aggressive maintenance cleanup
  void _performAggressiveMaintenanceCleanup() {
    try {
      _lastCleanup = DateTime.now();

      // Trim access history more aggressively
      _trimAccessHistory();

      // Perform smart cleanup
      performSmartCleanup();

      // Clean up preloading queue
      _preloadingQueue.clear();

      // Exit memory pressure mode if memory usage is now acceptable
      final imageCache = PaintingBinding.instance.imageCache;
      final usageRatio = imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

      if (_memoryPressureMode && usageRatio < _memoryWarningThreshold) {
        _memoryPressureMode = false;
        debugPrint('✅ Exited memory pressure mode - usage: ${(usageRatio * 100).toStringAsFixed(1)}%');
      }

      if (kDebugMode) {
        debugPrint('🧹 Enhanced maintenance completed - usage: ${(usageRatio * 100).toStringAsFixed(1)}%');
      }

    } catch (e) {
      debugPrint('Error in aggressive maintenance cleanup: $e');
    }
  }

  /// Trim access history more aggressively
  void _trimAccessHistory() {
    try {
      const maxHistorySize = 200; // Reduced from 300

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

  /// Enter memory pressure mode with immediate aggressive cleanup
  void enterMemoryPressureMode() {
    if (_memoryPressureMode) return;

    _memoryPressureMode = true;

    try {
      final imageCache = PaintingBinding.instance.imageCache;

      // ENHANCED: More aggressive cache reduction
      final reducedSize = (imageCache.maximumSize * 0.4).round(); // Reduced to 40%
      final reducedBytes = (imageCache.maximumSizeBytes * 0.4).round(); // Reduced to 40%

      imageCache.maximumSize = reducedSize;
      imageCache.maximumSizeBytes = reducedBytes;

      // Immediate aggressive cleanup
      _handleEmergencyMemoryPressure();

      debugPrint('🚨 Entered AGGRESSIVE memory pressure mode');
      debugPrint('  Reduced cache: $reducedSize images, ${(reducedBytes / 1024 / 1024).round()}MB');

    } catch (e) {
      debugPrint('Error entering memory pressure mode: $e');
    }
  }

  /// Exit memory pressure mode and restore cache limits
  void exitMemoryPressureMode() {
    if (!_memoryPressureMode) return;

    _memoryPressureMode = false;

    try {
      // Restore original cache configuration (but more conservative)
      configureCache();

      debugPrint('✅ Exited memory pressure mode - cache restored to conservative limits');

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
      _memoryPressureEvents = 0;
      _aggressiveCleanups = 0;

      debugPrint('🧹 Enhanced image cache cleared completely');

    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Get enhanced cache statistics
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
        memoryPressureEvents: 0,
        aggressiveCleanups: 0,
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
        memoryPressureEvents: _memoryPressureEvents,
        aggressiveCleanups: _aggressiveCleanups,
      );

    } catch (e) {
      debugPrint('Error getting enhanced cache statistics: $e');
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
        memoryPressureEvents: _memoryPressureEvents,
        aggressiveCleanups: _aggressiveCleanups,
      );
    }
  }

  /// Print enhanced cache statistics
  void printStatistics() {
    if (!kDebugMode) return;

    final stats = getStatistics();
    final usageRatio = stats.maximumSizeBytes > 0
        ? stats.currentSizeBytes / stats.maximumSizeBytes
        : 0.0;
    final avgSizeMB = stats.currentSize > 0
        ? (stats.currentSizeBytes / stats.currentSize / 1024 / 1024)
        : 0.0;

    debugPrint('=== ENHANCED Image Cache Statistics ===');
    debugPrint('Initialized: ${stats.isInitialized}');
    debugPrint('Current Size: ${stats.currentSize}/${stats.maximumSize} images');
    debugPrint('Memory Usage: ${(stats.currentSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB/${(stats.maximumSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB (${(usageRatio * 100).toStringAsFixed(1)}%)');
    debugPrint('Average Size: ${avgSizeMB.toStringAsFixed(1)}MB per image');
    debugPrint('Cache Hits: ${stats.cacheHits}');
    debugPrint('Cache Misses: ${stats.cacheMisses}');
    debugPrint('Hit Rate: ${(stats.hitRate * 100).toStringAsFixed(1)}%');
    debugPrint('Evictions: ${stats.evictions}');
    debugPrint('Memory Pressure Events: ${stats.memoryPressureEvents}');
    debugPrint('Aggressive Cleanups: ${stats.aggressiveCleanups}');
    debugPrint('Access History: ${stats.accessHistorySize} entries');
    debugPrint('Memory Pressure Mode: ${stats.memoryPressureMode}');
    if (stats.lastCleanup != null) {
      debugPrint('Last Cleanup: ${stats.lastCleanup}');
    }
    debugPrint('=======================================');
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

/// ENHANCED: Data class for cache statistics with memory pressure metrics
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
  final int memoryPressureEvents;
  final int aggressiveCleanups;

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
    this.memoryPressureEvents = 0,
    this.aggressiveCleanups = 0,
  });
}