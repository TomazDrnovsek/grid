import 'package:flutter/material.dart';
import 'package:grid/app_theme.dart';
import 'ui/splash_screen.dart';

void main() {
  runApp(const GridApp());
}

class GridApp extends StatelessWidget {
  const GridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      home: const SplashScreen(), // Start with splash screen
    );
  }
}