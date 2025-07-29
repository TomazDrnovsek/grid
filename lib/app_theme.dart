import 'package:flutter/material.dart';

// Central place for all our app's colors, based on the handoff document.
class AppColors {
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF555555);
  static const Color backgroundDefault = Color(0xFFFFFFFF);
  static const Color brandPrimary = Color(0xFF7424FF);
  // Add other colors from your handoff here as needed.

  // ADDED: Modal overlay color (80% opacity black)
  static const Color overlay80 = Color(0xCC111111);
}

// Central place for all our app's text styles.
class AppTextStyles {
  // CHANGED: 19px bold with 3% letter spacing
  static const TextStyle headlineSm = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 19,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.57,
    color: AppColors.textPrimary,
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
    fontWeight: FontWeight.w500, // Medium weight
    color: AppColors.textPrimary,
    height: 20 / 14,
  );

// Add other text styles from your handoff here as needed.
}

// The main theme data for the app
ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundDefault,
    primaryColor: AppColors.brandPrimary,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      // Headline Small from your handoff
      titleLarge: AppTextStyles.headlineSm,
      // Body from your handoff
      bodyMedium: AppTextStyles.body,
    ),
    useMaterial3: true,
  );
}

// ADDED: Expose styles and colors for widget use
class AppTheme {
  static const TextStyle headlineSm = AppTextStyles.headlineSm;
  static const TextStyle body = AppTextStyles.body;
  static const TextStyle bodyMedium = AppTextStyles.bodyMedium;

  static const Color background = AppColors.backgroundDefault;
  static const Color primary = AppColors.brandPrimary;
}
