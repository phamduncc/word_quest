import 'package:equatable/equatable.dart';
import 'package:word_quest/core/enums.dart';

/// Represents a game level with progress tracking.
class Level extends Equatable {
  final int id;
  final Difficulty difficulty;
  final WordCategory category;
  final int stars; // 0-3
  final bool isUnlocked;
  final int bestScore;
  final int bestTimeSeconds;

  const Level({
    required this.id,
    required this.difficulty,
    required this.category,
    this.stars = 0,
    this.isUnlocked = false,
    this.bestScore = 0,
    this.bestTimeSeconds = 0,
  });

  bool get isCompleted => stars > 0;

  Level copyWith({
    int? id,
    Difficulty? difficulty,
    WordCategory? category,
    int? stars,
    bool? isUnlocked,
    int? bestScore,
    int? bestTimeSeconds,
  }) {
    return Level(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      stars: stars ?? this.stars,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      bestScore: bestScore ?? this.bestScore,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
    );
  }

  @override
  List<Object?> get props =>
      [id, difficulty, category, stars, isUnlocked, bestScore, bestTimeSeconds];
}
