// File: lib/widgets/error_boundary.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';

/// Comprehensive error boundary system for graceful error recovery
/// Handles widget build errors, async operation failures, and provides fallback UI
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack, VoidCallback? retry)? errorBuilder;
  final String? errorContext;
  final bool showRetryButton;
  final VoidCallback? onRetry;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.errorContext,
    this.showRetryButton = false,
    this.onRetry,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Set up global error handling for this boundary's subtree
    if (kDebugMode) {
      FlutterError.onError = (FlutterErrorDetails details) {
        // Log the error for debugging
        debugPrint('ErrorBoundary caught error in ${widget.errorContext ?? 'unknown context'}:');
        debugPrint('Error: ${details.exception}');
        debugPrint('Stack: ${details.stack}');

        // Update state if this boundary is still mounted
        if (mounted && !_hasError) {
          setState(() {
            _error = details.exception;
            _stackTrace = details.stack;
            _hasError = true;
          });
        }
      };
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
      _hasError = false;
    });

    if (widget.onRetry != null) {
      widget.onRetry!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace, widget.showRetryButton ? _retry : null) ??
          _DefaultErrorWidget(
            error: _error!,
            stackTrace: _stackTrace,
            context: widget.errorContext,
            onRetry: widget.showRetryButton ? _retry : null,
          );
    }

    // Wrap child in a safe container to catch any remaining errors
    return _SafeWidgetWrapper(
      onError: (error, stack) {
        if (mounted) {
          setState(() {
            _error = error;
            _stackTrace = stack;
            _hasError = true;
          });
        }
      },
      child: widget.child,
    );
  }
}

/// Safe widget wrapper that catches build-time errors
class _SafeWidgetWrapper extends StatelessWidget {
  final Widget child;
  final void Function(Object error, StackTrace stack) onError;

  const _SafeWidgetWrapper({
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return child;
    } catch (error, stack) {
      onError(error, stack);
      return _DefaultErrorWidget(
        error: error,
        stackTrace: stack,
        context: 'Widget build',
      );
    }
  }
}

/// Default error widget with consistent styling
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final String? context;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    this.context,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.gridErrorIcon(isDark),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Something went wrong',
            style: AppTheme.bodyMedium(isDark),
            textAlign: TextAlign.center,
          ),
          if (this.context != null) ...[
            const SizedBox(height: 4),
            Text(
              'Context: ${this.context}',
              style: AppTheme.body(isDark).copyWith(
                color: AppColors.textSecondary(isDark),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: AppTheme.bodyMedium(isDark),
              ),
            ),
          ],
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.body(isDark).copyWith(
                color: AppColors.textSecondary(isDark),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Specialized error boundary for grid items with compact error display
class GridItemErrorBoundary extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const GridItemErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ErrorBoundary(
      errorContext: 'Grid Item',
      showRetryButton: onRetry != null,
      onRetry: onRetry,
      errorBuilder: (error, stack, retry) => Container(
        color: AppColors.gridErrorBackground(isDark),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: AppColors.gridErrorIcon(isDark),
              size: 24,
            ),
            if (retry != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: retry,
                child: Text(
                  'Retry',
                  style: AppTheme.body(isDark).copyWith(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Async operation error boundary for handling repository and service errors
class AsyncErrorBoundary extends ConsumerWidget {
  final Future<Widget> Function() childBuilder;
  final String? operationContext;
  final VoidCallback? onRetry;

  const AsyncErrorBoundary({
    super.key,
    required this.childBuilder,
    this.operationContext,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Widget>(
      future: childBuilder(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error!;
          final stack = snapshot.stackTrace;

          // Log async errors
          debugPrint('AsyncErrorBoundary caught error in ${operationContext ?? 'async operation'}:');
          debugPrint('Error: $error');
          if (stack != null) {
            debugPrint('Stack: $stack');
          }

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.gridErrorIcon(isDark),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Operation failed',
                  style: AppTheme.bodyMedium(isDark),
                  textAlign: TextAlign.center,
                ),
                if (operationContext != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    operationContext!,
                    style: AppTheme.body(isDark).copyWith(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onRetry,
                    child: Text(
                      'Retry',
                      style: AppTheme.bodyMedium(isDark),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        // Show loading state
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

/// Error boundary specifically for image loading operations
class ImageErrorBoundary extends StatelessWidget {
  final Widget child;
  final String? imagePath;
  final VoidCallback? onRetry;

  const ImageErrorBoundary({
    super.key,
    required this.child,
    this.imagePath,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ErrorBoundary(
      errorContext: 'Image Loading${imagePath != null ? ' ($imagePath)' : ''}',
      showRetryButton: onRetry != null,
      onRetry: onRetry,
      errorBuilder: (error, stack, retry) => Container(
        color: AppColors.gridErrorBackground(isDark),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: AppColors.gridErrorIcon(isDark),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Image failed to load',
              style: AppTheme.body(isDark).copyWith(
                color: AppColors.textSecondary(isDark),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (retry != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: retry,
                child: Text(
                  'Retry',
                  style: AppTheme.bodyMedium(isDark),
                ),
              ),
            ],
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Extension methods for easier error boundary integration
extension ErrorBoundaryExtensions on Widget {
  /// Wrap widget with a basic error boundary
  Widget withErrorBoundary({
    String? context,
    bool showRetryButton = false,
    VoidCallback? onRetry,
  }) {
    return ErrorBoundary(
      errorContext: context,
      showRetryButton: showRetryButton,
      onRetry: onRetry,
      child: this,
    );
  }

  /// Wrap widget with grid item error boundary
  Widget withGridErrorBoundary({VoidCallback? onRetry}) {
    return GridItemErrorBoundary(
      onRetry: onRetry,
      child: this,
    );
  }

  /// Wrap widget with image error boundary
  Widget withImageErrorBoundary({
    String? imagePath,
    VoidCallback? onRetry,
  }) {
    return ImageErrorBoundary(
      imagePath: imagePath,
      onRetry: onRetry,
      child: this,
    );
  }
}

/// Global error handler for repository operations
class RepositoryErrorHandler {
  static T handleSyncOperation<T>(
      T Function() operation, {
        required T fallbackValue,
        String? context,
      }) {
    try {
      return operation();
    } catch (error, stack) {
      debugPrint('Repository error in ${context ?? 'unknown operation'}: $error');
      if (kDebugMode) {
        debugPrint('Stack: $stack');
      }
      return fallbackValue;
    }
  }

  static Future<T> handleAsyncOperation<T>(
      Future<T> Function() operation, {
        required T fallbackValue,
        String? context,
      }) async {
    try {
      return await operation();
    } catch (error, stack) {
      debugPrint('Async repository error in ${context ?? 'unknown operation'}: $error');
      if (kDebugMode) {
        debugPrint('Stack: $stack');
      }
      return fallbackValue;
    }
  }
}

/// Error boundary for database operations
class DatabaseErrorBoundary extends StatelessWidget {
  final Widget child;
  final String? operationName;

  const DatabaseErrorBoundary({
    super.key,
    required this.child,
    this.operationName,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorContext: 'Database${operationName != null ? ' ($operationName)' : ''}',
      child: child,
    );
  }
}