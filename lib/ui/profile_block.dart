import 'package:flutter/material.dart';
import 'package:grid/app_theme.dart'; // Import your custom theme file

/// ProfileBlock Widget: Displays the main user profile information.
/// This widget now uses styles from the app's central theme for consistency.
class ProfileBlock extends StatelessWidget {
  // Note: 'const' is removed because Theme.of(context) is not a compile-time constant.
  const ProfileBlock({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the text theme defined in your MaterialApp.
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username text, using the 'titleLarge' style from the theme.
          Text(
            'tomazdrnovsek',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 40,
                // This color is specific, so we can leave it hardcoded for now.
                backgroundColor: Color(0xFFE5D7F5),
              ),
              const SizedBox(width: 16),
              // Using Expanded to prevent potential overflow issues if names are long.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User's full name.
                    Text(
                      'Tomaž Drnovšek',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Row for stats.
                    const Row(
                      // Using MainAxisAlignment.spaceBetween could be an option for responsiveness.
                      // But for now, SizedBox keeps the exact spacing from your design.
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
          // User's location/bio text, using the 'bodyMedium' style from the theme.
          Text(
            'From Ljubljana, Slovenia.',
            style: textTheme.bodyMedium,
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

  // Note: 'const' is removed here as well.
  const Stat({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The stat value (e.g., "327").
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            // Using the primary text color from our custom AppColors.
            color: AppColors.textPrimary,
          ),
        ),
        // The stat label (e.g., "posts").
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            // Using the secondary text color for the label for subtle contrast.
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
