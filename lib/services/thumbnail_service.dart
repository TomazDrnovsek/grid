// File: lib/services/thumbnail_service.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../file_utils.dart';
import '../services/performance_monitor.dart';

/// Lazy thumbnail generation service with priority queue
/// Generates thumbnails on-demand to reduce initial load time from 1501ms to <100ms
class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  // Priority queue for thumbnail requests
  final _thumbnailQueue = PriorityQueue<ThumbnailRequest>((a, b) => b.priority.compareTo(a.priority));
  final _processing = <String>{};
  final _completed = <String, File>{};
  final _callbacks = <String, List<Function(File)>>{};

  Timer? _processingTimer;
  bool _isProcessing = false;
  final int _maxConcurrentJobs = 2; // Limit concurrent processing

  /// Request thumbnail generation with priority
  /// Priority: 10 = visible/critical, 5 = above fold, 1 = below fold
  Future<File?> requestThumbnail(String imagePath, {int priority = 5}) async {
    try {
      // Check if already completed
      if (_completed.containsKey(imagePath)) {
        return _completed[imagePath];
      }

      // Check if thumbnail already exists on disk
      final existingThumbnail = await FileUtils.getThumbnailForImage(imagePath);
      if (existingThumbnail != null) {
        _completed[imagePath] = existingThumbnail;
        return existingThumbnail;
      }

      // Check if already processing
      if (_processing.contains(imagePath)) {
        return null; // Will be notified via callback
      }

      // Add to queue
      final request = ThumbnailRequest(
        imagePath: imagePath,
        priority: priority,
        timestamp: DateTime.now(),
      );

      _thumbnailQueue.add(request);
      _startProcessing();

      return null; // Will be generated asynchronously

    } catch (e) {
      debugPrint('Error requesting thumbnail for $imagePath: $e');
      return null;
    }
  }

  /// Register callback for when thumbnail is ready
  void onThumbnailReady(String imagePath, Function(File) callback) {
    _callbacks.putIfAbsent(imagePath, () => []).add(callback);
  }

  /// Start processing queue if not already running
  void _startProcessing() {
    if (_isProcessing || _thumbnailQueue.isEmpty) return;

    _isProcessing = true;
    _processingTimer?.cancel();

    _processingTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _processNext();
    });
  }

  /// Process next item in queue
  Future<void> _processNext() async {
    // Limit concurrent jobs
    if (_processing.length >= _maxConcurrentJobs) return;

    if (_thumbnailQueue.isEmpty) {
      _stopProcessing();
      return;
    }

    final request = _thumbnailQueue.removeFirst();

    // Skip if already processing or completed
    if (_processing.contains(request.imagePath) ||
        _completed.containsKey(request.imagePath)) {
      return;
    }

    // Process in background
    _processThumbnail(request);
  }

  /// Process single thumbnail request
  Future<void> _processThumbnail(ThumbnailRequest request) async {
    _processing.add(request.imagePath);

    try {
      // Start performance monitoring
      PerformanceMonitor.instance.startOperation('lazy_thumbnail_generation');

      debugPrint('🔄 Generating lazy thumbnail: ${request.imagePath} (priority: ${request.priority})');

      // Generate thumbnail using existing FileUtils
      final thumbnailFile = await FileUtils.generateThumbnail(XFile(request.imagePath));

      // Store completed thumbnail
      _completed[request.imagePath] = thumbnailFile;

      // Notify callbacks
      final callbacks = _callbacks.remove(request.imagePath);
      if (callbacks != null) {
        for (final callback in callbacks) {
          try {
            callback(thumbnailFile);
          } catch (e) {
            debugPrint('Error in thumbnail callback: $e');
          }
        }
      }

      // End performance monitoring
      PerformanceMonitor.instance.endOperation('lazy_thumbnail_generation');

      debugPrint('✅ Lazy thumbnail completed: ${thumbnailFile.path}');

    } catch (e) {
      debugPrint('❌ Error generating lazy thumbnail for ${request.imagePath}: $e');
      PerformanceMonitor.instance.endOperation('lazy_thumbnail_generation');
    } finally {
      _processing.remove(request.imagePath);
    }
  }

  /// Stop processing when queue is empty
  void _stopProcessing() {
    _isProcessing = false;
    _processingTimer?.cancel();
    _processingTimer = null;
    debugPrint('Thumbnail processing stopped - queue empty');
  }

  /// Get processing statistics
  ThumbnailServiceStats getStats() {
    return ThumbnailServiceStats(
      queueSize: _thumbnailQueue.length,
      processing: _processing.length,
      completed: _completed.length,
      isProcessing: _isProcessing,
    );
  }

  /// Clear all caches and stop processing (for cleanup)
  void dispose() {
    _processingTimer?.cancel();
    _thumbnailQueue.clear();
    _processing.clear();
    _completed.clear();
    _callbacks.clear();
    _isProcessing = false;
  }

  /// Preload thumbnails for visible range
  void preloadVisibleRange(List<String> imagePaths, int startIndex, int endIndex) {
    try {
      // High priority for visible items
      for (int i = startIndex; i <= endIndex && i < imagePaths.length; i++) {
        requestThumbnail(imagePaths[i], priority: 10);
      }

      // Medium priority for buffer zone (above fold)
      final bufferSize = 10;
      final bufferStart = (startIndex - bufferSize).clamp(0, imagePaths.length - 1);
      final bufferEnd = (endIndex + bufferSize).clamp(0, imagePaths.length - 1);

      for (int i = bufferStart; i < startIndex; i++) {
        requestThumbnail(imagePaths[i], priority: 5);
      }
      for (int i = endIndex + 1; i <= bufferEnd; i++) {
        requestThumbnail(imagePaths[i], priority: 5);
      }

    } catch (e) {
      debugPrint('Error preloading visible range: $e');
    }
  }

  /// Force generate thumbnail immediately (for critical items)
  Future<File?> generateImmediately(String imagePath) async {
    try {
      // Check if already exists
      final existing = await FileUtils.getThumbnailForImage(imagePath);
      if (existing != null) {
        _completed[imagePath] = existing;
        return existing;
      }

      // Generate immediately
      PerformanceMonitor.instance.startOperation('immediate_thumbnail_generation');

      final thumbnailFile = await FileUtils.generateThumbnail(XFile(imagePath));
      _completed[imagePath] = thumbnailFile;

      PerformanceMonitor.instance.endOperation('immediate_thumbnail_generation');

      return thumbnailFile;

    } catch (e) {
      debugPrint('Error generating immediate thumbnail: $e');
      PerformanceMonitor.instance.endOperation('immediate_thumbnail_generation');
      return null;
    }
  }
}

/// Data class for thumbnail requests
class ThumbnailRequest {
  final String imagePath;
  final int priority;
  final DateTime timestamp;

  ThumbnailRequest({
    required this.imagePath,
    required this.priority,
    required this.timestamp,
  });

  @override
  String toString() => 'ThumbnailRequest($imagePath, priority: $priority)';
}

/// Simple priority queue implementation
class PriorityQueue<T> {
  final List<T> _items = [];
  final Comparator<T> _compare;

  PriorityQueue(this._compare);

  void add(T item) {
    _items.add(item);
    _items.sort(_compare);
  }

  T removeFirst() {
    if (_items.isEmpty) throw StateError('Queue is empty');
    return _items.removeAt(0);
  }

  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;
  void clear() => _items.clear();
}

/// Statistics for thumbnail service
class ThumbnailServiceStats {
  final int queueSize;
  final int processing;
  final int completed;
  final bool isProcessing;

  const ThumbnailServiceStats({
    required this.queueSize,
    required this.processing,
    required this.completed,
    required this.isProcessing,
  });

  @override
  String toString() {
    return 'ThumbnailServiceStats(queue: $queueSize, processing: $processing, completed: $completed, active: $isProcessing)';
  }
}