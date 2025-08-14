// File: lib/services/dominant_color_service.dart
import 'dart:io';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for extracting and caching dominant colors from images
/// SUBTLE ENHANCEMENT: Original logic + tiny vibrancy boost for appeal
/// Uses LRU cache with max 100 colors and SharedPreferences persistence
class DominantColorService {
  static final DominantColorService _instance = DominantColorService._internal();
  factory DominantColorService() => _instance;
  DominantColorService._internal();

  // LRU cache implementation
  final LinkedHashMap<String, Color> _colorCache = LinkedHashMap();
  static const int _maxCacheSize = 100;

  // Persistence keys
  static const String _cacheKey = 'dominant_colors_cache';
  static const String _cacheOrderKey = 'dominant_colors_order';

  // SUBTLE: Tiny enhancement parameters
  static const double _subtleSaturationBoost = 1.05; // TINY: +5% saturation only
  static const double _targetLightness = 0.36;       // NORMALIZE: Target brightness (36% - darker for better contrast)

  bool _isInitialized = false;
  bool _isLoadingCache = false;

  /// Initialize service and load persisted cache
  Future<void> initialize() async {
    if (_isInitialized || _isLoadingCache) return;

    _isLoadingCache = true;

    try {
      await loadPersistedCache();
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('DominantColorService initialized with ${_colorCache.length} cached colors');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing DominantColorService: $e');
      }
    } finally {
      _isLoadingCache = false;
    }
  }

  /// Get dominant color for an image path
  /// Returns cached color if available, otherwise extracts and caches
  Future<Color> getDominantColor(String imagePath) async {
    // Initialize if needed
    if (!_isInitialized) {
      await initialize();
    }

    // Check cache first
    if (_colorCache.containsKey(imagePath)) {
      // Move to end for LRU
      final color = _colorCache.remove(imagePath)!;
      _colorCache[imagePath] = color;

      if (kDebugMode) {
        debugPrint('Cache hit for dominant color: $imagePath');
      }

      return color;
    }

    // Extract color from thumbnail
    try {
      final color = await _extractDominantColor(imagePath);

      // Cache the result
      await cacheColor(imagePath, color);

      return color;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error extracting dominant color for $imagePath: $e');
      }
      return Colors.transparent;
    }
  }

  /// Extract dominant color from image file with subtle enhancement
  Future<Color> _extractDominantColor(String imagePath) async {
    try {
      final file = File(imagePath);

      // Verify file exists
      if (!await file.exists()) {
        if (kDebugMode) {
          debugPrint('File does not exist: $imagePath');
        }
        return Colors.transparent;
      }

      // Start timing for performance monitoring
      final startTime = DateTime.now();

      // IMPROVED: Better sampling while keeping original logic
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        FileImage(file),
        size: const Size(200, 200), // Better sampling (was 100x100)
        maximumColorCount: 16,      // More options (was 5)
      );

      // ORIGINAL: Preserve original color selection priority
      Color dominantColor = Colors.transparent;

      if (paletteGenerator.dominantColor != null) {
        dominantColor = paletteGenerator.dominantColor!.color;
      } else if (paletteGenerator.vibrantColor != null) {
        dominantColor = paletteGenerator.vibrantColor!.color;
      } else if (paletteGenerator.mutedColor != null) {
        dominantColor = paletteGenerator.mutedColor!.color;
      } else if (paletteGenerator.colors.isNotEmpty) {
        dominantColor = paletteGenerator.colors.first;
      }

      // SUBTLE: Apply tiny vibrancy boost
      if (dominantColor != Colors.transparent) {
        dominantColor = _applySubtleEnhancement(dominantColor);
      }

      final extractionTime = DateTime.now().difference(startTime);

      if (kDebugMode) {
        debugPrint('Extracted dominant color in ${extractionTime.inMilliseconds}ms for: $imagePath');
      }

      return dominantColor;

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to extract dominant color: $e');
      }
      return Colors.transparent;
    }
  }

  /// SUBTLE: Apply tiny enhancement + brightness normalization for consistent visibility
  Color _applySubtleEnhancement(Color original) {
    final hsl = HSLColor.fromColor(original);

    // TINY boost: Only +5% saturation
    final enhancedSaturation = (hsl.saturation * _subtleSaturationBoost).clamp(0.0, 1.0);

    // NORMALIZE: Set all colors to consistent brightness level
    final normalizedLightness = _targetLightness;

    // Create subtly enhanced and normalized color
    final enhancedColor = hsl
        .withSaturation(enhancedSaturation)
        .withLightness(normalizedLightness)
        .toColor();

    if (kDebugMode) {
      debugPrint('Color normalization:');
      debugPrint('  Original: HSL(${hsl.hue.toStringAsFixed(0)}°, ${(hsl.saturation * 100).toStringAsFixed(0)}%, ${(hsl.lightness * 100).toStringAsFixed(0)}%)');
      debugPrint('  Enhanced: HSL(${hsl.hue.toStringAsFixed(0)}°, ${(enhancedSaturation * 100).toStringAsFixed(0)}%, ${(normalizedLightness * 100).toStringAsFixed(0)}%)');
    }

    return enhancedColor;
  }

  /// Cache a color for an image path
  Future<void> cacheColor(String imagePath, Color color) async {
    // Add to cache (LRU - newest at end)
    _colorCache.remove(imagePath); // Remove if exists
    _colorCache[imagePath] = color;

    // Enforce max cache size
    while (_colorCache.length > _maxCacheSize) {
      _colorCache.remove(_colorCache.keys.first);
    }

    // Persist to storage
    await _persistCache();
  }

  /// Load persisted cache from SharedPreferences
  Future<void> loadPersistedCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cache data
      final cacheJson = prefs.getString(_cacheKey);
      final orderJson = prefs.getString(_cacheOrderKey);

      if (cacheJson == null || orderJson == null) {
        if (kDebugMode) {
          debugPrint('No persisted color cache found');
        }
        return;
      }

      // Parse cache
      final Map<String, dynamic> cacheMap = jsonDecode(cacheJson);
      final List<dynamic> orderList = jsonDecode(orderJson);

      // Clear current cache
      _colorCache.clear();

      // Rebuild cache in order (for LRU)
      for (final path in orderList) {
        if (cacheMap.containsKey(path)) {
          final colorHex = cacheMap[path] as String;
          final colorValue = int.tryParse(colorHex.replaceFirst('#', '0xff'));

          if (colorValue != null) {
            _colorCache[path] = Color(colorValue);
          }
        }
      }

      // Enforce max size
      while (_colorCache.length > _maxCacheSize) {
        _colorCache.remove(_colorCache.keys.first);
      }

      if (kDebugMode) {
        debugPrint('Loaded ${_colorCache.length} colors from persistent cache');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading persisted color cache: $e');
      }
      _colorCache.clear(); // Clear on error
    }
  }

  /// Persist current cache to SharedPreferences
  Future<void> _persistCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert cache to JSON-friendly format
      final cacheMap = <String, String>{};
      final orderList = <String>[];

      for (final entry in _colorCache.entries) {
        final path = entry.key;
        final color = entry.value;

        // Convert color to hex string using new API
        final alpha = ((color.a * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
        final red = ((color.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
        final green = ((color.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
        final blue = ((color.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
        final hex = '#$alpha$red$green$blue';

        cacheMap[path] = hex;
        orderList.add(path);
      }

      // Save to preferences
      await prefs.setString(_cacheKey, jsonEncode(cacheMap));
      await prefs.setString(_cacheOrderKey, jsonEncode(orderList));

      if (kDebugMode) {
        debugPrint('Persisted ${_colorCache.length} colors to cache');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error persisting color cache: $e');
      }
    }
  }

  /// Clear all cached colors
  void clearCache() {
    _colorCache.clear();
    _clearPersistedCache();

    if (kDebugMode) {
      debugPrint('Color cache cleared');
    }
  }

  /// Clear persisted cache from SharedPreferences
  Future<void> _clearPersistedCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheOrderKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing persisted cache: $e');
      }
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _colorCache.length,
      'maxSize': _maxCacheSize,
      'isInitialized': _isInitialized,
      'cacheUtilization': '${(_colorCache.length / _maxCacheSize * 100).toStringAsFixed(1)}%',
      'enhancementMode': 'Original + Subtle Enhancement + Brightness Normalization',
      'saturationBoost': '${((_subtleSaturationBoost - 1) * 100).toStringAsFixed(0)}%',
      'targetLightness': '${(_targetLightness * 100).toStringAsFixed(0)}%',
      'sampleSize': '200x200px',
      'maxColors': 16,
    };
  }

  /// Preload colors for visible images
  Future<void> preloadColors(List<String> imagePaths) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Process in batches to avoid overwhelming
    const batchSize = 5;

    for (int i = 0; i < imagePaths.length; i += batchSize) {
      final batch = imagePaths.skip(i).take(batchSize);

      await Future.wait(
        batch.map((path) => getDominantColor(path)),
        eagerError: false, // Continue even if some fail
      );

      // Small delay between batches
      if (i + batchSize < imagePaths.length) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
  }
}