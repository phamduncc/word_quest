import 'package:word_quest/core/constants.dart';
import 'package:word_quest/core/enums.dart';
import 'package:word_quest/data/hive/hive_boxes.dart';
import 'package:word_quest/domain/models/achievement.dart';
import 'package:word_quest/domain/models/level.dart';
import 'package:word_quest/domain/models/player_profile.dart';
import 'package:word_quest/domain/models/settings.dart';
import 'package:word_quest/domain/models/statistics.dart';

/// Repository for all local storage operations using Hive.
class StorageRepository {
  // ═══════════════════════════════════════════════════════════
  // Player Profile
  // ═══════════════════════════════════════════════════════════

  PlayerProfile loadPlayerProfile() {
    final box = HiveBoxes.playerProfile;
    if (box.isEmpty) return PlayerProfile.initial();

    return PlayerProfile(
      name: box.get('name', defaultValue: 'Player'),
      totalScore: box.get('totalScore', defaultValue: 0),
      totalStarsEarned: box.get('totalStarsEarned', defaultValue: 0),
      levelsCompleted: box.get('levelsCompleted', defaultValue: 0),
      wordsFound: box.get('wordsFound', defaultValue: 0),
      currentStreak: box.get('currentStreak', defaultValue: 0),
      bestStreak: box.get('bestStreak', defaultValue: 0),
      hintsRemaining: box.get('hintsRemaining', defaultValue: 3),
      lastPlayedDate: DateTime.tryParse(
              box.get('lastPlayedDate', defaultValue: '')) ??
          DateTime.now(),
      gamesPlayed: box.get('gamesPlayed', defaultValue: 0),
    );
  }

