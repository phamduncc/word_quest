import 'package:equatable/equatable.dart';

/// Aggregated player statistics.
class Statistics extends Equatable {
  final int totalGamesPlayed;
  final int totalWordsFound;
  final int totalScore;
  final int totalPlayTimeSeconds;
  final int levelsCompleted;
  final int totalHintsUsed;
  final int totalThreeStarLevels;
  final Map<String, int> categoryCompletions; // category name -> count
  final int longestStreak;
  final int dailyChallengesCompleted;

  const Statistics({
    this.totalGamesPlayed = 0,
    this.totalWordsFound = 0,
    this.totalScore = 0,
    this.totalPlayTimeSeconds = 0,
    this.levelsCompleted = 0,
    this.totalHintsUsed = 0,
    this.totalThreeStarLevels = 0,
    this.categoryCompletions = const {},
    this.longestStreak = 0,
    this.dailyChallengesCompleted = 0,
  });

  String get formattedPlayTime {
    final hours = totalPlayTimeSeconds ~/ 3600;
    final minutes = (totalPlayTimeSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  Statistics copyWith({
    int? totalGamesPlayed,
    int? totalWordsFound,
    int? totalScore,
    int? totalPlayTimeSeconds,
    int? levelsCompleted,
    int? totalHintsUsed,
    int? totalThreeStarLevels,
    Map<String, int>? categoryCompletions,
    int? longestStreak,
    int? dailyChallengesCompleted,
  }) {
    return Statistics(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      totalScore: totalScore ?? this.totalScore,
      totalPlayTimeSeconds: totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      totalThreeStarLevels: totalThreeStarLevels ?? this.totalThreeStarLevels,
      categoryCompletions: categoryCompletions ?? this.categoryCompletions,
      longestStreak: longestStreak ?? this.longestStreak,
      dailyChallengesCompleted:
          dailyChallengesCompleted ?? this.dailyChallengesCompleted,
    );
  }

  @override
  List<Object?> get props => [
        totalGamesPlayed,
        totalWordsFound,
        totalScore,
        totalPlayTimeSeconds,
        levelsCompleted,
        totalHintsUsed,
        totalThreeStarLevels,
        categoryCompletions,
        longestStreak,
        dailyChallengesCompleted,
      ];
}
