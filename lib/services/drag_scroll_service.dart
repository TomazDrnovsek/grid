import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Service that manages automatic scrolling when dragging items near screen edges.
///
/// This service provides edge detection and velocity calculation for smooth
/// auto-scrolling during drag operations. Designed for 120Hz performance.
class DragScrollService {
  // ============================================================================
  // CONFIGURATION CONSTANTS
  // ============================================================================

  /// Height of the edge detection zone at top and bottom of viewport
  static const double edgeZoneHeight = 80.0;

  /// Distance from edge for fast scroll speed activation
  static const double fastZoneThreshold = 30.0;

  /// Distance from edge for medium scroll speed activation
  static const double mediumZoneThreshold = 60.0;

  /// Scroll speeds in pixels per second
  static const double fastScrollSpeed = 400.0;
  static const double mediumScrollSpeed = 200.0;
  static const double slowScrollSpeed = 100.0;

  /// Frame interval for smooth 60 FPS scrolling (16.67ms)
  static const Duration frameInterval = Duration(milliseconds: 17);

  /// Minimum drag duration before auto-scroll activates (prevents accidental triggers)
  static const Duration activationDelay = Duration(milliseconds: 150);

  /// Buffer zone at scroll boundaries to prevent overshooting
  static const double scrollBoundaryBuffer = 10.0;

  // ============================================================================
  // EDGE ZONE DETECTION
  // ============================================================================

  /// Identifies which edge zone (if any) the drag position is within
  EdgeZone detectEdgeZone(Offset dragPosition, Size viewport) {
    final double topDistance = dragPosition.dy;
    final double bottomDistance = viewport.height - dragPosition.dy;

    // Check if drag is within top edge zone
    if (topDistance >= 0 && topDistance < edgeZoneHeight) {
      if (kDebugMode) {
        debugPrint('DragScroll: In TOP edge zone (distance: ${topDistance.toStringAsFixed(1)}px)');
      }
      return EdgeZone.top;
    }

    // Check if drag is within bottom edge zone
    if (bottomDistance >= 0 && bottomDistance < edgeZoneHeight) {
      if (kDebugMode) {
        debugPrint('DragScroll: In BOTTOM edge zone (distance: ${bottomDistance.toStringAsFixed(1)}px)');
      }
      return EdgeZone.bottom;
    }

    return EdgeZone.none;
  }

  /// Checks if a position is within any edge zone
  bool isInEdgeZone(Offset position, Size viewport) {
    return detectEdgeZone(position, viewport) != EdgeZone.none;
  }

  /// Gets the distance from the nearest edge (for velocity calculation)
  double getDistanceFromEdge(Offset dragPosition, Size viewport, EdgeZone zone) {
    switch (zone) {
      case EdgeZone.top:
        return dragPosition.dy.clamp(0.0, edgeZoneHeight);
      case EdgeZone.bottom:
        return (viewport.height - dragPosition.dy).clamp(0.0, edgeZoneHeight);
      case EdgeZone.none:
        return 0.0;
    }
  }

  // ============================================================================
  // VELOCITY CALCULATION
  // ============================================================================

  /// Calculates scroll velocity based on edge zone and distance from edge
  double calculateScrollVelocity(EdgeZone zone, double distanceFromEdge) {
    if (zone == EdgeZone.none || distanceFromEdge <= 0) {
      return 0.0;
    }

    // Determine speed tier based on distance
    final double baseSpeed = _getSpeedForDistance(distanceFromEdge);

    // Apply direction based on zone (negative for upward scroll)
    final double velocity = zone == EdgeZone.top ? -baseSpeed : baseSpeed;

    if (kDebugMode && velocity != 0) {
      debugPrint('DragScroll: Velocity calculated: ${velocity.toStringAsFixed(1)}px/s '
          '(zone: $zone, distance: ${distanceFromEdge.toStringAsFixed(1)}px)');
    }

    return velocity;
  }

