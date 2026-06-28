import 'package:equatable/equatable.dart';
import 'package:word_quest/core/enums.dart';
import 'package:word_quest/domain/models/word_placement.dart';

/// A complete puzzle with grid, placed words, and metadata.
class Puzzle extends Equatable {
  final int rows;
  final int cols;
  final List<List<String>> grid;
  final List<WordPlacement> words;
  final Difficulty difficulty;
  final WordCategory category;
  final int levelId;

  const Puzzle({
    required this.rows,
    required this.cols,
    required this.grid,
    required this.words,
    required this.difficulty,
    required this.category,
    required this.levelId,
  });

  /// Total number of words to find.
  int get totalWords => words.length;

  /// Number of words already found.
  int get foundWords => words.where((w) => w.isFound).length;

  /// Whether all words have been found.
  bool get isComplete => foundWords == totalWords;

  /// Returns the letter at the given position.
  String letterAt(int row, int col) => grid[row][col];

  /// Returns a copy with the given word marked as found.
  Puzzle withWordFound(int wordIndex) {
    final updatedWords = List<WordPlacement>.from(words);
    updatedWords[wordIndex] = updatedWords[wordIndex].markFound();
    return Puzzle(
      rows: rows,
      cols: cols,
      grid: grid,
      words: updatedWords,
      difficulty: difficulty,
      category: category,
      levelId: levelId,
    );
  }

  @override
  List<Object?> get props =>
      [rows, cols, grid, words, difficulty, category, levelId];
}
