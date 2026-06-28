import 'package:equatable/equatable.dart';

/// Represents a position on the puzzle grid.
class CellPosition extends Equatable {
  final int row;
  final int col;

  const CellPosition({required this.row, required this.col});

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => 'CellPosition($row, $col)';

  /// Returns the cell in a given direction.
  CellPosition step(int dx, int dy) =>
      CellPosition(row: row + dy, col: col + dx);

  /// Checks if this position is within grid bounds.
  bool isInBounds(int rows, int cols) =>
      row >= 0 && row < rows && col >= 0 && col < cols;
}

/// Represents a single cell in the puzzle grid.
class Cell extends Equatable {
  final CellPosition position;
  final String letter;

  const Cell({required this.position, required this.letter});

  @override
  List<Object?> get props => [position, letter];
}
