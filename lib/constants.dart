// lib/constants.dart

/// Global constants for the Grid photo gallery app
class Constants {
  // App Information
  static const String appName = 'Grid';

  // Cloud Backup Constants
  static const String defaultCloudFolderName = 'Grid';
  static const int manifestVersion = 1;
  static const int maxManifestSizeMB = 50;

  // Carousels (G-016): most photos one carousel holds
  static const int maxCarouselSlides = 20;

  // Performance Constants
  static const int defaultConcurrency = 2;
  static const int defaultChunkSize = 64 * 1024; // 64KB
  static const Duration defaultRetryDelay = Duration(seconds: 2);
  static const int maxRetries = 3;

  // Private constructor to prevent instantiation
  Constants._();
}