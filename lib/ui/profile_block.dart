// File: lib/ui/profile_block.dart
import 'package:flutter/material.dart';
import 'package:grid/app_theme.dart'; // Provides AppColors & AppTheme styles

/// Displays the main user profile information.
class ProfileBlock extends StatelessWidget {
  const ProfileBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: const AssetImage('assets/images/profile.jpg'),
                backgroundColor: AppColors.avatarPlaceholder(isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tomaž Drnovšek', style: AppTheme.bodyMedium(isDark)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Stat(label: 'posts', value: '327', isDark: isDark),
                        const SizedBox(width: 24),
                        Stat(label: 'followers', value: '3,333', isDark: isDark),
                        const SizedBox(width: 24),
                        Stat(label: 'following', value: '813', isDark: isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('From Ljubljana, Slovenia.', style: AppTheme.body(isDark)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Reusable value/label pair.
class Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const Stat({super.key, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            value,
            style: AppTheme.statValue(isDark)
        ),
        Text(
            label,
            style: AppTheme.statLabel(isDark)
        ),
      ],
    );
  }
}