  Future<void> savePlayerProfile(PlayerProfile profile) async {
    final box = HiveBoxes.playerProfile;
    await box.putAll({
      'name': profile.name,
      'totalScore': profile.totalScore,
      'totalStarsEarned': profile.totalStarsEarned,
      'levelsCompleted': profile.levelsCompleted,
      'wordsFound': profile.wordsFound,
      'currentStreak': profile.currentStreak,
      'bestStreak': profile.bestStreak,
      'hintsRemaining': profile.hintsRemaining,
      'lastPlayedDate': profile.lastPlayedDate.toIso8601String(),
      'gamesPlayed': profile.gamesPlayed,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // Settings
  // ═══════════════════════════════════════════════════════════

  Settings loadSettings() {
    final box = HiveBoxes.settings;
    if (box.isEmpty) return const Settings();

    return Settings(
      isDarkMode: box.get('isDarkMode', defaultValue: false),
      isSoundEnabled: box.get('isSoundEnabled', defaultValue: true),
      isMusicEnabled: box.get('isMusicEnabled', defaultValue: true),
      isHapticEnabled: box.get('isHapticEnabled', defaultValue: true),
    );
  }

  Future<void> saveSettings(Settings settings) async {
    final box = HiveBoxes.settings;
    await box.putAll({
      'isDarkMode': settings.isDarkMode,
      'isSoundEnabled': settings.isSoundEnabled,
      'isMusicEnabled': settings.isMusicEnabled,
      'isHapticEnabled': settings.isHapticEnabled,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // Levels
  // ═══════════════════════════════════════════════════════════

  Level loadLevel(int levelId) {
    final box = HiveBoxes.levels;
    final key = 'level_$levelId';
    final data = box.get(key);

    if (data == null) {
      // Generate level metadata from ID
      final categoryIndex =
          (levelId - 1) ~/ AppConstants.levelsPerCategory;
      final category = WordCategory
          .values[categoryIndex.clamp(0, WordCategory.values.length - 1)];
      final posInCategory =
          (levelId - 1) % AppConstants.levelsPerCategory;

      Difficulty difficulty;
      if (posInCategory < 5) {
        difficulty = Difficulty.easy;
      } else if (posInCategory < 12) {
        difficulty = Difficulty.medium;
      } else if (posInCategory < 19) {
        difficulty = Difficulty.hard;
      } else {
        difficulty = Difficulty.expert;
      }

      return Level(
        id: levelId,
        difficulty: difficulty,
        category: category,
        isUnlocked: levelId == 1, // first level is always unlocked
      );
    }

    final map = Map<String, dynamic>.from(data);
    return Level(
      id: levelId,
      difficulty: Difficulty.values[map['difficulty'] ?? 0],
      category: WordCategory.values[map['category'] ?? 0],
      stars: map['stars'] ?? 0,
      isUnlocked: map['isUnlocked'] ?? false,
      bestScore: map['bestScore'] ?? 0,
      bestTimeSeconds: map['bestTimeSeconds'] ?? 0,
    );
  }

  Future<void> saveLevel(Level level) async {
    final box = HiveBoxes.levels;
    await box.put('level_${level.id}', {
      'difficulty': level.difficulty.index,
      'category': level.category.index,
      'stars': level.stars,
      'isUnlocked': level.isUnlocked,
      'bestScore': level.bestScore,
      'bestTimeSeconds': level.bestTimeSeconds,
    });
  }

  List<Level> loadAllLevels() {
    final totalLevels =
        AppConstants.levelsPerCategory * AppConstants.totalCategories;
    return List.generate(totalLevels, (i) => loadLevel(i + 1));
  }

  // ═══════════════════════════════════════════════════════════
  // Achievements
  // ═══════════════════════════════════════════════════════════

  List<Achievement> loadAchievements() {
    final box = HiveBoxes.achievements;
    final defaults = Achievements.all;

    return defaults.map((a) {
      final data = box.get(a.id);
      if (data == null) return a;
      final map = Map<String, dynamic>.from(data);
      return a.copyWith(
        progress: map['progress'] ?? 0,
        isUnlocked: map['isUnlocked'] ?? false,
        unlockedAt: map['unlockedAt'] != null
            ? DateTime.tryParse(map['unlockedAt'])
            : null,
      );
    }).toList();
  }

  Future<void> saveAchievement(Achievement achievement) async {
    final box = HiveBoxes.achievements;
    await box.put(achievement.id, {
      'progress': achievement.progress,
      'isUnlocked': achievement.isUnlocked,
      'unlockedAt': achievement.unlockedAt?.toIso8601String(),
    });
  }

  // ═══════════════════════════════════════════════════════════
  // Statistics
  // ═══════════════════════════════════════════════════════════

  Statistics loadStatistics() {
    final box = HiveBoxes.statistics;
    if (box.isEmpty) return const Statistics();

    return Statistics(
      totalGamesPlayed: box.get('totalGamesPlayed', defaultValue: 0),
      totalWordsFound: box.get('totalWordsFound', defaultValue: 0),
      totalScore: box.get('totalScore', defaultValue: 0),
      totalPlayTimeSeconds: box.get('totalPlayTimeSeconds', defaultValue: 0),
      levelsCompleted: box.get('levelsCompleted', defaultValue: 0),
      totalHintsUsed: box.get('totalHintsUsed', defaultValue: 0),
      totalThreeStarLevels: box.get('totalThreeStarLevels', defaultValue: 0),
      categoryCompletions: Map<String, int>.from(
          box.get('categoryCompletions', defaultValue: {})),
      longestStreak: box.get('longestStreak', defaultValue: 0),
      dailyChallengesCompleted:
          box.get('dailyChallengesCompleted', defaultValue: 0),
    );
  }

  Future<void> saveStatistics(Statistics stats) async {
    final box = HiveBoxes.statistics;
    await box.putAll({
      'totalGamesPlayed': stats.totalGamesPlayed,
      'totalWordsFound': stats.totalWordsFound,
      'totalScore': stats.totalScore,
      'totalPlayTimeSeconds': stats.totalPlayTimeSeconds,
      'levelsCompleted': stats.levelsCompleted,
      'totalHintsUsed': stats.totalHintsUsed,
      'totalThreeStarLevels': stats.totalThreeStarLevels,
      'categoryCompletions': stats.categoryCompletions,
      'longestStreak': stats.longestStreak,
      'dailyChallengesCompleted': stats.dailyChallengesCompleted,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // Daily Challenge
  // ═══════════════════════════════════════════════════════════

  bool isDailyChallengeCompleted(DateTime date) {
    final box = HiveBoxes.dailyChallenge;
    final key = _dateKey(date);
    return box.get(key, defaultValue: false);
  }

  Future<void> markDailyChallengeCompleted(DateTime date) async {
    final box = HiveBoxes.dailyChallenge;
    await box.put(_dateKey(date), true);
  }

  String _dateKey(DateTime date) =>
      '${date.year}_${date.month}_${date.day}';

  // ═══════════════════════════════════════════════════════════
  // Reset
  // ═══════════════════════════════════════════════════════════

  Future<void> resetAllProgress() async {
    await Future.wait([
      HiveBoxes.playerProfile.clear(),
      HiveBoxes.levels.clear(),
      HiveBoxes.achievements.clear(),
      HiveBoxes.statistics.clear(),
      HiveBoxes.dailyChallenge.clear(),
    ]);
  }
}
