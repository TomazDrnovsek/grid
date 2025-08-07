// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid/app_theme.dart';
import 'package:grid/core/service_locator.dart';
import 'package:grid/services/performance_monitor.dart';
import 'package:grid/services/image_cache_service.dart';
import 'ui/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // ENHANCED: Initialize dependency injection container
  await _initializeDependencyInjection();

  // Wrap the app with ProviderScope to enable Riverpod state management
  runApp(const ProviderScope(child: GridApp()));
}

/// Initialize dependency injection system replacing singleton pattern
Future<void> _initializeDependencyInjection() async {
  try {
    if (kDebugMode) {
      debugPrint('🚀 Initializing dependency injection system...');
    }

    // Initialize ServiceLocator with all dependencies
    final serviceLocator = ServiceLocator();
    await serviceLocator.initialize();

    if (kDebugMode) {
      debugPrint('✅ Dependency injection system initialized');

      // Print service statistics
      final stats = serviceLocator.getServiceStats();
      debugPrint('📊 Service Statistics:');
      debugPrint('  Services registered: ${stats['serviceCount']}');
      debugPrint('  Services: ${stats['services']}');
    }

  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Failed to initialize dependency injection: $e');
    }

    // This is critical - if DI fails, we can't continue
    rethrow;
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

    // ENHANCED: Dispose dependency injection system
    _disposeDependencyInjection();

    super.dispose();
  }

  /// Dispose dependency injection system properly
  Future<void> _disposeDependencyInjection() async {
    try {
      final serviceLocator = ServiceLocator();
      await serviceLocator.dispose();

      if (kDebugMode) {
        debugPrint('✅ Dependency injection system disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing dependency injection: $e');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    try {
      final serviceLocator = ServiceLocator();

      // Get services through dependency injection
      final performanceMonitor = serviceLocator.tryGet<PerformanceMonitor>();
      final imageCacheService = serviceLocator.tryGet<ImageCacheService>();

      if (performanceMonitor == null || imageCacheService == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Services not available for lifecycle management');
        }
        return;
      }

      switch (state) {
        case AppLifecycleState.resumed:
        // Resume monitoring when app becomes active
          final stats = performanceMonitor.getStatistics();
          if (!stats.isMonitoring) {
            performanceMonitor.startMonitoring();
            if (kDebugMode) {
              debugPrint('📱 App resumed - Performance monitoring restarted');
            }
          }
          // Exit memory pressure mode when app resumes
          imageCacheService.exitMemoryPressureMode();
          break;

        case AppLifecycleState.paused:
        case AppLifecycleState.detached:
        // Stop monitoring when app is backgrounded to save resources
          final stats = performanceMonitor.getStatistics();
          if (stats.isMonitoring) {
            performanceMonitor.stopMonitoring();
            if (kDebugMode) {
              debugPrint('📱 App paused - Performance monitoring stopped');
            }
          }
          // Enter memory pressure mode to free memory when backgrounded
          imageCacheService.enterMemoryPressureMode();
          break;

        case AppLifecycleState.inactive:
        // Aggressive cleanup during brief inactive states
          imageCacheService.performSmartCleanup();
          break;

        case AppLifecycleState.hidden:
        // Handle hidden state (newer Flutter versions)
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error handling app lifecycle change: $e');
      }
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