// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid/app_theme.dart';
import 'package:grid/core/app_config.dart';
import 'package:grid/services/image_cache_service.dart';
import 'package:grid/services/performance_monitor.dart';
import 'package:grid/services/thumbnail_service.dart';
import 'package:grid/services/scroll_optimization_service.dart';
import 'ui/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration (performance settings, refresh rate, etc.)
  await AppConfig().initialize();

  // ENHANCED: Configure aggressive memory management for 79-image grid
  _configureEnhancedImageCache();

  // Initialize thumbnail service for lazy loading
  _initializeThumbnailService();

  // Initialize scroll optimization service for invisible performance improvements
  _initializeScrollOptimizationService();

  // Initialize and start performance monitoring
  _initializePerformanceMonitoring();

  // Wrap the app with ProviderScope to enable Riverpod state management
  runApp(const ProviderScope(child: GridApp()));
}

/// ENHANCED: Configure aggressive image cache management to prevent 99% memory usage
void _configureEnhancedImageCache() {
  try {
    // Use the enhanced ImageCacheService for aggressive memory management
    ImageCacheService().configureCache();

    // ENHANCED: Print cache statistics with memory warnings
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      // Small delay to let the cache initialize before printing stats
      Future.delayed(const Duration(milliseconds: 100), () {
        ImageCacheService().printStatistics();
        debugPrint('🧠 MEMORY CRISIS MODE: Aggressive cache management active');
        debugPrint('📉 REDUCED LIMITS: Conservative memory thresholds');
        debugPrint('🔄 AUTO-EVICTION: LRU cleanup at 70% usage');
      });
    }

  } catch (e) {
    debugPrint('Error configuring Enhanced ImageCacheService: $e');

    // Fallback to ultra-conservative configuration if the service fails
    _configureUltraConservativeCache();
  }
}

/// Initialize thumbnail service for lazy loading
/// TASK 3.2: Reduces initial load time from 1501ms to <100ms
void _initializeThumbnailService() {
  try {
    // Get thumbnail service instance (singleton initialization)
    final thumbnailService = ThumbnailService();

    // Log initialization in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      final stats = thumbnailService.getStats();
      debugPrint('✅ ThumbnailService initialized: $stats');
      debugPrint('🚀 LAZY LOADING: Thumbnails will generate on-demand');
    }

  } catch (e) {
    debugPrint('⚠️ Error initializing ThumbnailService: $e');
    // Continue without thumbnail service - app will work but without lazy loading optimization
  }
}

/// Initialize scroll optimization service for invisible performance improvements
/// TASK 3.3: Eliminates frame drops (17-332ms → 8.3ms target) with zero UX impact
void _initializeScrollOptimizationService() {
  try {
    // Get scroll optimization service instance (singleton initialization)
    final scrollOptimizer = ScrollOptimizationService();

    // Initialize the service
    scrollOptimizer.initialize();

    // Log initialization in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      debugPrint('✅ ScrollOptimizationService initialized');
      debugPrint('🎯 INVISIBLE OPTIMIZATIONS: Frame drops 17-332ms → 8.3ms target');
      debugPrint('📱 ZERO UX IMPACT: No visible quality changes or loading indicators');
    }

  } catch (e) {
    debugPrint('⚠️ Error initializing ScrollOptimizationService: $e');
    // Continue without scroll optimization - app will work but without performance improvements
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

          // ENHANCED: Also log memory pressure during critical frames
          final cacheService = ImageCacheService();
          final stats = cacheService.getStatistics();
          final usagePercent = stats.maximumSizeBytes > 0
              ? (stats.currentSizeBytes / stats.maximumSizeBytes * 100)
              : 0.0;

          if (usagePercent > 85) {
            debugPrint('🧠 Memory pressure during critical frame: ${usagePercent.toStringAsFixed(1)}%');
          }
        }
      });

      // ENHANCED: Schedule more frequent performance reports during memory crisis
      _scheduleEnhancedPerformanceReports(monitor);
    }

    debugPrint('✅ Performance monitoring initialized with memory crisis detection');

  } catch (e) {
    debugPrint('⚠️ Error initializing performance monitoring: $e');
    // Continue without performance monitoring - not critical for app function
  }
}

