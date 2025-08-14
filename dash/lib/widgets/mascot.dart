import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class Mascot extends StatelessWidget {
  final String mood; // 'idle' | 'cheer' | 'encourage' | 'celebrate'
  const Mascot({super.key, this.mood = 'idle'});

  @override
  Widget build(BuildContext context) {
    final double size = scaledFontSize(context, baseOnPhone: 100, maxOnDesktop: 160);
    // Placeholder box where Rive animation will be embedded later
    return Container(
      width: size,
      height: size,
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