import 'package:equatable/equatable.dart';

/// Player profile stored locally.
class PlayerProfile extends Equatable {
  final String name;
  final int totalScore;
  final int totalStarsEarned;
  final int levelsCompleted;
  final int wordsFound;
  final int currentStreak;
  final int bestStreak;
  final int hintsRemaining;
  final DateTime lastPlayedDate;
  final int gamesPlayed;

  const PlayerProfile({
    this.name = 'Player',
    this.totalScore = 0,
    this.totalStarsEarned = 0,
    this.levelsCompleted = 0,
    this.wordsFound = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.hintsRemaining = 3,
    required this.lastPlayedDate,
    this.gamesPlayed = 0,
  });

  factory PlayerProfile.initial() => PlayerProfile(
        lastPlayedDate: DateTime.now(),
      );

  PlayerProfile copyWith({
    String? name,
    int? totalScore,
    int? totalStarsEarned,
    int? levelsCompleted,
    int? wordsFound,
    int? currentStreak,
    int? bestStreak,
    int? hintsRemaining,
    DateTime? lastPlayedDate,
    int? gamesPlayed,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      totalScore: totalScore ?? this.totalScore,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      wordsFound: wordsFound ?? this.wordsFound,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    );
  }

  @override
  List<Object?> get props => [
        name,
        totalScore,
        totalStarsEarned,
        levelsCompleted,
        wordsFound,
        currentStreak,
        bestStreak,
        hintsRemaining,
        lastPlayedDate,
        gamesPlayed,
      ];
}
