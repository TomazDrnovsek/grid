// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid/app_theme.dart';
import 'package:grid/core/app_config.dart';
import 'package:grid/services/image_cache_service.dart';
import 'package:grid/services/performance_monitor.dart';
import 'ui/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration (performance settings, refresh rate, etc.)
  await AppConfig().initialize();

  // Configure advanced image cache management
  _configureImageCache();

  // Initialize and start performance monitoring
  _initializePerformanceMonitoring();

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

/// Initialize performance monitoring system
void _initializePerformanceMonitoring() {
  try {
    final monitor = PerformanceMonitor.instance;

    // Initialize with device-specific thresholds
    monitor.initialize();

    // Start monitoring in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      monitor.startMonitoring();

      // Add a frame callback to track poor performance
      monitor.addFrameCallback((frameData) {
        if (frameData.isCritical) {
          debugPrint('🚨 Critical frame performance: ${frameData.totalMs.toStringAsFixed(1)}ms');
        }
      });

      // Schedule periodic performance reports (every 30 seconds in debug)
      _schedulePerformanceReports(monitor);
    }

    debugPrint('✅ Performance monitoring initialized');

  } catch (e) {
    debugPrint('⚠️ Error initializing performance monitoring: $e');
    // Continue without performance monitoring - not critical for app function
  }
}

/// Schedule periodic performance reports for debugging
void _schedulePerformanceReports(PerformanceMonitor monitor) {
  if (const bool.fromEnvironment('dart.vm.product')) return;

  // Print detailed performance report every 30 seconds in debug mode
  Future.delayed(const Duration(seconds: 30), () {
    monitor.printPerformanceReport();
    _schedulePerformanceReports(monitor); // Reschedule
  });
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

class _GridAppState extends State<GridApp> with WidgetsBindingObserver {
  late ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();

    // Observe app lifecycle for performance monitoring
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Clean up observers
    WidgetsBinding.instance.removeObserver(this);

    // Stop performance monitoring when app is disposed
    try {
      PerformanceMonitor.instance.stopMonitoring();
    } catch (e) {
      debugPrint('Error stopping performance monitor: $e');
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    try {
      final monitor = PerformanceMonitor.instance;

      switch (state) {
        case AppLifecycleState.resumed:
        // Resume monitoring when app becomes active
          if (!monitor.getStatistics().isMonitoring) {
            monitor.startMonitoring();
            debugPrint('📱 App resumed - Performance monitoring restarted');
          }
          break;

        case AppLifecycleState.paused:
        case AppLifecycleState.detached:
        // Stop monitoring when app is backgrounded to save resources
          if (monitor.getStatistics().isMonitoring) {
            monitor.stopMonitoring();
            debugPrint('📱 App paused - Performance monitoring stopped');
          }
          break;

        case AppLifecycleState.inactive:
        // Keep monitoring during brief inactive states
          break;

        case AppLifecycleState.hidden:
        // Handle hidden state (newer Flutter versions)
          break;
      }
    } catch (e) {
      debugPrint('Error handling app lifecycle change: $e');
    }
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