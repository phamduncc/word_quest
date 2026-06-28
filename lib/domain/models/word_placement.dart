import 'package:equatable/equatable.dart';
import 'package:word_quest/core/enums.dart';
import 'package:word_quest/domain/models/cell.dart';

/// A word placed on the puzzle grid with its location and direction.
class WordPlacement extends Equatable {
  /// The word as placed in the grid (uppercase).
  final String gridWord;

  /// The display form of the word (Title Case).
  final String displayWord;

  /// The cells occupied by this word on the grid.
  final List<CellPosition> cells;

  /// Direction this word was placed.
  final Direction direction;

  /// Whether the player has found this word.
  final bool isFound;

  const WordPlacement({
    required this.gridWord,
    required this.displayWord,
    required this.cells,
    required this.direction,
    this.isFound = false,
  });

  /// Returns a copy with [isFound] set to true.
  WordPlacement markFound() => WordPlacement(
        gridWord: gridWord,
        displayWord: displayWord,
        cells: cells,
        direction: direction,
        isFound: true,
      );

  @override
  List<Object?> get props => [gridWord, displayWord, cells, direction, isFound];
}
