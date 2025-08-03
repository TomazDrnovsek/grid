// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid/app_theme.dart';
import 'package:grid/core/app_config.dart';
import 'package:grid/services/image_cache_service.dart';
import 'ui/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration (performance settings, refresh rate, etc.)
  await AppConfig().initialize();

  // Configure advanced image cache management
  _configureImageCache();

  // Wrap the app with ProviderScope to enable Riverpod state management
  runApp(const ProviderScope(child: GridApp()));
}

/// Configure advanced image cache with smart management and LRU eviction
void _configureImageCache() {
  try {
    // Use the new ImageCacheService for advanced cache management
    ImageCacheService().configureCache();

    // Print cache statistics in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      // Small delay to let the cache initialize before printing stats
      Future.delayed(const Duration(milliseconds: 100), () {
        ImageCacheService().printStatistics();
      });
    }

  } catch (e) {
    debugPrint('Error configuring ImageCacheService: $e');

    // Fallback to basic configuration if the service fails
    _configureFallbackCache();
  }
}

/// Fallback cache configuration for error cases
void _configureFallbackCache() {
  try {
    // Basic cache configuration as fallback
    PaintingBinding.instance.imageCache.maximumSize = 200;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 300 * 1024 * 1024; // 300MB

    debugPrint('Image cache configured: 200 images, 300MB (fallback)');
  } catch (e) {
    debugPrint('Critical error: Failed to configure image cache: $e');
  }
}

class GridApp extends StatefulWidget {
  const GridApp({super.key});

  @override
  State<GridApp> createState() => _GridAppState();
}

class _GridAppState extends State<GridApp> {
  late ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: 'Grid',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: _themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(themeNotifier: _themeNotifier),
        );
      },
    );
  }
}