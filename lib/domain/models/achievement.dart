import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:word_quest/core/enums.dart';

/// An achievement definition and its unlock state.
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementType type;
  final int target; // target count to unlock
  final int progress; // current progress
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.target,
    this.progress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressPercent =>
      target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  Achievement copyWith({
    int? progress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      type: type,
      target: target,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, type, target, progress, isUnlocked, unlockedAt];
}

/// Predefined achievements (English).
class Achievements {
  Achievements._();

  static List<Achievement> get all => [
        const Achievement(
          id: 'first_word',
          title: 'First Word',
          description: 'Find your first word',
          icon: Icons.track_changes,
          type: AchievementType.firstWord,
          target: 1,
        ),
        const Achievement(
          id: 'first_level',
          title: 'Beginner',
          description: 'Complete your first level',
          icon: Icons.star_rounded,
          type: AchievementType.firstLevel,
          target: 1,
        ),
        const Achievement(
          id: 'speed_demon',
          title: 'Speed Demon',
          description: 'Complete a level in under 30 seconds',
          icon: Icons.bolt,
          type: AchievementType.speedDemon,
          target: 1,
        ),
        const Achievement(
          id: 'perfectionist',
          title: 'Perfectionist',
          description: 'Earn 3 stars on 10 levels',
          icon: Icons.diamond,
          type: AchievementType.perfectionist,
          target: 10,
        ),
        const Achievement(
          id: 'streak_3',
          title: 'On a Roll',
          description: 'Play 3 days in a row',
          icon: Icons.local_fire_department_rounded,
          type: AchievementType.streakMaster,
          target: 3,
        ),
        const Achievement(
          id: 'streak_7',
          title: 'Week Warrior',
          description: 'Play 7 days in a row',
          icon: Icons.local_fire_department_rounded,
          type: AchievementType.streakMaster,
          target: 7,
        ),
        const Achievement(
          id: 'streak_30',
          title: 'Streak Master',
          description: 'Play 30 days in a row',
          icon: Icons.workspace_premium_rounded,
          type: AchievementType.streakMaster,
          target: 30,
        ),
        const Achievement(
          id: 'no_hints',
          title: 'No Hints Needed',
          description: 'Complete 5 levels without using hints',
          icon: Icons.psychology_rounded,
          type: AchievementType.noHints,
          target: 5,
        ),
        const Achievement(
          id: 'word_hunter_50',
          title: 'Word Hunter',
          description: 'Find 50 words',
          icon: Icons.search_rounded,
          type: AchievementType.wordHunter,
          target: 50,
        ),
        const Achievement(
          id: 'word_hunter_200',
          title: 'Word Master',
          description: 'Find 200 words',
          icon: Icons.menu_book_rounded,
          type: AchievementType.wordHunter,
          target: 200,
        ),
        const Achievement(
          id: 'word_hunter_500',
          title: 'Linguist',
          description: 'Find 500 words',
          icon: Icons.school_rounded,
          type: AchievementType.wordHunter,
          target: 500,
        ),
        const Achievement(
          id: 'dedicated_10',
          title: 'Dedicated',
          description: 'Complete 10 levels',
          icon: Icons.assignment_rounded,
          type: AchievementType.dedicated,
          target: 10,
        ),
        const Achievement(
          id: 'dedicated_50',
          title: 'Committed',
          description: 'Complete 50 levels',
          icon: Icons.emoji_events_rounded,
          type: AchievementType.dedicated,
          target: 50,
        ),
        const Achievement(
          id: 'grand_master',
          title: 'Grand Master',
          description: 'Complete 100 levels',
          icon: Icons.workspace_premium_rounded,
          type: AchievementType.grandMaster,
          target: 100,
        ),
        const Achievement(
          id: 'animal_expert',
          title: 'Animal Expert',
          description: 'Complete all Animals levels',
          icon: Icons.pets_rounded,
          type: AchievementType.categoryExpert,
          target: 25,
        ),
        const Achievement(
          id: 'fruit_expert',
          title: 'Fruit Expert',
          description: 'Complete all Fruits levels',
          icon: Icons.apple,
          type: AchievementType.categoryExpert,
          target: 25,
        ),
        const Achievement(
          id: 'school_expert',
          title: 'Top Student',
          description: 'Complete all School levels',
          icon: Icons.school_rounded,
          type: AchievementType.categoryExpert,
          target: 25,
        ),
        const Achievement(
          id: 'nature_expert',
          title: 'Nature Lover',
          description: 'Complete all Nature levels',
          icon: Icons.eco_rounded,
          type: AchievementType.categoryExpert,
          target: 25,
        ),
      ];
}
