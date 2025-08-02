// File: lib/app_theme.dart
import 'package:flutter/material.dart';

// Theme mode notifier to manage app-wide theme state
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}

// Central place for all our app's colors, based on the hand-off document.
class AppColors {
  // Light theme colors
  static const Color scaffoldBackgroundLight = Color(0xFFFFFFFF);
  static const Color bottomBarBackgroundLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111111);
  static const Color textSecondaryLight = Color(0xFF555555);
  static const Color backgroundDefaultLight = Color(0xFFFFFFFF);

  // Dark theme colors - Following industry best practices
  static const Color scaffoldBackgroundDark = Color(0xFF121212);      // Material Design dark surface
  static const Color bottomBarBackgroundDark = Color(0xFF1E1E1E);     // Elevated surface
  static const Color textPrimaryDark = Color(0xFFE1E1E1);             // High emphasis text
  static const Color textSecondaryDark = Color(0xFFB3B3B3);           // Medium emphasis text
  static const Color backgroundDefaultDark = Color(0xFF121212);       // Base dark surface

  // Method to get colors based on theme mode
  static Color scaffoldBackground(bool isDark) => isDark ? scaffoldBackgroundDark : scaffoldBackgroundLight;
  static Color bottomBarBackground(bool isDark) => isDark ? bottomBarBackgroundDark : bottomBarBackgroundLight;
  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color backgroundDefault(bool isDark) => isDark ? backgroundDefaultDark : backgroundDefaultLight;

  // Brand and constant colors (same in both themes)
  static const Color brandPrimary = Color(0xFF7424FF);
  static const Color overlay80 = Color(0xCC111111);

  // Grid-specific colours - Dark mode variants
  static const Color gridDragPlaceholderLight = Color(0x4D9E9E9E);
  static const Color gridDragPlaceholderDark = Color(0x4D666666);
  static Color gridDragPlaceholder(bool isDark) => isDark ? gridDragPlaceholderDark : gridDragPlaceholderLight;

  static const Color gridDragTargetBorder = Color(0xFF1E88E5);  // Same in both themes - brand color

  // UPDATED: Selected image border - white in dark mode, black in light mode
  static Color gridSelectionBorder(bool isDark) => isDark ? pureWhite : textPrimaryLight;
  static Color gridSelectionTickBg(bool isDark) => textPrimaryLight; // Always black circle

  static const Color gridErrorBackgroundLight = Color(0xFFE0E0E0);
  static const Color gridErrorBackgroundDark = Color(0xFF2C2C2C);
  static Color gridErrorBackground(bool isDark) => isDark ? gridErrorBackgroundDark : gridErrorBackgroundLight;

  static const Color gridErrorIconLight = Color(0xFF9E9E9E);
  static const Color gridErrorIconDark = Color(0xFF707070);
  static Color gridErrorIcon(bool isDark) => isDark ? gridErrorIconDark : gridErrorIconLight;

  static const Color gridDragShadow = Color(0x4D000000);        // Same in both themes

  static const Color sheetDividerLight = Color(0xFFF7F7F7);
  static const Color sheetDividerDark = Color(0xFF2C2C2C);
  static Color sheetDivider(bool isDark) => isDark ? sheetDividerDark : sheetDividerLight;

  static const Color avatarPlaceholderLight = Color(0xFF9E9E9E);
  static const Color avatarPlaceholderDark = Color(0xFF666666);
  static Color avatarPlaceholder(bool isDark) => isDark ? avatarPlaceholderDark : avatarPlaceholderLight;

  // UPDATED: Delete modal specific colours - new dark mode styling
  static const Color modalOverlayBackgroundLight = Color(0xCC111111);
  static const Color modalOverlayBackgroundDark = Color(0xCC000000);
  static Color modalOverlayBackground(bool isDark) => isDark ? modalOverlayBackgroundDark : modalOverlayBackgroundLight;

  static const Color modalContentBackgroundLight = Color(0xFFFFFFFF);
  static const Color modalContentBackgroundDark = Color(0xFF000000);  // UPDATED: Pure black
  static Color modalContentBackground(bool isDark) => isDark ? modalContentBackgroundDark : modalContentBackgroundLight;

  static const Color cancelButtonBackgroundLight = Color(0xFFE0E0E0);
  static const Color cancelButtonBackgroundDark = Color(0xFF222222);  // UPDATED: Dark gray
  static Color cancelButtonBackground(bool isDark) => isDark ? cancelButtonBackgroundDark : cancelButtonBackgroundLight;

  static const Color deleteButtonBackgroundLight = Color(0xFF000000); // Black in light mode
  static const Color deleteButtonBackgroundDark = Color(0xFFFFFFFF);  // UPDATED: White in dark mode
  static Color deleteButtonBackground(bool isDark) => isDark ? deleteButtonBackgroundDark : deleteButtonBackgroundLight;

  static const Color deleteButtonTextLight = Color(0xFFFFFFFF);       // White text in light mode
  static const Color deleteButtonTextDark = Color(0xFF000000);        // UPDATED: Black text in dark mode
  static Color deleteButtonText(bool isDark) => isDark ? deleteButtonTextDark : deleteButtonTextLight;

  static const Color deleteButtonOverlayLight = Color(0x1AFFFFFF);    // Light overlay in light mode
  static const Color deleteButtonOverlayDark = Color(0x1A000000);     // UPDATED: Dark overlay in dark mode
  static Color deleteButtonOverlay(bool isDark) => isDark ? deleteButtonOverlayDark : deleteButtonOverlayLight;

  // Image preview modal colors (same in both themes - always dark overlay)
  static const Color imagePreviewOverlay = Color(0xC8000000);    // ~78% black opacity
  static const Color imagePreviewErrorIcon = Color(0xFFFFFFFF);  // White for error icon
  static const Color imagePreviewErrorText = Color(0xFFFFFFFF);  // White for error text

  // Splash screen colors (unchanged - always dark)
  static const Color splashBackground = Color(0xFF1A1A1A);       // Dark background

  // UPDATED: Switch/Toggle colors - new styling
  static const Color switchTrackOutline = Colors.transparent;    // No outline
  static const Color switchInactiveTrackLight = Color(0xFFF0F0F0);  // UPDATED: Light gray
  static const Color switchInactiveTrackDark = Color(0xFF222222);   // UPDATED: Dark gray
  static Color switchInactiveTrack(bool isDark) => isDark ? switchInactiveTrackDark : switchInactiveTrackLight;

  static const Color switchInactiveThumbLight = Color(0xFF000000);  // UPDATED: Black circle
  static const Color switchInactiveThumbDark = Color(0xFFFFFFFF);   // UPDATED: White circle
  static Color switchInactiveThumb(bool isDark) => isDark ? switchInactiveThumbDark : switchInactiveThumbLight;

  // Pure colors for situations requiring absolute values
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureTransparent = Colors.transparent;
}

