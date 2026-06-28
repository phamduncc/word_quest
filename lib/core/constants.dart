import 'package:flutter/material.dart';

/// App-wide constants for the Word Quest game.
class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = 'Word Quest';
  static const String appVersion = '1.0.0';

  // ── Scoring ──
  static const int baseScorePerWord = 100;
  static const int bonusPerRemainingSecond = 2;
  static const int hintPenalty = 50;
  static const int streakMultiplier = 10;

  // ── Stars ──
  static const double threeStarThreshold = 0.9; // 90%+ of max score
  static const double twoStarThreshold = 0.7;
  static const double oneStarThreshold = 0.0;

  // ── Hints ──
  static const int initialHints = 3;
  static const int maxHints = 10;
  static const int hintRewardPerAd = 3;

  // ── Timer ──
  static const int easyTimeLimitSeconds = 300; // 5 min
  static const int mediumTimeLimitSeconds = 480; // 8 min
  static const int hardTimeLimitSeconds = 600; // 10 min
  static const int expertTimeLimitSeconds = 900; // 15 min

  static int timeLimitForDifficulty(int gridSize) {
    if (gridSize <= 8) return easyTimeLimitSeconds;
    if (gridSize <= 10) return mediumTimeLimitSeconds;
    if (gridSize <= 12) return hardTimeLimitSeconds;
    return expertTimeLimitSeconds;
  }

  // ── English Letters ──
  /// Letters used to fill empty grid cells, weighted by frequency in English.
  static const List<String> englishLetters = [
    'E', 'E', 'E', 'E', 'E', // highest frequency
    'T', 'T', 'T', 'T',
    'A', 'A', 'A', 'A',
    'O', 'O', 'O',
    'I', 'I', 'I',
    'N', 'N', 'N',
    'S', 'S', 'S',
    'H', 'H',
    'R', 'R',
    'D', 'D',
    'L', 'L',
    'C', 'C',
    'U', 'U',
    'M', 'M',
    'W',
    'F',
    'G',
    'Y',
    'P',
    'B',
    'V',
    'K',
  ];

  // ── Animation Durations ──
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 600);
  static const Duration celebrationDuration = Duration(milliseconds: 1500);

  // ── Grid ──
  static const double minCellSize = 28.0;
  static const double maxCellSize = 48.0;
  static const double gridPadding = 8.0;
  static const double cellSpacing = 2.0;

  // ── Highlight Colors ──
  static const List<Color> highlightColors = [
    Color(0xFF4FC3F7), // Light Blue
    Color(0xFF81C784), // Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFE57373), // Red
    Color(0xFFBA68C8), // Purple
    Color(0xFF4DD0E1), // Cyan
    Color(0xFFFFF176), // Yellow
    Color(0xFFA1887F), // Brown
    Color(0xFF90A4AE), // Blue Grey
    Color(0xFFF06292), // Pink
    Color(0xFFAED581), // Light Green
    Color(0xFF7986CB), // Indigo
    Color(0xFFFFD54F), // Amber
    Color(0xFF4DB6AC), // Teal
    Color(0xFFFF8A65), // Deep Orange
    Color(0xFF9575CD), // Deep Purple
    Color(0xFF64B5F6), // Blue
    Color(0xFFDCE775), // Lime
    Color(0xFFE0E0E0), // Grey
    Color(0xFFF48FB1), // Light Pink
  ];

  // ── Level Generation ──
  static const int levelsPerCategory = 25;
  static const int totalCategories = 16;
}
