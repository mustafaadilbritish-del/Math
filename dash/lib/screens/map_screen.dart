import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../models/progress_models.dart';
import '../utils/responsive.dart';
import 'lesson_screen.dart';

class MapScreen extends ConsumerWidget {
  static const routeName = '/map';
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(progressMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: constrainedBody(
        child: Padding(
          padding: pagePadding(context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = gridCountForMaxWidth(
                constraints.maxWidth,
                phone: 3,
                tablet: 4,
                desktop: 6,
                largeDesktop: 8,
              );
                             return GridView.count(
                 crossAxisCount: crossAxisCount,
                 childAspectRatio: isPhone(context) ? 1.0 : 1.2,
                 crossAxisSpacing: isPhone(context) ? 8 : 12,
                 mainAxisSpacing: isPhone(context) ? 8 : 12,
                 children: [
                   for (int t = 2; t <= 12; t++)
                     _LessonNode(
                       label: '×$t',
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
               );
            },
          ),
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
                        Text(label, style: TextStyle(fontSize: scaledFontSize(context, baseOnPhone: 22, maxOnDesktop: 32), fontWeight: FontWeight.bold, color: Colors.white)),
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
            Text('Best: ${progress.bestStreak}', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}