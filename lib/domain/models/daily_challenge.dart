import 'package:equatable/equatable.dart';
import 'package:word_quest/core/enums.dart';

/// A daily challenge puzzle that changes each day.
class DailyChallenge extends Equatable {
  final DateTime date;
  final Difficulty difficulty;
  final WordCategory category;
  final bool isCompleted;
  final int score;
  final int timeSeconds;
  final int stars;

  const DailyChallenge({
    required this.date,
    this.difficulty = Difficulty.medium,
    this.category = WordCategory.animals,
    this.isCompleted = false,
    this.score = 0,
    this.timeSeconds = 0,
    this.stars = 0,
  });

  /// Generate a deterministic seed from the date for reproducible puzzles.
  int get seed {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  /// Level ID for daily challenges (offset by 100000 to avoid collision).
  int get levelId => 100000 + seed;

  DailyChallenge copyWith({
    bool? isCompleted,
    int? score,
    int? timeSeconds,
    int? stars,
  }) {
    return DailyChallenge(
      date: date,
      difficulty: difficulty,
      category: category,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      stars: stars ?? this.stars,
    );
  }

  @override
  List<Object?> get props =>
      [date, difficulty, category, isCompleted, score, timeSeconds, stars];
}
