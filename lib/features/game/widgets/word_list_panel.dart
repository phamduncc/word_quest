import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_quest/core/constants.dart';
import 'package:word_quest/features/game/game_providers.dart';

/// Horizontal scrollable word list showing found/unfound words.
class WordListPanel extends ConsumerWidget {
  final int levelId;

  const WordListPanel({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider(levelId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: List.generate(gameState.puzzle.words.length, (index) {
          final word = gameState.puzzle.words[index];
          final isFound = word.isFound;
          final highlightColor = gameState.foundWordColors[index];

          return AnimatedContainer(
            duration: AppConstants.normalAnimation,
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFound
                  ? (highlightColor ?? Colors.green).withValues(alpha: 0.2)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isFound
                    ? (highlightColor ?? Colors.green)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.grey.shade300),
                width: isFound ? 2 : 1,
              ),
              boxShadow: isFound
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFound) ...[
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: highlightColor ?? Colors.green,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  word.displayWord,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isFound
                        ? (highlightColor ?? Colors.green)
                        : (isDark ? Colors.white : Colors.black87),
                    decoration:
                        isFound ? TextDecoration.lineThrough : null,
                    decorationColor: highlightColor,
                    decorationThickness: 2,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
