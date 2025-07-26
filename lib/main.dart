import 'package:flutter/material.dart';
import 'package:grid/app_theme.dart'; // Import your new theme file
import 'ui/grid_home.dart';

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
      theme: buildLightTheme(), // Use our custom light theme
      home: const GridHomePage(),
    );
  }
}