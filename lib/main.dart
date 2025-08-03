// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid/app_theme.dart';
import 'package:grid/core/app_config.dart';
import 'ui/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration (performance settings, refresh rate, etc.)
  await AppConfig().initialize();

  // Configure image cache with much larger limits to prevent reloading
  _configureImageCache();

  // Wrap the app with ProviderScope to enable Riverpod state management
  runApp(const ProviderScope(child: GridApp()));
}

/// Configure image cache for optimal performance - increased limits to prevent reloading
void _configureImageCache() {
  // Much larger cache limits to prevent image reloading
  PaintingBinding.instance.imageCache.maximumSize = 200; // Increased from 50-75
  PaintingBinding.instance.imageCache.maximumSizeBytes = 300 * 1024 * 1024; // 300MB instead of 100-150MB

  debugPrint('Image cache configured: 200 images, 300MB');
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