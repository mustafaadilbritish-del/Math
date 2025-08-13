import 'package:flutter/material.dart';

class Mascot extends StatelessWidget {
  final String mood; // 'idle' | 'cheer' | 'encourage' | 'celebrate'
  const Mascot({super.key, this.mood = 'idle'});

  @override
  Widget build(BuildContext context) {
    // Placeholder box where Rive animation will be embedded later
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      alignment: Alignment.center,
      child: Text(
        mood,
        style: const TextStyle(color: Colors.blueGrey),
      ),
    );
  }
}