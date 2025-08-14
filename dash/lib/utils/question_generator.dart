import 'dart:math';

import '../models/lesson_question.dart';

class QuestionGenerator {
  final Random _random;
  QuestionGenerator([Random? random]) : _random = random ?? Random();

  LessonQuestion generate({
    required int table,
    required bool isDivision,
    required int difficultyIndex, // 0 easy, 1 medium, 2 hard
  }) {
    // Choose a type with weighted probability
    final double roll = _random.nextDouble();
    final bool allowPattern = true; // can toggle if needed
    QuestionType chosenType;
    if (allowPattern && roll < 0.25) {
      chosenType = QuestionType.pattern;
    } else if (roll < 0.6) {
      chosenType = QuestionType.multipleChoice;
    } else {
      chosenType = QuestionType.numberEntry;
    }

    switch (chosenType) {
      case QuestionType.pattern:
        return _generatePattern(table: table, isDivision: isDivision, difficultyIndex: difficultyIndex);
      case QuestionType.multipleChoice:
        return _generateMultipleChoice(table: table, isDivision: isDivision, difficultyIndex: difficultyIndex);
      case QuestionType.numberEntry:
        return _generateNumberEntry(table: table, isDivision: isDivision, difficultyIndex: difficultyIndex);
    }
  }

  int _pickK(int difficultyIndex) {
    // k determines 1..12; harder favors larger values
    switch (difficultyIndex.clamp(0, 2)) {
      case 2:
        return _random.nextInt(7) + 6; // 6..12
      case 1:
        return _random.nextInt(12) + 1; // 1..12
      default:
        return _random.nextInt(6) + 1; // 1..6
    }
  }

  LessonQuestion _generateNumberEntry({required int table, required bool isDivision, required int difficultyIndex}) {
    final int k = _pickK(difficultyIndex);
    final int left = isDivision ? table * k : table;
    final int right = isDivision ? table : k;
    final int answer = isDivision ? k : table * k;
    return LessonQuestion.numberEntry(
      table: table,
      isDivision: isDivision,
      left: left,
      right: right,
      correctAnswer: answer,
    );
  }

  LessonQuestion _generateMultipleChoice({required int table, required bool isDivision, required int difficultyIndex}) {
    final int k = _pickK(difficultyIndex);
    final int left = isDivision ? table * k : table;
    final int right = isDivision ? table : k;
    final int answer = isDivision ? k : table * k;

    final Set<int> options = {answer};
    while (options.length < 3) {
      final int delta = 1 + _random.nextInt(3); // small distractors
      final int sign = _random.nextBool() ? 1 : -1;
      int candidate = answer + delta * sign;
      if (candidate <= 0) candidate = answer + delta;
      options.add(candidate);
    }
    final List<int> shuffled = options.toList()..shuffle(_random);
    return LessonQuestion.multipleChoice(
      table: table,
      isDivision: isDivision,
      left: left,
      right: right,
      correctAnswer: answer,
      options: shuffled,
    );
  }

  LessonQuestion _generatePattern({required int table, required bool isDivision, required int difficultyIndex}) {
    // Creates three rows where the last result is unknown
    // Example for division: 54 ÷ 9 = 6, 63 ÷ 9 = 7, 72 ÷ 9 = ? (8)
    final int startK = max(2, _pickK(difficultyIndex) - 1); // ensure we have k, k+1, k+2
    final List<int> ks = [startK, startK + 1, startK + 2];

    late final List<int> lefts;
    late final List<int> results;
    late final int rightConst;
    if (isDivision) {
      rightConst = table;
      lefts = ks.map((k) => k * table).toList();
      results = ks.toList();
    } else {
      rightConst = table;
      lefts = ks.toList();
      results = ks.map((k) => k * table).toList();
    }

    final PatternQuestionData data = PatternQuestionData(
      isDivision: isDivision,
      rightConst: rightConst,
      leftOperands: lefts,
      results: results,
    );

    // Build two options (correct and a close distractor)
    final int correct = data.correctAnswer;
    int distractor = correct + (_random.nextBool() ? 1 : -1);
    if (distractor <= 0) distractor = correct + 1;
    final List<int> options = [correct, distractor]..shuffle(_random);

    return LessonQuestion.pattern(
      table: table,
      isDivision: isDivision,
      pattern: data,
      options: options,
    );
  }
}