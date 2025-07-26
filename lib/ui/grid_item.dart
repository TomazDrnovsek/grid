import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  final int index;
  const GridItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://placehold.co/118x157?text=${index + 1}'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}