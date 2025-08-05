// File: lib/services/image_processor_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../models/photo_state.dart';
import 'performance_monitor.dart';

/// High-performance image processing service using isolates
/// FIXED: Prevents UI thread blocking during heavy image compression operations
/// Now properly handles Flutter service dependencies by passing paths to isolates
class ImageProcessorService {
  static final ImageProcessorService _instance = ImageProcessorService._internal();
  factory ImageProcessorService() => _instance;
  ImageProcessorService._internal();

  /// Process a single image with thumbnail in background isolate
  /// FIXED: Now gets directory paths in main thread before isolate call
  Future<ProcessedImage> processImageInIsolate(XFile sourceFile) async {
    try {
      // Start performance monitoring
      PerformanceMonitor.instance.startOperation('isolate_image_processing');

      debugPrint('🔄 Starting isolate image processing for: ${sourceFile.path}');

      // FIXED: Get directory paths in main thread (where Flutter services work)
      final directories = await _getDirectoryPathsMainThread();

      // Prepare data for isolate (only primitives can be passed)
      final isolateData = IsolateImageData(
        sourcePath: sourceFile.path,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        imagesDir: directories['images']!,
        thumbnailsDir: directories['thumbnails']!,
      );

      // Run image processing in isolate using compute
      final result = await compute(_processImageInIsolate, isolateData);

      // End performance monitoring
      PerformanceMonitor.instance.endOperation('isolate_image_processing');

      debugPrint('✅ Isolate processing complete: ${result.image.path}');

      return result;

    } catch (e) {
      PerformanceMonitor.instance.endOperation('isolate_image_processing');
      debugPrint('❌ Error in isolate image processing: $e');
      rethrow;
    }
  }

