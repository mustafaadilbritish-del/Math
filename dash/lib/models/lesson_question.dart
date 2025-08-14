enum QuestionType { numberEntry, multipleChoice, pattern }

class LessonQuestion {
  final QuestionType type;
  final bool isDivision; // false=multiplication, true=division
  final int table; // 2..12

  // For numberEntry and multipleChoice
  final int? left;
  final int? right;
  final int? correctAnswer;
  final List<int>? options; // for multiple choice (and pattern selectable options)

  // For pattern questions
  final PatternQuestionData? pattern;

  LessonQuestion.numberEntry({
    required this.table,
    required this.isDivision,
    required int left,
    required int right,
    required int correctAnswer,
  })  : type = QuestionType.numberEntry,
        left = left,
        right = right,
        correctAnswer = correctAnswer,
        options = null,
        pattern = null;

  LessonQuestion.multipleChoice({
    required this.table,
    required this.isDivision,
    required int left,
    required int right,
    required int correctAnswer,
    required List<int> options,
  })  : type = QuestionType.multipleChoice,
        left = left,
        right = right,
        correctAnswer = correctAnswer,
        options = options,
        pattern = null;

  LessonQuestion.pattern({
    required this.table,
    required this.isDivision,
    required PatternQuestionData pattern,
    required List<int> options,
  })  : type = QuestionType.pattern,
        left = null,
        right = null,
        correctAnswer = pattern.correctAnswer,
        options = options,
        pattern = pattern;

  String get keySignature {
    switch (type) {
      case QuestionType.numberEntry:
      case QuestionType.multipleChoice:
        return '${isDivision ? 'd' : 'm'}:${left}x${right}';
      case QuestionType.pattern:
        return '${isDivision ? 'd' : 'm'}:pattern:${pattern?.rightConst}:${pattern?.leftOperands.join(',')}';
    }
  }
}

class PatternQuestionData {
  final bool isDivision;
  final int rightConst; // e.g., divide by 9 or multiply by 9
  final List<int> leftOperands; // length 3
  final List<int> results; // length 3, with last one unknown in UI

  const PatternQuestionData({
    required this.isDivision,
    required this.rightConst,
    required this.leftOperands,
    required this.results,
  });

  int get correctAnswer => results.last;
}