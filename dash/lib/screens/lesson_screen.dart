import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../utils/responsive.dart';

class LessonArgs {
  final int table;
  final bool isDivision;
  const LessonArgs({required this.table, required this.isDivision});
}

class LessonScreen extends ConsumerStatefulWidget {
  static const routeName = '/lesson';
  const LessonScreen({super.key});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  static const int questionsPerLesson = 10;
  static const int livesMax = 3;

  late int table;
  late bool isDivision;
  int currentQuestionIndex = 0;
  int currentLeft = 2;
  int currentRight = 2;
  String? feedback; // 'correct' | 'wrong'
  int streak = 0;
  int lives = livesMax;
  final TextEditingController inputController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as LessonArgs;
    table = args.table;
    isDivision = args.isDivision;
    _generateQuestion();
  }

  void _generateQuestion() {
    final rand = Random();
    if (!isDivision) {
      currentLeft = table;
      currentRight = rand.nextInt(11) + 1; // 1..12
    } else {
      // For division: (table * k) ÷ table = k
      currentRight = table;
      final k = rand.nextInt(11) + 1; // 1..12
      currentLeft = k * table;
    }
    inputController.clear();
  }

  void _submitAnswer(int answer) async {
    final correctAnswer = isDivision ? (currentLeft ~/ currentRight) : (currentLeft * currentRight);
    final isCorrect = answer == correctAnswer;

    setState(() {
      feedback = isCorrect ? 'correct' : 'wrong';
      if (isCorrect) {
        streak += 1;
      } else {
        streak = 0;
        lives -= 1;
      }
    });

    await Future.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;

    if (!isCorrect && lives <= 0) {
      _finishLesson();
      return;
    }

    if (currentQuestionIndex + 1 >= questionsPerLesson) {
      _finishLesson();
      return;
    }

    setState(() {
      currentQuestionIndex += 1;
      feedback = null;
    });

    _generateQuestion();
  }

  void _finishLesson() async {
    final progressController = ref.read(progressMapProvider.notifier);
    final existing = progressController.getProgress(table, isDivision);
    final starsEarned = streak >= 10 ? 3 : streak >= 6 ? 2 : streak >= 3 ? 1 : 0;
    final updated = existing.copyWith(
      starsEarned: max(existing.starsEarned, starsEarned),
      bestStreak: max(existing.bestStreak, streak),
    );
    await progressController.updateProgress(updated);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lesson Complete!'),
        content: Text('Stars: ${updated.starsEarned}\nBest Streak: ${updated.bestStreak}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    ).then((_) => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    final prompt = !isDivision ? '${currentLeft} × ${currentRight} = ?' : '${currentLeft} ÷ ${currentRight} = ?';

    return Scaffold(
      appBar: AppBar(title: Text('Lesson ${isDivision ? 'Division' : 'Multiplication'} $table')),
      body: constrainedBody(
        child: Padding(
          padding: pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    for (int i = 0; i < livesMax; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.favorite,
                          color: i < lives ? Colors.red : Colors.grey.shade400,
                        ),
                      ),
                  ]),
                  Text('Q ${currentQuestionIndex + 1}/$questionsPerLesson'),
                  Text('Streak: $streak'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Text(
                    prompt,
                    style: TextStyle(
                      fontSize: scaledFontSize(context, baseOnPhone: 36, maxOnDesktop: 64),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (feedback == 'correct')
                const Text('Great job!', textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontSize: 20)),
              if (feedback == 'wrong')
                const Text('Try again!', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 20)),
              const SizedBox(height: 12),
              _NumberPad(onSubmit: _submitAnswer),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter answer'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final txt = inputController.text;
                      final parsed = int.tryParse(txt);
                      if (parsed != null) {
                        _submitAnswer(parsed);
                      }
                    },
                    child: const Text('Submit'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatefulWidget {
  final void Function(int) onSubmit;
  const _NumberPad({required this.onSubmit});

  @override
  State<_NumberPad> createState() => _NumberPadState();
}

class _NumberPadState extends State<_NumberPad> {
  String buffer = '';

  void _push(String digit) {
    setState(() => buffer = (buffer + digit).substring(0, min(3, buffer.length + 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isPhone(context) ? 3 : 6,
          childAspectRatio: isPhone(context) ? 1.6 : 2.2,
          padding: EdgeInsets.zero,
          crossAxisSpacing: isPhone(context) ? 8 : 12,
          mainAxisSpacing: isPhone(context) ? 8 : 12,
          children: [
            for (final d in ['1','2','3','4','5','6','7','8','9','C','0','OK'])
              ElevatedButton(
                onPressed: () {
                  if (d == 'OK') {
                    final parsed = int.tryParse(buffer);
                    if (parsed != null) widget.onSubmit(parsed);
                    setState(() => buffer = '');
                  } else if (d == 'C') {
                    setState(() => buffer = '');
                  } else {
                    _push(d);
                  }
                },
                child: Text(d),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Answer: $buffer'),
      ],
    );
  }
}