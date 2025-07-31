// File: lib/ui/profile_block.dart
import 'package:flutter/material.dart';
import 'package:grid/app_theme.dart'; // Provides AppColors & AppTheme styles

/// Displays the main user profile information.
class ProfileBlock extends StatelessWidget {
  const ProfileBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/profile.jpg'),
                backgroundColor: AppColors.avatarPlaceholder,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tomaž Drnovšek', style: AppTheme.bodyMedium),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Stat(label: 'posts', value: '327'),
                        SizedBox(width: 24),
                        Stat(label: 'followers', value: '3,333'),
                        SizedBox(width: 24),
                        Stat(label: 'following', value: '813'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('From Ljubljana, Slovenia.', style: AppTheme.body),
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

  const Stat({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            value,
            style: AppTheme.statValue
        ),
        Text(
            label,
            style: AppTheme.statLabel
        ),
      ],
    );
  }
}