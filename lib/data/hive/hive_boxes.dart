import 'package:hive_flutter/hive_flutter.dart';

/// Manages Hive box initialization and access.
class HiveBoxes {
  HiveBoxes._();

  static const String playerProfileBox = 'player_profile';
  static const String settingsBox = 'settings';
  static const String levelsBox = 'levels';
  static const String achievementsBox = 'achievements';
  static const String statisticsBox = 'statistics';
  static const String dailyChallengeBox = 'daily_challenge';

  /// Initialize Hive and open all required boxes.
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(playerProfileBox),
      Hive.openBox(settingsBox),
      Hive.openBox(levelsBox),
      Hive.openBox(achievementsBox),
      Hive.openBox(statisticsBox),
      Hive.openBox(dailyChallengeBox),
    ]);
  }

  static Box get playerProfile => Hive.box(playerProfileBox);
  static Box get settings => Hive.box(settingsBox);
  static Box get levels => Hive.box(levelsBox);
  static Box get achievements => Hive.box(achievementsBox);
  static Box get statistics => Hive.box(statisticsBox);
  static Box get dailyChallenge => Hive.box(dailyChallengeBox);

  /// Close all boxes.
  static Future<void> close() async {
    await Hive.close();
  }
}
