// File: lib/core/service_locator.dart
import 'package:flutter/foundation.dart';
import '../services/image_cache_service.dart';
import '../services/scroll_optimization_service.dart';
import '../services/thumbnail_service.dart';
import '../services/performance_monitor.dart';
import '../services/photo_database.dart';
import '../core/app_config.dart';

/// Simple dependency injection container for services
/// Replaces singleton pattern with proper dependency management
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  bool _isInitialized = false;

  /// Initialize all services with proper dependency injection
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('ServiceLocator already initialized');
      }
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint('🚀 Initializing ServiceLocator with dependency injection...');
      }

      // Initialize core configuration first
      final appConfig = AppConfig();
      await appConfig.initialize();
      _services[AppConfig] = appConfig;

      // Initialize database
      final database = PhotoDatabase();
      _services[PhotoDatabase] = database;

      // Initialize performance monitor
      final performanceMonitor = PerformanceMonitor.instance;
      performanceMonitor.initialize();
      _services[PerformanceMonitor] = performanceMonitor;

      // Initialize image cache service
      final imageCacheService = ImageCacheService();
      imageCacheService.configureCache();
      _services[ImageCacheService] = imageCacheService;

      // Initialize thumbnail service
      final thumbnailService = ThumbnailService();
      _services[ThumbnailService] = thumbnailService;

      // Initialize scroll optimization service
      final scrollOptimizationService = ScrollOptimizationService();
      scrollOptimizationService.initialize();
      _services[ScrollOptimizationService] = scrollOptimizationService;

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ ServiceLocator initialized with ${_services.length} services');
        _printRegisteredServices();
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing ServiceLocator: $e');
      }
      rethrow;
    }
  }

  /// Get service by type with null safety
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered. Make sure to call initialize() first.');
    }
    return service as T;
  }

  /// Check if service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Get service safely (returns null if not registered)
  T? tryGet<T>() {
    return _services[T] as T?;
  }

  /// Register a service (for testing or late registration)
  void register<T>(T service) {
    _services[T] = service;
    if (kDebugMode) {
      debugPrint('📝 Registered service: $T');
    }
  }

  /// Dispose all services properly
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      if (kDebugMode) {
        debugPrint('🧹 Disposing ServiceLocator services...');
      }

      // Dispose services in reverse order of initialization
      final scrollOptimizer = tryGet<ScrollOptimizationService>();
      scrollOptimizer?.dispose();

      final thumbnailService = tryGet<ThumbnailService>();
      thumbnailService?.dispose();

      final imageCacheService = tryGet<ImageCacheService>();
      imageCacheService?.clearCache();

      final performanceMonitor = tryGet<PerformanceMonitor>();
      performanceMonitor?.stopMonitoring();

      final database = tryGet<PhotoDatabase>();
      await database?.close();

      _services.clear();
      _isInitialized = false;

      if (kDebugMode) {
        debugPrint('✅ ServiceLocator disposed');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing ServiceLocator: $e');
      }
    }
  }

  /// Print registered services for debugging
  void _printRegisteredServices() {
    if (!kDebugMode) return;

    debugPrint('📋 Registered services:');
    for (final type in _services.keys) {
      debugPrint('  - $type');
    }
  }

  /// Get service statistics for debugging
  Map<String, dynamic> getServiceStats() {
    final stats = <String, dynamic>{
      'initialized': _isInitialized,
      'serviceCount': _services.length,
      'services': _services.keys.map((type) => type.toString()).toList(),
    };

    // Get individual service stats if available
    try {
      final imageCacheService = tryGet<ImageCacheService>();
      if (imageCacheService != null) {
        stats['imageCacheStats'] = imageCacheService.getStatistics();
      }

      final performanceMonitor = tryGet<PerformanceMonitor>();
      if (performanceMonitor != null) {
        stats['performanceStats'] = performanceMonitor.getStatistics();
      }

      final thumbnailService = tryGet<ThumbnailService>();
      if (thumbnailService != null) {
        stats['thumbnailStats'] = thumbnailService.getStats();
      }

      final scrollOptimizer = tryGet<ScrollOptimizationService>();
      if (scrollOptimizer != null) {
        stats['scrollStats'] = scrollOptimizer.getStats();
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting service stats: $e');
      }
    }

    return stats;
  }

  /// Reset for testing
  @visibleForTesting
  void reset() {
    _services.clear();
    _isInitialized = false;
  }
}

/// Extension for easy access to services
extension ServiceLocatorExtension on Object {
  /// Get service from ServiceLocator
  T getService<T>() => ServiceLocator().get<T>();

  /// Try to get service from ServiceLocator
  T? tryGetService<T>() => ServiceLocator().tryGet<T>();
}