// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid/app_theme.dart';
import 'ui/splash_screen.dart';

void main() {
  // Configure image cache for better performance
  WidgetsFlutterBinding.ensureInitialized();

  // Increase image cache size for smooth scrolling
  // Default is 100MB and 1000 images, we'll increase it
  PaintingBinding.instance.imageCache.maximumSize = 1000; // Max number of images
  PaintingBinding.instance.imageCache.maximumSizeBytes = 500 * 1024 * 1024; // 500MB

  runApp(const GridApp());
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