  /// Process multiple images in parallel isolates with smart batching
  /// FIXED: Directory paths now handled properly for batch operations
  Future<BatchImageResult> processBatchImagesInIsolates(List<XFile> sourceFiles) async {
    if (sourceFiles.isEmpty) {
      return const BatchImageResult(
        processedImages: [],
        successCount: 0,
        failureCount: 0,
      );
    }

    try {
      // Start performance monitoring
      PerformanceMonitor.instance.startOperation('batch_isolate_processing');

      debugPrint('🔄 Starting batch isolate processing for ${sourceFiles.length} images');

      // FIXED: Get directory paths once in main thread for entire batch
      final directories = await _getDirectoryPathsMainThread();

      final List<ProcessedImage> processedImages = [];
      final List<String> errors = [];
      int successCount = 0;
      int failureCount = 0;

      // Process images in small batches to prevent system overload
      const batchSize = 3; // Process 3 images concurrently maximum

      for (int i = 0; i < sourceFiles.length; i += batchSize) {
        final endIndex = (i + batchSize).clamp(0, sourceFiles.length);
        final batch = sourceFiles.sublist(i, endIndex);

        debugPrint('Processing batch ${(i ~/ batchSize) + 1}/${(sourceFiles.length / batchSize).ceil()}: ${batch.length} images');

        // Process batch in parallel isolates
        final batchFutures = batch.map((file) async {
          try {
            // Create isolate data with pre-fetched directory paths
            final isolateData = IsolateImageData(
              sourcePath: file.path,
              timestamp: DateTime.now().millisecondsSinceEpoch,
              imagesDir: directories['images']!,
              thumbnailsDir: directories['thumbnails']!,
            );

            final result = await compute(_processImageInIsolate, isolateData);
            return ProcessingResult.success(result);
          } catch (e) {
            debugPrint('Batch processing error for ${file.path}: $e');
            return ProcessingResult.error(e.toString());
          }
        });

        // Wait for batch completion
        final batchResults = await Future.wait(batchFutures);

        // Process batch results
        for (final result in batchResults) {
          if (result.isSuccess) {
            processedImages.add(result.processedImage!);
            successCount++;
          } else {
            errors.add(result.error!);
            failureCount++;
          }
        }

        // Small delay between batches to prevent overwhelming the system
        if (i + batchSize < sourceFiles.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      // End performance monitoring
      PerformanceMonitor.instance.endOperation('batch_isolate_processing');

      debugPrint('✅ Batch isolate processing complete: $successCount success, $failureCount failed');

      return BatchImageResult(
        processedImages: processedImages,
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );

    } catch (e) {
      PerformanceMonitor.instance.endOperation('batch_isolate_processing');
      debugPrint('❌ Error in batch isolate processing: $e');

      return BatchImageResult(
        processedImages: const [],
        successCount: 0,
        failureCount: sourceFiles.length,
        errors: ['Batch processing failed: $e'],
      );
    }
  }

  /// Generate thumbnail in isolate for existing image
  /// FIXED: Directory paths handled in main thread
  Future<File> generateThumbnailInIsolate(String imagePath) async {
    try {
      // Start performance monitoring
      PerformanceMonitor.instance.startOperation('isolate_thumbnail_generation');

      debugPrint('🔄 Generating thumbnail in isolate for: $imagePath');

      // FIXED: Get directory paths in main thread
      final directories = await _getDirectoryPathsMainThread();

      // Prepare data for isolate
      final isolateData = ThumbnailIsolateData(
        imagePath: imagePath,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnailsDir: directories['thumbnails']!,
      );

      // Generate thumbnail in isolate
      final thumbnailPath = await compute(_generateThumbnailInIsolate, isolateData);

      // End performance monitoring
      PerformanceMonitor.instance.endOperation('isolate_thumbnail_generation');

      final thumbnailFile = File(thumbnailPath);
      debugPrint('✅ Thumbnail generated in isolate: $thumbnailPath');

      return thumbnailFile;

    } catch (e) {
      PerformanceMonitor.instance.endOperation('isolate_thumbnail_generation');
      debugPrint('❌ Error generating thumbnail in isolate: $e');
      rethrow;
    }
  }

  /// FIXED: Get directory paths in main thread where Flutter services are available
  Future<Map<String, String>> _getDirectoryPathsMainThread() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${docsDir.path}/images');
      final thumbsDir = Directory('${docsDir.path}/thumbnails');

      // Create directories if they don't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      if (!await thumbsDir.exists()) {
        await thumbsDir.create(recursive: true);
      }

      return {
        'images': imagesDir.path,
        'thumbnails': thumbsDir.path,
      };
    } catch (e) {
      debugPrint('Error getting directory paths in main thread: $e');
      rethrow;
    }
  }
}

/// Static function that runs in isolate for image processing
/// FIXED: Now receives directory paths as parameters instead of calling Flutter services
Future<ProcessedImage> _processImageInIsolate(IsolateImageData data) async {
  try {
    // Generate file paths with timestamp using provided directory paths
    final imagePath = '${data.imagesDir}/IMG_${data.timestamp}.jpg';
    final thumbPath = '${data.thumbnailsDir}/THUMB_${data.timestamp}.jpg';

    // Verify source file exists
    final sourceFile = File(data.sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source file does not exist: ${data.sourcePath}');
    }

    // Process full-resolution image
    final imageResult = await FlutterImageCompress.compressAndGetFile(
      data.sourcePath,
      imagePath,
      minWidth: 1080,
      quality: 85,
      autoCorrectionAngle: true,
      keepExif: true,
    );

    if (imageResult == null) {
      throw Exception('Failed to compress full image');
    }

    // Process thumbnail
    final thumbResult = await FlutterImageCompress.compressAndGetFile(
      data.sourcePath,
      thumbPath,
      minWidth: 360,
      quality: 85,
      autoCorrectionAngle: true,
      keepExif: false,
    );

    if (thumbResult == null) {
      // Clean up full image if thumbnail fails
      try {
        await File(imageResult.path).delete();
      } catch (e) {
        debugPrint('Failed to clean up full image after thumbnail failure: $e');
      }
      throw Exception('Failed to generate thumbnail');
    }

    // Verify both files were created
    final imageFile = File(imageResult.path);
    final thumbFile = File(thumbResult.path);

    if (!await imageFile.exists() || !await thumbFile.exists()) {
      throw Exception('Processed files were not created successfully');
    }

    // Verify file sizes are reasonable
    final imageSize = await imageFile.length();
    final thumbSize = await thumbFile.length();

    if (imageSize == 0 || thumbSize == 0) {
      throw Exception('Processed files are empty');
    }

    debugPrint('Isolate processed: Image ${(imageSize / 1024).round()}KB, Thumb ${(thumbSize / 1024).round()}KB');

    return ProcessedImage(
      image: imageFile,
      thumbnail: thumbFile,
    );

  } catch (e) {
    debugPrint('Error in isolate image processing: $e');
    rethrow;
  }
}

