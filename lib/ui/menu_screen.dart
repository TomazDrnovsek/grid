// File: lib/ui/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_theme.dart';

class MenuScreen extends StatelessWidget {
  final ThemeNotifier themeNotifier;

  const MenuScreen({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground(isDark),
          body: Column(
            children: [
              // Top navigation bar matching main screen layout
              Container(
                padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back arrow
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/arrow_left.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          AppColors.textPrimary(isDark),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    // Empty space to balance the layout (matching main screen structure)
                    const SizedBox(width: 24),
                  ],
                ),
              ),

              // Main content area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 32), // Space from top navigation

                      // Appearance toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Appearance',
                            style: AppTheme.body(isDark),
                          ),
                          Switch(
                            value: themeNotifier.isDarkMode,
                            onChanged: (value) {
                              themeNotifier.toggleTheme();
                            },
                            activeColor: AppColors.textPrimary(isDark),
                            inactiveThumbColor: AppColors.textSecondary(isDark),
                            inactiveTrackColor: AppColors.switchInactiveTrack(isDark),
                            trackOutlineColor: AppTheme.switchTrackOutlineColor,
                          ),
                        ],
                      ),

                      // Future menu items will go here
                    ],
                  ),
                ),
              ),

              // Version number at bottom
              Container(
                padding: const EdgeInsets.only(bottom: 48, left: 16, right: 16),
                child: Text(
                  'Version 0.1',
                  style: AppTheme.body(isDark),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}