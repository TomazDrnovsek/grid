// File: lib/ui/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_theme.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
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
                  ),
                ),
                // Empty space to balance the layout (matching main screen structure)
                const SizedBox(width: 24),
              ],
            ),
          ),

          // Main content area (empty for now)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Column(
                children: [
                  SizedBox(height: 32), // Space from top navigation
                  // Future menu items will go here
                ],
              ),
            ),
          ),

          // Version number at bottom
          Container(
            padding: const EdgeInsets.only(bottom: 48, left: 16, right: 16),
            child: const Text(
              'Version 0.1',
              style: AppTheme.body,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}