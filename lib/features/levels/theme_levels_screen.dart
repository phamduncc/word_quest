import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:word_quest/core/constants.dart';
import 'package:word_quest/core/enums.dart';
import 'package:word_quest/core/theme.dart';
import 'package:word_quest/features/game/game_providers.dart';

/// Level selection screen for a specific word category theme.
class ThemeLevelsScreen extends ConsumerWidget {
  final WordCategory category;

  const ThemeLevelsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = Color(category.colorValue);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkBackground : AppTheme.warmBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              _buildHeader(context, themeColor, isDark),

              const SizedBox(height: 8),

              // ── Difficulty Legend ──
              _buildDifficultyLegend(isDark),

              const SizedBox(height: 8),

              // ── Level Grid ──
              Expanded(
                child: _buildLevelGrid(context, ref, themeColor, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color themeColor,
    bool isDark,
  ) {
    final darkColor = Color.lerp(themeColor, Colors.black, 0.35)!;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor, darkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.goNamed('levels'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Icon(
            category.icon,
            size: 36,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${AppConstants.levelsPerCategory} levels',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyLegend(bool isDark) {
    const items = [
      ('Easy', Color(0xFF4CAF50)),
      ('Med', Color(0xFFFF9800)),
      ('Hard', Color(0xFFE53935)),
      ('Exp.', Color(0xFF9C27B0)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.$2,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item.$1,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelGrid(
    BuildContext context,
    WidgetRef ref,
    Color themeColor,
    bool isDark,
  ) {
    final storage = ref.read(storageRepositoryProvider);
    final categoryIndex = category.index;
    final startLevel = categoryIndex * AppConstants.levelsPerCategory + 1;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: AppConstants.levelsPerCategory,
      itemBuilder: (context, index) {
        final levelId = startLevel + index;
        final level = storage.loadLevel(levelId);
        final isUnlocked = level.isUnlocked || levelId == startLevel;

        return _LevelBubble(
          levelNumber: index + 1,
          levelId: levelId,
          stars: level.stars,
          isUnlocked: isUnlocked,
          isDark: isDark,
          difficulty: level.difficulty,
          themeColor: themeColor,
          onTap: isUnlocked
              ? () => context.goNamed(
                    'game',
                    pathParameters: {'levelId': levelId.toString()},
                  )
              : null,
        );
      },
    );
  }
}

/// Individual level bubble for a specific theme.
class _LevelBubble extends StatelessWidget {
  final int levelNumber;
  final int levelId;
  final int stars;
  final bool isUnlocked;
  final bool isDark;
  final Difficulty difficulty;
  final Color themeColor;
  final VoidCallback? onTap;

  const _LevelBubble({
    required this.levelNumber,
    required this.levelId,
    required this.stars,
    required this.isUnlocked,
    required this.isDark,
    required this.difficulty,
    required this.themeColor,
    this.onTap,
  });

  Color get _difficultyColor {
    switch (difficulty) {
      case Difficulty.easy:
        return const Color(0xFF4CAF50);
      case Difficulty.medium:
        return const Color(0xFFFF9800);
      case Difficulty.hard:
        return const Color(0xFFE53935);
      case Difficulty.expert:
        return const Color(0xFF9C27B0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isDark
                  ? _difficultyColor.withValues(alpha: 0.15)
                  : Colors.white)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnlocked
                ? _difficultyColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: stars > 0 ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _difficultyColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(
                Icons.lock_rounded,
                size: 24,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              )
            else
              Text(
                '$levelNumber',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: stars > 0
                      ? _difficultyColor
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            if (isUnlocked && stars > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 12,
                    color: i < stars
                        ? const Color(0xFFFFB300)
                        : Colors.grey.shade400,
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
