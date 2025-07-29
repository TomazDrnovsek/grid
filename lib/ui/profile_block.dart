import 'package:flutter/material.dart';
import 'package:grid/app_theme.dart'; // Import your custom theme file

/// ProfileBlock Widget: Displays the main user profile information.
/// This widget now uses styles from the app's central theme for consistency.
class ProfileBlock extends StatelessWidget {
  const ProfileBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CHANGED: use AppTheme style
          const Text('tomazdrnovsek', style: AppTheme.headlineSm),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/profile.jpg'),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tomaž Drnovšek',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Stat(label: 'posts', value: '327'),
                        SizedBox(width: 24),
                        Stat(label: 'followers', value: '3,333'),
                        SizedBox(width: 24),
                        Stat(label: 'following', value: '813'),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'From Ljubljana, Slovenia.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Stat Widget: A reusable component for displaying a value and a label (e.g., "327 posts").
class Stat extends StatelessWidget {
  final String label;
  final String value;

  const Stat({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
