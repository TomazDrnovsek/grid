// File: lib/services/image_cache_service.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Advanced image cache service that prevents image reloading during theme changes and scrolling
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // Cache for preloaded images to prevent disposal
  final Map<String, ImageProvider> _permanentCache = {};
  final Set<String> _preloadedPaths = {};

  /// Configure the global image cache with aggressive settings
  static void configureGlobalCache() {
    final imageCache = PaintingBinding.instance.imageCache;

    // Increase cache size significantly
    imageCache.maximumSize = 200; // Increased from default 100
    imageCache.maximumSizeBytes = 300 * 1024 * 1024; // 300MB instead of 100MB

    debugPrint('Image cache configured: ${imageCache.maximumSize} images, ${(imageCache.maximumSizeBytes / 1024 / 1024).round()}MB');
  }

  /// Preload critical images and keep them in permanent cache
  Future<void> preloadCriticalImages(List<File> thumbnails) async {
    final criticalCount = thumbnails.length > 24 ? 24 : thumbnails.length; // First 24 images

    for (int i = 0; i < criticalCount; i++) {
      try {
        final file = thumbnails[i];
        final path = file.path;

        if (_preloadedPaths.contains(path)) continue;

        final imageProvider = FileImage(file);

        // Preload the image
        final imageStream = imageProvider.resolve(const ImageConfiguration());
        final completer = Completer<void>();

        void onImageLoaded(ImageInfo info, bool syncCall) {
          // Store in permanent cache
          _permanentCache[path] = imageProvider;
          _preloadedPaths.add(path);
          completer.complete();
        }

        void onImageError(dynamic exception, StackTrace? stackTrace) {
          debugPrint('Failed to preload image: $path');
          completer.complete();
        }

        final listener = ImageStreamListener(onImageLoaded, onError: onImageError);
        imageStream.addListener(listener);

        // Wait for preload with timeout
        try {
          await completer.future.timeout(
            const Duration(seconds: 5),
          );
        } catch (e) {
          debugPrint('Preload timeout for: $path');
        } finally {
          imageStream.removeListener(listener);
        }

        // Small delay to prevent overwhelming the system
        await Future.delayed(const Duration(milliseconds: 10));

      } catch (e) {
        debugPrint('Error preloading image ${thumbnails[i].path}: $e');
      }
    }

    debugPrint('Preloaded ${_preloadedPaths.length} critical images');
  }

  /// Get cached image provider or create new one
  ImageProvider getImageProvider(File imageFile) {
    final path = imageFile.path;

    // Return from permanent cache if available
    if (_permanentCache.containsKey(path)) {
      return _permanentCache[path]!;
    }

    // Create new provider and potentially cache it
    final provider = FileImage(imageFile);

    // Add to permanent cache if it's a critical image
    if (_preloadedPaths.contains(path)) {
      _permanentCache[path] = provider;
    }

    return provider;
  }

  /// Prevent specific images from being evicted
  void protectFromEviction(List<String> imagePaths) {
    for (final path in imagePaths) {
      final file = File(path);
      if (file.existsSync()) {
        final provider = FileImage(file);
        _permanentCache[path] = provider;
      }
    }
  }

  /// Clear non-critical cached images (keep permanent cache)
  void clearNonCriticalCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();

    debugPrint('Cleared cache, kept ${_permanentCache.length} permanent images');
  }

  /// Force refresh a specific image
  void refreshImage(String imagePath) {
    _permanentCache.remove(imagePath);
    _preloadedPaths.remove(imagePath);

    final provider = FileImage(File(imagePath));
    PaintingBinding.instance.imageCache.evict(provider);
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    return {
      'globalCacheSize': imageCache.currentSize,
      'globalCacheBytes': imageCache.currentSizeBytes,
      'globalMaxSize': imageCache.maximumSize,
      'globalMaxBytes': imageCache.maximumSizeBytes,
      'permanentCacheSize': _permanentCache.length,
      'preloadedCount': _preloadedPaths.length,
    };
  }

  /// Print cache statistics for debugging
  void printCacheStats() {
    if (kDebugMode) {
      final stats = getCacheStats();
      debugPrint('=== Image Cache Statistics ===');
      debugPrint('Global Cache: ${stats['globalCacheSize']}/${stats['globalMaxSize']} images');
      debugPrint('Global Memory: ${(stats['globalCacheBytes'] / 1024 / 1024).toStringAsFixed(1)}/${(stats['globalMaxBytes'] / 1024 / 1024).round()}MB');
      debugPrint('Permanent Cache: ${stats['permanentCacheSize']} images');
      debugPrint('Preloaded: ${stats['preloadedCount']} images');
      debugPrint('=============================');
    }
  }
}