/// ENHANCED: Schedule frequent performance reports for memory crisis monitoring
void _scheduleEnhancedPerformanceReports(PerformanceMonitor monitor) {
  if (const bool.fromEnvironment('dart.vm.product')) return;

  // ENHANCED: More frequent reports during memory crisis - every 20 seconds
  Future.delayed(const Duration(seconds: 20), () {
    monitor.printPerformanceReport();

    // Enhanced cache statistics during memory crisis
    try {
      final cacheService = ImageCacheService();
      final stats = cacheService.getStatistics();
      final usagePercent = stats.maximumSizeBytes > 0
          ? (stats.currentSizeBytes / stats.maximumSizeBytes * 100)
          : 0.0;
      final avgSizeMB = stats.currentSize > 0
          ? (stats.currentSizeBytes / stats.currentSize / 1024 / 1024)
          : 0.0;

      debugPrint('🧠 MEMORY CRISIS MONITORING:');
      debugPrint('  Usage: ${usagePercent.toStringAsFixed(1)}% (${stats.currentSize} images)');
      debugPrint('  Average: ${avgSizeMB.toStringAsFixed(1)}MB per image');
      debugPrint('  Pressure Events: ${stats.memoryPressureEvents}');
      debugPrint('  Aggressive Cleanups: ${stats.aggressiveCleanups}');
      debugPrint('  Pressure Mode: ${stats.memoryPressureMode}');

      // Alert if still in crisis
      if (usagePercent > 85) {
        debugPrint('🚨 MEMORY STILL IN CRISIS: ${usagePercent.toStringAsFixed(1)}% usage');
      } else if (usagePercent > 70) {
        debugPrint('⚠️ MEMORY WARNING: ${usagePercent.toStringAsFixed(1)}% usage');
      } else {
        debugPrint('✅ MEMORY HEALTHY: ${usagePercent.toStringAsFixed(1)}% usage');
      }

    } catch (e) {
      debugPrint('Error getting enhanced cache stats: $e');
    }

    // Also print thumbnail service stats
    try {
      final thumbnailStats = ThumbnailService().getStats();
      debugPrint('📊 Thumbnail Service: $thumbnailStats');
    } catch (e) {
      debugPrint('Error getting thumbnail stats: $e');
    }

    // Print scroll optimization stats
    try {
      final scrollOptimizer = ScrollOptimizationService();
      scrollOptimizer.printStats();
    } catch (e) {
      debugPrint('Error getting scroll optimization stats: $e');
    }

    _scheduleEnhancedPerformanceReports(monitor); // Reschedule
  });
}

/// ENHANCED: Ultra-conservative fallback cache configuration for memory crisis
void _configureUltraConservativeCache() {
  try {
    // Ultra-conservative cache configuration as fallback
    PaintingBinding.instance.imageCache.maximumSize = 50;  // Extremely limited
    PaintingBinding.instance.imageCache.maximumSizeBytes = 80 * 1024 * 1024; // 80MB only

    debugPrint('🚨 ULTRA-CONSERVATIVE cache configured: 50 images, 80MB (emergency fallback)');
  } catch (e) {
    debugPrint('Critical error: Failed to configure ultra-conservative image cache: $e');
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

    // Observe app lifecycle for performance monitoring and memory management
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

    // Dispose thumbnail service when app is disposed
    try {
      ThumbnailService().dispose();
    } catch (e) {
      debugPrint('Error disposing thumbnail service: $e');
    }

    // Dispose scroll optimization service when app is disposed
    try {
      ScrollOptimizationService().dispose();
    } catch (e) {
      debugPrint('Error disposing scroll optimization service: $e');
    }

    // ENHANCED: Clear image cache on app dispose to free memory
    try {
      ImageCacheService().clearCache();
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    try {
      final monitor = PerformanceMonitor.instance;
      final cacheService = ImageCacheService();

      switch (state) {
        case AppLifecycleState.resumed:
        // Resume monitoring when app becomes active
          if (!monitor.getStatistics().isMonitoring) {
            monitor.startMonitoring();
            debugPrint('📱 App resumed - Performance monitoring restarted');
          }
          // ENHANCED: Exit memory pressure mode when app resumes
          cacheService.exitMemoryPressureMode();
          break;

        case AppLifecycleState.paused:
        case AppLifecycleState.detached:
        // Stop monitoring when app is backgrounded to save resources
          if (monitor.getStatistics().isMonitoring) {
            monitor.stopMonitoring();
            debugPrint('📱 App paused - Performance monitoring stopped');
          }
          // ENHANCED: Enter memory pressure mode to free memory when backgrounded
          cacheService.enterMemoryPressureMode();
          break;

        case AppLifecycleState.inactive:
        // ENHANCED: Aggressive cleanup during brief inactive states
          cacheService.performSmartCleanup();
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