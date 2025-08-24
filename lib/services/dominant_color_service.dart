// File: lib/services/dominant_color_service.dart
import 'dart:io';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for extracting and caching dominant colors from images
/// PHASE A: Enhanced with persistent cache that survives app restarts
/// SUBTLE ENHANCEMENT: Original logic + tiny vibrancy boost for appeal
/// Uses LRU cache with max 100 colors and SharedPreferences persistence
class DominantColorService {
  static final DominantColorService _instance = DominantColorService._internal();
  factory DominantColorService() => _instance;
  DominantColorService._internal();

  // LRU cache implementation
  final LinkedHashMap<String, Color> _colorCache = LinkedHashMap();
  static const int _maxCacheSize = 100;

  // PHASE A: Updated persistence keys with v2 for better cache management
  static const String _cacheKey = 'dominant_colors_cache_v2';
  bool _cacheLoaded = false;
  bool _isInitializing = false; // Prevent race condition

  // SUBTLE: Tiny enhancement parameters
  static const double _subtleSaturationBoost = 1.05; // TINY: +5% saturation only
  static const double _targetLightness = 0.36;       // NORMALIZE: Target brightness (36% - darker for better contrast)

  /// PHASE A: Initialize service and load persisted cache (race-condition safe)
  Future<void> initialize() async {
    if (_cacheLoaded || _isInitializing) return;

    _isInitializing = true; // Prevent concurrent initializations

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);

      if (cacheJson != null) {
        final Map<String, dynamic> cached = json.decode(cacheJson);
        cached.forEach((key, value) {
          _colorCache[key] = Color(value as int);
        });

        if (kDebugMode) {
          debugPrint('✅ Phase A: Loaded ${_colorCache.length} colors from persistent cache');
        }
      } else {
        if (kDebugMode) {
          debugPrint('📝 Phase A: No persistent cache found, starting fresh');
        }
      }

      _cacheLoaded = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Phase A: Error loading cache: $e');
      }
      _cacheLoaded = true;
    } finally {
      _isInitializing = false; // Always reset the flag
    }
  }

  /// Get dominant color for an image path
  /// PHASE A: Ensures cache is loaded before proceeding
  Future<Color> getDominantColor(String imagePath) async {
    // PHASE A: Initialize cache if not loaded
    if (!_cacheLoaded) await initialize();

    // Check cache first
    if (_colorCache.containsKey(imagePath)) {
      // Move to end for LRU
      final color = _colorCache.remove(imagePath)!;
      _colorCache[imagePath] = color;

      if (kDebugMode) {
        debugPrint('⚡ Phase A: Cache hit for dominant color: $imagePath');
      }

      return color;
    }

    // Extract color from thumbnail
    try {
      final color = await _extractDominantColor(imagePath);

      // Cache the result with persistence
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

  /// PHASE A: Cache a color with batched persistence
  Future<void> cacheColor(String imagePath, Color color) async {
    // Add to cache (LRU - newest at end)
    _colorCache.remove(imagePath); // Remove if exists
    _colorCache[imagePath] = color;

    // Enforce max cache size
    while (_colorCache.length > _maxCacheSize) {
      _colorCache.remove(_colorCache.keys.first);
    }

    // PHASE A: Persist less frequently to reduce overhead
    if (_colorCache.length % 3 == 0) {
      await _persistCache();
    }
  }

  /// PHASE A: Persist current cache to SharedPreferences
  Future<void> _persistCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheMap = <String, int>{};

      _colorCache.forEach((key, color) {
        cacheMap[key] = color.toARGB32(); // Fixed: replace deprecated .value
      });

      await prefs.setString(_cacheKey, json.encode(cacheMap));

      if (kDebugMode) {
        debugPrint('💾 Phase A: Persisted ${_colorCache.length} colors to cache');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Phase A: Error persisting cache: $e');
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
      'isInitialized': _cacheLoaded,
      'cacheUtilization': '${(_colorCache.length / _maxCacheSize * 100).toStringAsFixed(1)}%',
      'enhancementMode': 'Phase A: Original + Subtle Enhancement + Persistent Cache',
      'saturationBoost': '${((_subtleSaturationBoost - 1) * 100).toStringAsFixed(0)}%',
      'targetLightness': '${(_targetLightness * 100).toStringAsFixed(0)}%',
      'sampleSize': '200x200px',
      'maxColors': 16,
      'phaseAActive': true,
    };
  }

  /// Preload colors for visible images
  Future<void> preloadColors(List<String> imagePaths) async {
    if (!_cacheLoaded) {
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