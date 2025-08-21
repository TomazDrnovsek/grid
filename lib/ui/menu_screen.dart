// File: lib/ui/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_theme.dart';
import '../core/app_config.dart';
import 'backup_settings_screen.dart';

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

                      // âœ… NEW: Cloud Backup settings entry (with feature flag check)
                      if (AppConfig.enableCloudBackup) ...[
                        const SizedBox(height: 24),
                        _MenuTile(
                          title: 'Cloud Backup',
                          subtitle: 'Backup photos to your cloud storage',
                          icon: Icons.cloud_outlined,
                          isDark: isDark,
                          onTap: () => _navigateToBackupSettings(context),
                        ),
                      ],

                      // Future menu items can be added here
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

  /// Navigate to backup settings screen with proper animation
  void _navigateToBackupSettings(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BackupSettingsScreen(themeNotifier: themeNotifier),
        transitionDuration: AppConfig().animationDuration,
        reverseTransitionDuration: AppConfig().animationDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic, // Smooth curve optimized for high refresh rate
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// Reusable menu tile widget for consistent styling
class _MenuTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _MenuTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.textSecondary(isDark).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.body(isDark).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTheme.body(isDark).copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow indicator
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary(isDark),
            ),
          ],
        ),
      ),
    );
  }
}