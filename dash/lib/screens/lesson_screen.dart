import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../utils/responsive.dart';
import '../models/lesson_question.dart';
import '../utils/question_generator.dart';
import '../widgets/quiz_widgets.dart';
import '../widgets/heart_lives.dart';

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
  String? feedback; // 'correct' | 'wrong'
  int streak = 0;
  int lives = livesMax;
  final TextEditingController inputController = TextEditingController();

  // Adaptive difficulty based on streak: 0..2
  int get _difficultyIndex => streak >= 6 ? 2 : streak >= 3 ? 1 : 0;

  final QuestionGenerator _generator = QuestionGenerator();
  LessonQuestion? _current;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as LessonArgs;
    table = args.table;
    isDivision = args.isDivision;
    _generateQuestion();
  }

  void _generateQuestion() {
    _current = _generator.generate(table: table, isDivision: isDivision, difficultyIndex: _difficultyIndex);
    inputController.clear();
  }

  void _submitAnswer(int answer) async {
    if (_current == null) return;
    final int correctAnswer = _current!.correctAnswer ?? 0;
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

    // sound/haptics
    final sound = ref.read(soundServiceProvider);
    if (isCorrect) {
      await sound.correct();
    } else {
      await sound.wrong();
    }

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
    final LessonQuestion? q = _current;

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
                  HeartLives(lives: lives, maxLives: livesMax),
                  Text('Q ${currentQuestionIndex + 1}/$questionsPerLesson'),
                  Text('Streak: $streak'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: _buildQuestionContent(q),
                ),
              ),
              if (feedback == 'correct')
                const Text('Great job!', textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontSize: 20)),
              if (feedback == 'wrong')
                const Text('Try again!', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 20)),
              const SizedBox(height: 12),
              if (q != null && q.type == QuestionType.numberEntry) ...[
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
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(LessonQuestion? q) {
    if (q == null) return const SizedBox.shrink();
    switch (q.type) {
      case QuestionType.numberEntry:
        final prompt = !q.isDivision ? '${q.left} × ${q.right} = ?' : '${q.left} ÷ ${q.right} = ?';
        return Text(
          prompt,
          style: TextStyle(
            fontSize: scaledFontSize(context, baseOnPhone: 36, maxOnDesktop: 64),
            fontWeight: FontWeight.bold,
          ),
        );
      case QuestionType.multipleChoice:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              !q.isDivision ? '${q.left} × ${q.right} = ?' : '${q.left} ÷ ${q.right} = ?',
              style: TextStyle(fontSize: scaledFontSize(context, baseOnPhone: 28, maxOnDesktop: 48), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MultipleChoiceList(options: q.options!, onSelected: _submitAnswer),
          ],
        );
      case QuestionType.pattern:
        return PatternGrid(
          data: q.pattern!,
          options: q.options!,
          onSelected: _submitAnswer,
        );
    }
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