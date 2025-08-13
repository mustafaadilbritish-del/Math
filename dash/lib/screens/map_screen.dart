import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../models/progress_models.dart';
import 'lesson_screen.dart';

class MapScreen extends ConsumerWidget {
  static const routeName = '/map';
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressMapProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Path'),
        actions: [
          IconButton(
            icon: Icon(settings.animationsEnabled ? Icons.animation : Icons.animation_outlined),
            onPressed: () => ref.read(appSettingsProvider.notifier).state = settings.copyWith(
                  animationsEnabled: !settings.animationsEnabled,
                ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            for (int t = 2; t <= 12; t++)
              _LessonNode(
                label: 'x$t',
                progress: ref.read(progressMapProvider.notifier).getProgress(t, false),
                onTap: () => Navigator.of(context).pushNamed(
                  LessonScreen.routeName,
                  arguments: LessonArgs(table: t, isDivision: false),
                ),
              ),
            for (int t = 2; t <= 12; t++)
              _LessonNode(
                label: '÷$t',
                progress: ref.read(progressMapProvider.notifier).getProgress(t, true),
                onTap: () => Navigator.of(context).pushNamed(
                  LessonScreen.routeName,
                  arguments: LessonArgs(table: t, isDivision: true),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  final String label;
  final LessonProgress progress;
  final VoidCallback onTap;
  const _LessonNode({required this.label, required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.orange.shade300, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Icon(
                    i < progress.starsEarned ? Icons.star : Icons.star_border,
                    color: Colors.yellow.shade100,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Best ${progress.bestStreak}', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}