  /// Determines scroll speed based on distance from edge
  double _getSpeedForDistance(double distance) {
    if (distance < fastZoneThreshold) {
      return fastScrollSpeed;
    } else if (distance < mediumZoneThreshold) {
      return mediumScrollSpeed;
    } else if (distance < edgeZoneHeight) {
      return slowScrollSpeed;
    }
    return 0.0;
  }

  /// Calculates smooth scroll velocity with easing
  double calculateSmoothVelocity(EdgeZone zone, double distanceFromEdge) {
    if (zone == EdgeZone.none || distanceFromEdge <= 0) {
      return 0.0;
    }

    // Calculate normalized position within edge zone (0.0 to 1.0)
    final double normalizedDistance = (edgeZoneHeight - distanceFromEdge) / edgeZoneHeight;

    // Apply easing curve for smooth acceleration
    final double easedValue = Curves.easeInOutCubic.transform(normalizedDistance);

    // Calculate velocity with easing
    final double baseVelocity = easedValue * fastScrollSpeed;

    // Apply direction
    return zone == EdgeZone.top ? -baseVelocity : baseVelocity;
  }

  // ============================================================================
  // SCROLL ANIMATION HELPERS
  // ============================================================================

  /// Calculates the delta scroll for a single frame
  double calculateFrameDelta(double velocityPerSecond) {
    // Convert velocity from pixels/second to pixels/frame
    return velocityPerSecond * (frameInterval.inMilliseconds / 1000.0);
  }

  /// Clamps scroll offset to valid bounds with buffer
  double clampScrollOffset(
      double targetOffset,
      double minExtent,
      double maxExtent,
      EdgeZone zone,
      ) {
    // Apply buffer at boundaries to prevent harsh stops
    double adjustedMin = minExtent;
    double adjustedMax = maxExtent;

    if (zone == EdgeZone.top && targetOffset <= scrollBoundaryBuffer) {
      // Approaching top boundary, slow down gradually
      adjustedMin = minExtent;
    } else if (zone == EdgeZone.bottom && targetOffset >= maxExtent - scrollBoundaryBuffer) {
      // Approaching bottom boundary, slow down gradually
      adjustedMax = maxExtent;
    }

    return targetOffset.clamp(adjustedMin, adjustedMax);
  }

