import 'package:flutter/material.dart';

/// Game difficulty levels with grid size and word count configuration.
enum Difficulty {
  easy(gridSize: 8, wordCount: 5, label: 'Easy'),
  medium(gridSize: 10, wordCount: 8, label: 'Medium'),
  hard(gridSize: 12, wordCount: 12, label: 'Hard'),
  expert(gridSize: 15, wordCount: 20, label: 'Expert');

  const Difficulty({
    required this.gridSize,
    required this.wordCount,
    required this.label,
  });

  final int gridSize;
  final int wordCount;
  final String label;
}

/// Directions a word can be placed in the grid.
enum Direction {
  horizontal(dx: 1, dy: 0),
  vertical(dx: 0, dy: 1),
  diagonalDown(dx: 1, dy: 1),
  diagonalUp(dx: 1, dy: -1),
  horizontalReverse(dx: -1, dy: 0),
  verticalReverse(dx: 0, dy: -1),
  diagonalDownReverse(dx: -1, dy: -1),
  diagonalUpReverse(dx: -1, dy: 1);

  const Direction({required this.dx, required this.dy});

  final int dx;
  final int dy;
}

/// Word categories for organizing the English word bank.
/// IMPORTANT: The order of enum values determines the category index.
/// Existing categories (0-7) must NOT be reordered for backward compatibility.
enum WordCategory {
  // ── Original 8 categories (index 0-7) ──
  animals(label: 'Animals', icon: Icons.pets, colorValue: 0xFFFF8F00),
  fruits(label: 'Fruits', icon: Icons.apple, colorValue: 0xFF43A047),
  school(label: 'School', icon: Icons.school, colorValue: 0xFF1976D2),
  family(label: 'Family', icon: Icons.family_restroom, colorValue: 0xFFE91E63),
  nature(label: 'Nature', icon: Icons.eco, colorValue: 0xFF2E7D32),
  countries(label: 'Countries', icon: Icons.public, colorValue: 0xFF3F51B5),
  science(label: 'Science', icon: Icons.science, colorValue: 0xFF00897B),
  transportation(label: 'Transport', icon: Icons.directions_car, colorValue: 0xFFE64A19),

  // ── New 8 categories (index 8-15) ──
  plants(label: 'Plants', icon: Icons.local_florist, colorValue: 0xFF558B2F),
  sports(label: 'Sports', icon: Icons.sports_soccer, colorValue: 0xFFC62828),
  food(label: 'Food', icon: Icons.fastfood, colorValue: 0xFFF57F17),
  objects(label: 'Objects', icon: Icons.chair, colorValue: 0xFF455A64),
  colors(label: 'Colors', icon: Icons.palette, colorValue: 0xFF6A1B9A),
  jobs(label: 'Jobs', icon: Icons.work, colorValue: 0xFF00838F),
  body(label: 'Body', icon: Icons.accessibility_new, colorValue: 0xFFAD1457),
  weather(label: 'Weather', icon: Icons.cloud, colorValue: 0xFF0277BD);

  const WordCategory({
    required this.label,
    required this.icon,
    required this.colorValue,
  });

  final String label;
  final IconData icon;
  final int colorValue;
}

/// Types of achievements.
enum AchievementType {
  firstWord,
  firstLevel,
  speedDemon,
  perfectionist,
  streakMaster,
  noHints,
  categoryExpert,
  wordHunter,
  dedicated,
  grandMaster,
}

/// Current status of a game session.
enum GameStatus {
  notStarted,
  playing,
  paused,
  completed,
}
