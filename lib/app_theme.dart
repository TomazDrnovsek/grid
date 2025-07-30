// File: lib/app_theme.dart
import 'package:flutter/material.dart';

// Central place for all our app's colors, based on the hand-off document.
class AppColors {
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF555555);
  static const Color backgroundDefault = Color(0xFFFFFFFF);
  static const Color brandPrimary = Color(0xFF7424FF);
  static const Color overlay80 = Color(0xCC111111);

  // ADDED: grid-specific colours
  static const Color gridDragPlaceholder = Color(0x4D9E9E9E);   // 30 % grey
  static const Color gridDragTargetBorder = Color(0xFF1E88E5);  // vibrant blue hover outline
  static const Color gridSelectionBorder = textPrimary;         // reuse near-black
  static const Color gridSelectionTickBg = textPrimary;         // same dark circle
  static const Color gridErrorBackground = Color(0xFFE0E0E0);   // grey-300 container
  static const Color gridErrorIcon = Color(0xFF9E9E9E);         // grey icon tint
  static const Color gridDragShadow = Color(0x4D000000);        // 30 % black shadow

}

// Central place for all our app's text styles.
class AppTextStyles {
  static const TextStyle headlineSm = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 19,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.57, // 3 % of 19 px
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
    color: AppColors.textSecondary,
    height: 20 / 14,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white,
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
    color: Colors.white,
    height: 1.29,
  );

}

// Light theme
ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundDefault,
    primaryColor: AppColors.brandPrimary,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.headlineSm,
      bodyMedium: AppTextStyles.body,
    ),
    useMaterial3: true,
  );
}

// ADDED: convenient re-exports
class AppTheme {
  static const TextStyle headlineSm = AppTextStyles.headlineSm;
  static const TextStyle body = AppTextStyles.body;
  static const TextStyle bodyMedium = AppTextStyles.bodyMedium;

  static const Color background = AppColors.backgroundDefault;
  static const Color primary = AppColors.brandPrimary;
}