  /// Checks if scrolling should stop due to reaching boundaries
  bool shouldStopAtBoundary(
      double currentOffset,
      double minExtent,
      double maxExtent,
      EdgeZone zone,
      ) {
    if (zone == EdgeZone.top && currentOffset <= minExtent) {
      if (kDebugMode) {
        debugPrint('DragScroll: Reached top boundary, stopping auto-scroll');
      }
      return true;
    }

    if (zone == EdgeZone.bottom && currentOffset >= maxExtent) {
      if (kDebugMode) {
        debugPrint('DragScroll: Reached bottom boundary, stopping auto-scroll');
      }
      return true;
    }

    return false;
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  /// Tracks active auto-scroll state
  Timer? _autoScrollTimer;
  EdgeZone _currentZone = EdgeZone.none;
  DateTime? _dragStartTime;
  bool _isAutoScrollActive = false;

  /// Gets whether auto-scroll is currently active
  bool get isAutoScrollActive => _isAutoScrollActive;

  /// Gets the current edge zone being scrolled
  EdgeZone get currentZone => _currentZone;

  /// Marks the start of a drag operation
  void onDragStart() {
    _dragStartTime = DateTime.now();
    _currentZone = EdgeZone.none;
    _isAutoScrollActive = false;

    if (kDebugMode) {
      debugPrint('DragScroll: Drag started, activation pending');
    }
  }

  /// Checks if enough time has passed for auto-scroll activation
  bool canActivateAutoScroll() {
    if (_dragStartTime == null) return false;

    final elapsed = DateTime.now().difference(_dragStartTime!);
    return elapsed >= activationDelay;
  }

  /// Updates the current edge zone
  void updateZone(EdgeZone zone) {
    if (_currentZone != zone) {
      if (kDebugMode) {
        debugPrint('DragScroll: Zone changed from $_currentZone to $zone');
      }
      _currentZone = zone;
    }
  }

  /// Marks auto-scroll as active
  void setAutoScrollActive(bool active) {
    _isAutoScrollActive = active;
  }

  /// Cleans up on drag end
  void onDragEnd() {
    stopAutoScroll();
    _dragStartTime = null;
    _currentZone = EdgeZone.none;
    _isAutoScrollActive = false;

    if (kDebugMode) {
      debugPrint('DragScroll: Drag ended, state cleared');
    }
  }

  /// Stops any active auto-scroll timer
  void stopAutoScroll() {
    if (_autoScrollTimer != null) {
      _autoScrollTimer!.cancel();
      _autoScrollTimer = null;
      _isAutoScrollActive = false;

      if (kDebugMode) {
        debugPrint('DragScroll: Auto-scroll stopped');
      }
    }
  }

  /// Sets the auto-scroll timer (for external management)
  void setAutoScrollTimer(Timer? timer) {
    if (_autoScrollTimer != null && _autoScrollTimer != timer) {
      _autoScrollTimer!.cancel();
    }
    _autoScrollTimer = timer;
    _isAutoScrollActive = timer != null;
  }

  /// Disposes of any resources
  void dispose() {
    stopAutoScroll();
    _dragStartTime = null;
    _currentZone = EdgeZone.none;
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Creates a visual indicator for the current scroll state
  String getScrollIndicator(EdgeZone zone) {
    switch (zone) {
      case EdgeZone.top:
        return '↑↑↑';
      case EdgeZone.bottom:
        return '↓↓↓';
      case EdgeZone.none:
        return '';
    }
  }

  /// Gets a description of the current scroll speed
  String getSpeedDescription(double velocity) {
    final double absVelocity = velocity.abs();
    if (absVelocity >= fastScrollSpeed * 0.9) {
      return 'Fast';
    } else if (absVelocity >= mediumScrollSpeed * 0.9) {
      return 'Medium';
    } else if (absVelocity > 0) {
      return 'Slow';
    }
    return 'None';
  }

  /// Validates scroll controller state
  bool isScrollControllerReady(ScrollController? controller) {
    return controller != null &&
        controller.hasClients &&
        controller.position.hasContentDimensions;
  }

  /// Gets safe scroll metrics from controller
  ScrollMetrics? getSafeScrollMetrics(ScrollController? controller) {
    if (isScrollControllerReady(controller)) {
      return controller!.position;
    }
    return null;
  }
}

// ============================================================================
// SUPPORTING TYPES
// ============================================================================

/// Represents the edge zones for auto-scrolling
enum EdgeZone {
  /// Drag is near the top edge
  top,

  /// Drag is near the bottom edge
  bottom,

  /// Drag is not in any edge zone
  none,
}

/// Configuration for customizing drag scroll behavior
class DragScrollConfig {
  final double edgeZoneHeight;
  final double fastScrollSpeed;
  final double mediumScrollSpeed;
  final double slowScrollSpeed;
  final Duration activationDelay;
  final bool useSmoothing;

  const DragScrollConfig({
    this.edgeZoneHeight = 80.0,
    this.fastScrollSpeed = 400.0,
    this.mediumScrollSpeed = 200.0,
    this.slowScrollSpeed = 100.0,
    this.activationDelay = const Duration(milliseconds: 150),
    this.useSmoothing = true,
  });

  /// Creates a configuration optimized for fast scrolling
  factory DragScrollConfig.fast() {
    return const DragScrollConfig(
      edgeZoneHeight: 100.0,
      fastScrollSpeed: 600.0,
      mediumScrollSpeed: 300.0,
      slowScrollSpeed: 150.0,
      activationDelay: Duration(milliseconds: 100),
    );
  }

  /// Creates a configuration optimized for precise control
  factory DragScrollConfig.precise() {
    return const DragScrollConfig(
      edgeZoneHeight: 60.0,
      fastScrollSpeed: 300.0,
      mediumScrollSpeed: 150.0,
      slowScrollSpeed: 75.0,
      activationDelay: Duration(milliseconds: 200),
    );
  }
}