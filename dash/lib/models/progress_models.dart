class LessonProgress {
  final int table; // 2-12
  final bool isDivision; // false=multiplication, true=division
  final int starsEarned; // 0-3
  final int bestStreak;

  LessonProgress({
    required this.table,
    required this.isDivision,
    this.starsEarned = 0,
    this.bestStreak = 0,
  });

  LessonProgress copyWith({
    int? table,
    bool? isDivision,
    int? starsEarned,
    int? bestStreak,
  }) {
    return LessonProgress(
      table: table ?? this.table,
      isDivision: isDivision ?? this.isDivision,
      starsEarned: starsEarned ?? this.starsEarned,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  Map<String, dynamic> toJson() => {
        'table': table,
        'isDivision': isDivision,
        'starsEarned': starsEarned,
        'bestStreak': bestStreak,
      };

  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
        table: json['table'] as int,
        isDivision: json['isDivision'] as bool,
        starsEarned: (json['starsEarned'] as int?) ?? 0,
        bestStreak: (json['bestStreak'] as int?) ?? 0,
      );
}

class QuestionResult {
  final int left; // e.g., 2 in 2 x 3
  final int right; // e.g., 3 in 2 x 3
  final int answer; // user answer
  final bool isCorrect;

  QuestionResult({
    required this.left,
    required this.right,
    required this.answer,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
        'left': left,
        'right': right,
        'answer': answer,
        'isCorrect': isCorrect,
      };

  factory QuestionResult.fromJson(Map<String, dynamic> json) => QuestionResult(
        left: json['left'] as int,
        right: json['right'] as int,
        answer: json['answer'] as int,
        isCorrect: json['isCorrect'] as bool,
      );
}