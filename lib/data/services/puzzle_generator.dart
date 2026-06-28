import 'dart:math';
import 'package:word_quest/core/constants.dart';
import 'package:word_quest/core/enums.dart';
import 'package:word_quest/data/english_words.dart';
import 'package:word_quest/domain/models/cell.dart';
import 'package:word_quest/domain/models/puzzle.dart';
import 'package:word_quest/domain/models/word_placement.dart';

/// Generates word search puzzles with configurable difficulty.
///
/// Algorithm:
/// 1. Sort words by length (longest first for better placement success)
/// 2. For each word, try random positions and directions
/// 3. Validate placement (bounds + conflict check with existing letters)
/// 4. Prefer placements that create valid intersections
/// 5. Fill empty cells with weighted random English letters
class PuzzleGenerator {
  /// Generate a puzzle for the given parameters.
  ///
  /// [difficulty] determines grid size and word count.
  /// [category] determines which word bank to use.
  /// [seed] ensures deterministic generation for the same level.
  static Puzzle generate({
    required Difficulty difficulty,
    required WordCategory category,
    required int seed,
    required int levelId,
  }) {
    final rows = difficulty.gridSize;
    final cols = difficulty.gridSize;
    final wordCount = difficulty.wordCount;
    final random = Random(seed);

    // Get words for this puzzle
    final wordEntries =
        EnglishWords.getWordsForPuzzle(category, wordCount, seed);

    // Sort by length descending (place longer words first)
    final sortedEntries = List<WordEntry>.from(wordEntries)
      ..sort((a, b) => b.gridWord.length.compareTo(a.gridWord.length));

    // Initialize empty grid
    final grid = List.generate(rows, (_) => List.filled(cols, ''));

    // Place words
    final placements = <WordPlacement>[];
    final directions = Direction.values;

    for (final entry in sortedEntries) {
      final placement = _tryPlaceWord(
        grid: grid,
        word: entry.gridWord,
        displayWord: entry.displayWord,
        rows: rows,
        cols: cols,
        random: random,
        directions: directions,
      );

      if (placement != null) {
        // Write word to grid
        for (var i = 0; i < placement.gridWord.length; i++) {
          final cell = placement.cells[i];
          grid[cell.row][cell.col] = placement.gridWord[i];
        }
        placements.add(placement);
      }
    }

    // Fill empty cells with random English letters
    _fillEmptyCells(grid, rows, cols, random);

    return Puzzle(
      rows: rows,
      cols: cols,
      grid: grid,
      words: placements,
      difficulty: difficulty,
      category: category,
      levelId: levelId,
    );
  }

  /// Try to place a word on the grid. Returns null if placement fails.
  static WordPlacement? _tryPlaceWord({
    required List<List<String>> grid,
    required String word,
    required String displayWord,
    required int rows,
    required int cols,
    required Random random,
    required List<Direction> directions,
  }) {
    // Collect all valid placements and score them
    final validPlacements = <_ScoredPlacement>[];

    for (final direction in directions) {
      // Calculate valid starting positions for this direction
      final startPositions = _getValidStartPositions(
        word: word,
        rows: rows,
        cols: cols,
        direction: direction,
      );

      for (final start in startPositions) {
        final cells = _getCells(start, direction, word.length);
        final score = _scorePlacement(grid, word, cells);
        if (score >= 0) {
          validPlacements.add(_ScoredPlacement(
            cells: cells,
            direction: direction,
            score: score,
          ));
        }
      }
    }

    if (validPlacements.isEmpty) return null;

    // Sort by score (prefer intersections), then pick randomly among top candidates
    validPlacements.sort((a, b) => b.score.compareTo(a.score));

    // Pick from the top ~20% to add variety while still preferring intersections
    final topCount = (validPlacements.length * 0.2).ceil().clamp(1, validPlacements.length);
    final chosen = validPlacements[random.nextInt(topCount)];

    return WordPlacement(
      gridWord: word,
      displayWord: displayWord,
      cells: chosen.cells,
      direction: chosen.direction,
    );
  }

  /// Get all valid starting positions for placing a word.
  static List<CellPosition> _getValidStartPositions({
    required String word,
    required int rows,
    required int cols,
    required Direction direction,
  }) {
    final positions = <CellPosition>[];
    final len = word.length;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        // Check if the word fits starting from this position in this direction
        final endRow = row + (len - 1) * direction.dy;
        final endCol = col + (len - 1) * direction.dx;

        if (endRow >= 0 && endRow < rows && endCol >= 0 && endCol < cols) {
          positions.add(CellPosition(row: row, col: col));
        }
      }
    }

    return positions;
  }

  /// Get the list of cells for a word placement.
  static List<CellPosition> _getCells(
    CellPosition start,
    Direction direction,
    int length,
  ) {
    return List.generate(
      length,
      (i) => CellPosition(
        row: start.row + i * direction.dy,
        col: start.col + i * direction.dx,
      ),
    );
  }

  /// Score a placement. Returns -1 if invalid (conflict), 0 if no intersections,
  /// positive score for each valid intersection.
  static int _scorePlacement(
    List<List<String>> grid,
    String word,
    List<CellPosition> cells,
  ) {
    var score = 0;

    for (var i = 0; i < word.length; i++) {
      final cell = cells[i];
      final existing = grid[cell.row][cell.col];

      if (existing.isNotEmpty) {
        if (existing == word[i]) {
          // Valid intersection — this letter matches
          score += 2;
        } else {
          // Conflict — different letter already placed here
          return -1;
        }
      }
    }

    return score;
  }

  /// Fill remaining empty cells with random English-frequency letters.
  static void _fillEmptyCells(
    List<List<String>> grid,
    int rows,
    int cols,
    Random random,
  ) {
    final letters = AppConstants.englishLetters;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (grid[row][col].isEmpty) {
          grid[row][col] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }
}

/// Internal helper for scoring placements.
class _ScoredPlacement {
  final List<CellPosition> cells;
  final Direction direction;
  final int score;

  const _ScoredPlacement({
    required this.cells,
    required this.direction,
    required this.score,
  });
}