// Central place for all our app's text styles and other theme properties.
class AppTheme {
  // Main text styles - Now take isDark parameter
  static TextStyle headlineSm(bool isDark) => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 19,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.57, // 3% of 19px
    color: AppColors.textPrimary(isDark),
    height: 1,
  );

  static TextStyle body(bool isDark) => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary(isDark),
    height: 20 / 14,
  );

  static TextStyle bodyMedium(bool isDark) => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary(isDark),
    height: 20 / 14,
  );

  static TextStyle statValue(bool isDark) => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary(isDark),
    height: 20 / 14,
  );

  static TextStyle statLabel(bool isDark) => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary(isDark),
    height: 20 / 14,
  );

  static TextStyle dialogTitle(bool isDark) => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary(isDark),
    height: 1.4,
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
  );

  static TextStyle dialogActionPrimary(bool isDark) => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary(isDark),
    height: 1.29,
  );

  // UPDATED: Delete button text style - adapts to theme
  static TextStyle dialogActionDanger(bool isDark) => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.deleteButtonText(isDark),
    height: 1.29,
  );

  // Image preview error text style (always white on dark overlay)
  static const TextStyle imagePreviewError = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.imagePreviewErrorText,
    height: 1.4,
  );

  // UPDATED: Switch styling properties - new custom styling
  static WidgetStateProperty<Color> get switchTrackOutlineColor =>
      WidgetStateProperty.all(AppColors.switchTrackOutline);

  static WidgetStateProperty<Color> switchThumbColor(bool isDark) =>
      WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.textPrimary(isDark);  // Active thumb color
        }
        return AppColors.switchInactiveThumb(isDark);  // Inactive thumb color
      });

  static WidgetStateProperty<Color> switchTrackColor(bool isDark) =>
      WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        return AppColors.switchInactiveTrack(isDark);  // Same track color always
      });
}

// Light theme
ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundDefaultLight,
    primaryColor: AppColors.brandPrimary,
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      titleLarge: AppTheme.headlineSm(false),
      bodyMedium: AppTheme.body(false),
    ),
    useMaterial3: true,
  );
}

// Dark theme
ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDefaultDark,
    primaryColor: AppColors.brandPrimary,
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      titleLarge: AppTheme.headlineSm(true),
      bodyMedium: AppTheme.body(true),
    ),
    useMaterial3: true,
  );
}