import 'package:flutter/material.dart';

class FabAddButton extends StatelessWidget {
  const FabAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Image.asset(
        'assets/add_button.png',
        fit: BoxFit.contain,
      ),
    );
  }
}