/// Static function that runs in isolate for thumbnail generation
/// FIXED: Now receives thumbnail directory path as parameter
Future<String> _generateThumbnailInIsolate(ThumbnailIsolateData data) async {
  try {
    // Generate thumbnail path using provided directory path
    final thumbPath = '${data.thumbnailsDir}/THUMB_${data.timestamp}.jpg';

    // Verify source image exists
    final sourceFile = File(data.imagePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source image does not exist: ${data.imagePath}');
    }

    // Generate thumbnail
    final thumbResult = await FlutterImageCompress.compressAndGetFile(
      data.imagePath,
      thumbPath,
      minWidth: 360,
      quality: 85,
      autoCorrectionAngle: true,
      keepExif: false,
    );

    if (thumbResult == null) {
      throw Exception('Failed to generate thumbnail');
    }

    // Verify thumbnail was created
    final thumbFile = File(thumbResult.path);
    if (!await thumbFile.exists()) {
      throw Exception('Thumbnail file was not created');
    }

    final thumbSize = await thumbFile.length();
    if (thumbSize == 0) {
      throw Exception('Thumbnail file is empty');
    }

    debugPrint('Isolate generated thumbnail: ${(thumbSize / 1024).round()}KB');

    return thumbResult.path;

  } catch (e) {
    debugPrint('Error in isolate thumbnail generation: $e');
    rethrow;
  }
}

/// FIXED: Data class for passing image data to isolate (now includes directory paths)
class IsolateImageData {
  final String sourcePath;
  final int timestamp;
  final String imagesDir;
  final String thumbnailsDir;

  const IsolateImageData({
    required this.sourcePath,
    required this.timestamp,
    required this.imagesDir,
    required this.thumbnailsDir,
  });
}

/// FIXED: Data class for passing thumbnail data to isolate (now includes directory path)
class ThumbnailIsolateData {
  final String imagePath;
  final int timestamp;
  final String thumbnailsDir;

  const ThumbnailIsolateData({
    required this.imagePath,
    required this.timestamp,
    required this.thumbnailsDir,
  });
}

/// Result wrapper for batch processing
class ProcessingResult {
  final bool isSuccess;
  final ProcessedImage? processedImage;
  final String? error;

  const ProcessingResult._({
    required this.isSuccess,
    this.processedImage,
    this.error,
  });

  factory ProcessingResult.success(ProcessedImage processedImage) {
    return ProcessingResult._(
      isSuccess: true,
      processedImage: processedImage,
    );
  }

  factory ProcessingResult.error(String error) {
    return ProcessingResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// Performance monitoring integration for isolate operations
class IsolatePerformanceTracker {
  static void trackIsolateOperation(String operationName, Future<void> Function() operation) async {
    try {
      PerformanceMonitor.instance.startOperation('${operationName}_isolate');
      await operation();
      PerformanceMonitor.instance.endOperation('${operationName}_isolate');
    } catch (e) {
      PerformanceMonitor.instance.endOperation('${operationName}_isolate');
      rethrow;
    }
  }
}