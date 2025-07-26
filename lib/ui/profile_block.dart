import 'package:flutter/material.dart';

class ProfileBlock extends StatelessWidget {
  const ProfileBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'tomazdrnovsek',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE5D7F5),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tomaž Drnovšek',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Stat(label: 'posts', value: '327'),
                      SizedBox(width: 24),
                      Stat(label: 'followers', value: '3,333'),
                      SizedBox(width: 24),
                      Stat(label: 'following', value: '813'),
                    ],
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'From Ljubljana, Slovenia.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

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
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}