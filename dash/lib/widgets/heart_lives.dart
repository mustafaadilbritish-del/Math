import 'package:flutter/material.dart';

class HeartLives extends StatelessWidget {
  final int lives;
  final int maxLives;
  const HeartLives({super.key, required this.lives, this.maxLives = 3});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < maxLives; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.favorite,
                key: ValueKey('$i-$lives'),
                color: i < lives ? Colors.red : Colors.grey.shade400,
              ),
            ),
          ),
      ],
    );
  }
}