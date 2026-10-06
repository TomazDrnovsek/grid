// File: lib/ui/how_to_use_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_theme.dart';

class HowToUseScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const HowToUseScreen({super.key, required this.themeNotifier});

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar (same structure as backup_settings_screen)
            Container(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
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
                  // Screen title
                  Text(
                    'How to Use Grid',
                    style: AppTheme.headlineSm(isDark),
                  ),
                  // Spacer to balance layout
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Getting Started section
                    _buildSectionTitle('Getting Started', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Adding Photos', isDark),
                    const SizedBox(height: 8),
                    _buildBodyText(
                      'Tap the + button in the top bar to select photos from your gallery. You can select multiple photos at once. Photos are automatically optimized and added to your grid.',
                      isDark,
                    ),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Adding a Carousel', isDark),
                    const SizedBox(height: 8),
                    _buildBodyText(
                      'A carousel puts up to 20 photos on one tile, like a carousel post.',
                      isDark,
                    ),
                    _buildBulletText('Tap + and pick two or more photos, in the order you want them', isDark),
                    _buildBulletText('Choose Carousel to add them as one tile, or Separate to give each photo its own tile', isDark),
                    _buildBulletText('The first photo you picked is the cover shown on the grid', isDark),
                    _buildBulletText('Carousel tiles show a carousel icon in the top right corner', isDark),
                    _buildBulletText('Tap outside the choice to cancel without adding anything', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Organizing Your Grid', isDark),
                    const SizedBox(height: 8),
                    _buildBodyText(
                      'Long press any photo and drag it to a new position. The grid will automatically adjust. Your arrangement saves automatically.',
                      isDark,
                    ),
                    const SizedBox(height: 24),

                    // Working with Photos section
                    _buildSectionTitle('Working with Photos', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Selecting Photos', isDark),
                    const SizedBox(height: 8),
                    _buildBulletText('Single tap to select or deselect a photo', isDark),
                    _buildBulletText('Long press to quickly enter selection mode', isDark),
                    _buildBulletText('Selected photos show a checkmark indicator', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Deleting Photos', isDark),
                    const SizedBox(height: 8),
                    _buildBulletText('Select photos you want to remove', isDark),
                    _buildBulletText('Tap the trash icon in the bottom bar', isDark),
                    _buildBulletText('Confirm deletion in the popup dialog', isDark),
                    _buildBulletText('Deleting a carousel deletes all its photos', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Sharing Photos', isDark),
                    const SizedBox(height: 8),
                    _buildBulletText('Select a single photo', isDark),
                    _buildBulletText('Tap the share icon in the bottom bar', isDark),
                    _buildBulletText('Choose your sharing destination', isDark),
                    _buildBulletText('A selected carousel shares all its photos at once', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Previewing Photos', isDark),
                    const SizedBox(height: 8),
                    _buildBodyText(
                      'Double tap any photo to view it full-screen. On a carousel, swipe left and right to see each photo; the counter in the corner shows which one you are on. Tap anywhere to close the preview.',
                      isDark,
                    ),
                    const SizedBox(height: 24),

                    // Advanced Features section
                    _buildSectionTitle('Advanced Features', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Color Visualization (Hue Map)', isDark),
                    const SizedBox(height: 8),
                    _buildBodyText(
                      'Toggle the ink icon in the bottom bar to overlay dominant colors on your photos. Useful for planning color-coordinated layouts.',
                      isDark,
                    ),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Profile Customization', isDark),
                    const SizedBox(height: 8),
                    _buildBodyText(
                      'Tap any field in your profile section to edit:',
                      isDark,
                    ),
                    _buildBulletText('Username', isDark),
                    _buildBulletText('Profile photo (tap avatar)', isDark),
                    _buildBulletText('Posts, followers, following counts', isDark),
                    _buildBulletText('Bio text', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Theme Switching', isDark),
                    const SizedBox(height: 8),
                    _buildBulletText('Tap the menu icon (three lines)', isDark),
                    _buildBulletText('Toggle the Appearance switch', isDark),
                    _buildBulletText('Choose between light and dark modes', isDark),
                    const SizedBox(height: 24),

                    // Backup & Restore section
                    _buildSectionTitle('Backup & Restore', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Creating a Backup', isDark),
                    const SizedBox(height: 8),
                    _buildBulletText('Open Menu → Settings', isDark),
                    _buildBulletText('Choose backup location on your device', isDark),
                    _buildBulletText('Tap Backup to save your photos and data', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Restoring from Backup', isDark),
                    const SizedBox(height: 8),
                    _buildBulletText('Open Menu → Settings', isDark),
                    _buildBulletText('Select your backup folder', isDark),
                    _buildBulletText('Tap Restore to recover your photos', isDark),
                    const SizedBox(height: 24),

                    // Navigation section
                    _buildSectionTitle('Navigation', isDark),
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Quick Actions', isDark),
                    const SizedBox(height: 8),
                    _buildBulletText('Home icon: Instantly scroll to top of grid', isDark),
                    _buildBulletText('Empty area tap: Clear all selections', isDark),
                    _buildBulletText('Back gesture: Exit menus or cancel operations', isDark),
                    const SizedBox(height: 24),

                    // Performance Tips section
                    _buildSectionTitle('Performance Tips', isDark),
                    const SizedBox(height: 16),
                    _buildBulletText('Grid automatically manages memory', isDark),
                    _buildBulletText('Thumbnails load as needed for smooth scrolling', isDark),
                    _buildBulletText('Large imports process in the background', isDark),
                    const SizedBox(height: 24),

                    // Tips section
                    _buildSectionTitle('Tips', isDark),
                    const SizedBox(height: 16),
                    _buildBulletText('Your photos never leave your device', isDark),
                    _buildBulletText('All changes save automatically', isDark),
                    _buildBulletText('Drag photos to screen edges to auto-scroll', isDark),
                    _buildBulletText('The app works completely offline', isDark),
                    _buildBulletText('No account or sign-up required', isDark),
                    const SizedBox(height: 16),

                    _buildBodyText(
                      'Need help? Contact: tomaz.drnovsek@gmail.com',
                      isDark,
                    ),

                    // Bottom spacer
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// Build section title using existing AppTheme styles
  Widget _buildSectionTitle(String text, bool isDark) {
    return Text(
      text,
      style: AppTheme.headlineSm(isDark),
    );
  }

  /// Build subsection title using existing AppTheme styles
  Widget _buildSubSectionTitle(String text, bool isDark) {
    return Text(
      text,
      style: AppTheme.bodyMedium(isDark),
    );
  }

  /// Build body text using existing AppTheme styles
  Widget _buildBodyText(String text, bool isDark) {
    return Text(
      text,
      style: AppTheme.body(isDark),
    );
  }

  /// Build bullet point text using existing AppTheme styles
  Widget _buildBulletText(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTheme.body(isDark).copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.body(isDark),
            ),
          ),
        ],
      ),
    );
  }
}