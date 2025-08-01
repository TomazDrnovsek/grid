// File: lib/app_theme.dart
import 'package:flutter/material.dart';

// Central place for all our app's colors, based on the hand-off document.
class AppColors {
  // Light theme colors
  static const Color scaffoldBackgroundLight = Color(0xFFFFFFFF);
  static const Color bottomBarBackgroundLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111111);
  static const Color textSecondaryLight = Color(0xFF555555);
  static const Color backgroundDefaultLight = Color(0xFFFFFFFF);

  // Dark theme colors (to be implemented)
  static const Color scaffoldBackgroundDark = Color(0xFF1A1A1A);
  static const Color bottomBarBackgroundDark = Color(0xFF1A1A1A);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color backgroundDefaultDark = Color(0xFF1A1A1A);

  // Current theme colors (will be dynamic later)
  static const Color scaffoldBackground = scaffoldBackgroundLight;
  static const Color bottomBarBackground = bottomBarBackgroundLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color backgroundDefault = backgroundDefaultLight;

  // Brand and constant colors (same in both themes)
  static const Color brandPrimary = Color(0xFF7424FF);
  static const Color overlay80 = Color(0xCC111111);

  // Grid-specific colours
  static const Color gridDragPlaceholder = Color(0x4D9E9E9E);   // 30% grey
  static const Color gridDragTargetBorder = Color(0xFF1E88E5);  // vibrant blue hover outline
  static const Color gridSelectionBorder = textPrimary;         // reuse near-black
  static const Color gridSelectionTickBg = textPrimary;         // same dark circle
  static const Color gridErrorBackground = Color(0xFFE0E0E0);   // grey-300 container
  static const Color gridErrorIcon = Color(0xFF9E9E9E);         // grey icon tint
  static const Color gridDragShadow = Color(0x4D000000);        // 30% black shadow
  static const Color sheetDivider = Color(0xFFF7F7F7);          // very-light grey
  static const Color avatarPlaceholder = Color(0xFF9E9E9E);     // medium grey

  // Delete modal specific colours
  static const Color modalOverlayBackground = Color(0xCC111111); // 80% opaque black
  static const Color modalContentBackground = Color(0xFFFFFFFF); // White background for the modal content
  static const Color cancelButtonBackground = Color(0xFFE0E0E0); // Light gray for Cancel button background
  static const Color deleteButtonBackground = Color(0xFF000000); // Black for Delete button background
  static const Color deleteButtonText = Color(0xFFFFFFFF);       // White text for Delete button
  static const Color deleteButtonOverlay = Color(0x1AFFFFFF);    // 10% opaque white

  // Image preview modal colors
  static const Color imagePreviewOverlay = Color(0xC8000000);    // ~78% black opacity
  static const Color imagePreviewErrorIcon = Color(0xFFFFFFFF);  // White for error icon
  static const Color imagePreviewErrorText = Color(0xFFFFFFFF);  // White for error text

  // Splash screen colors
  static const Color splashBackground = Color(0xFF1A1A1A);       // Dark background

  // Switch/Toggle colors
  static const Color switchTrackOutline = Colors.transparent;    // No outline
  static const Color switchInactiveTrack = Color(0x4D555555);    // 30% opacity secondary text

  // Pure colors for situations requiring absolute values
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureTransparent = Colors.transparent;
}

// Central place for all our app's text styles and other theme properties.
class AppTheme {
  // Main text styles
  static const TextStyle headlineSm = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 19,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.57, // 3% of 19px
    color: AppColors.textPrimary,
    height: 1,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 20 / 14,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 20 / 14,
  );

  static const TextStyle statValue = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 20 / 14,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 20 / 14,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
  );

  static const TextStyle dialogActionPrimary = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.29,
  );

  static const TextStyle dialogActionDanger = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.pureWhite,
    height: 1.29,
  );

  // Image preview error text style
  static const TextStyle imagePreviewError = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.imagePreviewErrorText,
    height: 1.4,
  );

  // Expose colors directly through AppTheme for consistency
  static const Color background = AppColors.backgroundDefault;
  static const Color primary = AppColors.brandPrimary;

  // Switch styling properties
  static WidgetStateProperty<Color> get switchTrackOutlineColor =>
      WidgetStateProperty.all(AppColors.switchTrackOutline);
}

// Light theme
ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundDefault,
    primaryColor: AppColors.brandPrimary,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      titleLarge: AppTheme.headlineSm,
      bodyMedium: AppTheme.body,
    ),
    useMaterial3: true,
  );
}

// Dark theme (placeholder for future implementation)
ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.scaffoldBackgroundDark,
    primaryColor: AppColors.brandPrimary,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      titleLarge: AppTheme.headlineSm,
      bodyMedium: AppTheme.body,
    ),
    useMaterial3: true,
  );
}