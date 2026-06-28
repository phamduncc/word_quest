import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_quest/domain/models/cell.dart';
import 'package:word_quest/domain/models/game_state.dart';
import 'package:word_quest/features/game/game_providers.dart';

/// Interactive word search grid with drag selection.
class GameGrid extends ConsumerStatefulWidget {
  final int levelId;

  const GameGrid({super.key, required this.levelId});

  @override
  ConsumerState<GameGrid> createState() => GameGridWidgetState();
}

class GameGridWidgetState extends ConsumerState<GameGrid>
    with SingleTickerProviderStateMixin {
  CellPosition? _hintCell;
  late AnimationController _hintAnimController;
  late Animation<double> _hintAnimation;

  @override
  void initState() {
    super.initState();
    _hintAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _hintAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hintAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hintAnimController.dispose();
    super.dispose();
  }

  void showHint(CellPosition cell) {
    setState(() => _hintCell = cell);
    _hintAnimController.forward(from: 0).then((_) {
      _hintAnimController.reverse().then((_) {
        if (mounted) setState(() => _hintCell = null);
      });
    });
  }

  CellPosition? _getCellFromPosition(
      Offset localPosition, double cellSize, int rows, int cols) {
    final col = (localPosition.dx / cellSize).floor();
    final row = (localPosition.dy / cellSize).floor();

    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      return CellPosition(row: row, col: col);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider(widget.levelId));
    final controller =
        ref.read(gameControllerProvider(widget.levelId).notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = constraints.maxWidth;
        final cellSize = gridSize / gameState.puzzle.cols;

        return GestureDetector(
          onPanStart: (details) {
            final cell = _getCellFromPosition(
              details.localPosition,
              cellSize,
              gameState.puzzle.rows,
              gameState.puzzle.cols,
            );
            if (cell != null) controller.onSelectionStart(cell);
          },
          onPanUpdate: (details) {
            final cell = _getCellFromPosition(
              details.localPosition,
              cellSize,
              gameState.puzzle.rows,
              gameState.puzzle.cols,
            );
            if (cell != null) controller.onSelectionUpdate(cell);
          },
          onPanEnd: (_) => controller.onSelectionEnd(),
          child: AnimatedBuilder(
            listenable: _hintAnimController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(gridSize, cellSize * gameState.puzzle.rows),
                painter: _GridPainter(
                  gameState: gameState,
                  cellSize: cellSize,
                  isDark: isDark,
                  hintCell: _hintCell,
                  hintOpacity: _hintAnimation.value,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Simple AnimatedWidget wrapper that rebuilds on listenable changes.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

/// Custom painter for the word search grid.
class _GridPainter extends CustomPainter {
  final GameState gameState;
  final double cellSize;
  final bool isDark;
  final CellPosition? hintCell;
  final double hintOpacity;

  _GridPainter({
    required this.gameState,
    required this.cellSize,
    required this.isDark,
    this.hintCell,
    this.hintOpacity = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final puzzle = gameState.puzzle;

    _drawCellBackgrounds(canvas, puzzle);
    _drawFoundWords(canvas);
    _drawCurrentSelection(canvas);

    if (hintCell != null) {
      _drawHintHighlight(canvas);
    }

    _drawGridLines(canvas, puzzle);
    _drawLetters(canvas, puzzle);
  }

  void _drawCellBackgrounds(Canvas canvas, puzzle) {
    final bgPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E1E2E)
          : Colors.white;

    for (var row = 0; row < puzzle.rows; row++) {
      for (var col = 0; col < puzzle.cols; col++) {
        final rect = Rect.fromLTWH(
          col * cellSize + 1,
          row * cellSize + 1,
          cellSize - 2,
          cellSize - 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          bgPaint,
        );
      }
    }
  }

  void _drawFoundWords(Canvas canvas) {
    for (final entry in gameState.foundWordColors.entries) {
      final wordIndex = entry.key;
      final color = entry.value;
      final word = gameState.puzzle.words[wordIndex];

      if (word.cells.isEmpty) continue;

      final paint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final path = _createCellPath(word.cells);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    }
  }

  void _drawCurrentSelection(Canvas canvas) {
    if (gameState.currentSelection.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF4FC3F7).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = _createCellPath(gameState.currentSelection);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawHintHighlight(Canvas canvas) {
    if (hintCell == null) return;

    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: hintOpacity * 0.6)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.amber.withValues(alpha: hintOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final rect = Rect.fromLTWH(
      hintCell!.col * cellSize + 2,
      hintCell!.row * cellSize + 2,
      cellSize - 4,
      cellSize - 4,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      borderPaint,
    );
  }

  Path _createCellPath(List<CellPosition> cells) {
    if (cells.isEmpty) return Path();

    final path = Path();
    final radius = cellSize * 0.4;

    if (cells.length == 1) {
      final rect = Rect.fromLTWH(
        cells[0].col * cellSize + 2,
        cells[0].row * cellSize + 2,
        cellSize - 4,
        cellSize - 4,
      );
      path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
      return path;
    }

    final first = cells.first;
    final last = cells.last;

    final startCenter = Offset(
      first.col * cellSize + cellSize / 2,
      first.row * cellSize + cellSize / 2,
    );
    final endCenter = Offset(
      last.col * cellSize + cellSize / 2,
      last.row * cellSize + cellSize / 2,
    );

    final dx = endCenter.dx - startCenter.dx;
    final dy = endCenter.dy - startCenter.dy;
    final lengthSq = dx * dx + dy * dy;
    if (lengthSq == 0) {
      final rect = Rect.fromCenter(
          center: startCenter, width: cellSize - 4, height: cellSize - 4);
      path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
      return path;
    }
    final dist = lengthSq > 0 ? lengthSq : 1.0;
    final sqrtDist = _sqrt(dist);
    final perpX = -dy / sqrtDist * (cellSize * 0.4);
    final perpY = dx / sqrtDist * (cellSize * 0.4);

    path.moveTo(startCenter.dx + perpX, startCenter.dy + perpY);
    path.lineTo(endCenter.dx + perpX, endCenter.dy + perpY);
    path.arcToPoint(
      Offset(endCenter.dx - perpX, endCenter.dy - perpY),
      radius: Radius.circular(cellSize * 0.4),
      clockwise: false,
    );
    path.lineTo(startCenter.dx - perpX, startCenter.dy - perpY);
    path.arcToPoint(
      Offset(startCenter.dx + perpX, startCenter.dy + perpY),
      radius: Radius.circular(cellSize * 0.4),
      clockwise: false,
    );
    path.close();

    return path;
  }

  double _sqrt(double value) {
    if (value <= 0) return 0;
    double x = value;
    for (var i = 0; i < 10; i++) {
      x = (x + value / x) / 2;
    }
    return x;
  }

  void _drawGridLines(Canvas canvas, puzzle) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 0.5;

    for (var i = 0; i <= puzzle.rows; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(puzzle.cols * cellSize, i * cellSize),
        paint,
      );
    }
    for (var i = 0; i <= puzzle.cols; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, puzzle.rows * cellSize),
        paint,
      );
    }
  }

  void _drawLetters(Canvas canvas, puzzle) {
    for (var row = 0; row < puzzle.rows; row++) {
      for (var col = 0; col < puzzle.cols; col++) {
        final letter = puzzle.letterAt(row, col);
        final isInSelection = gameState.currentSelection
            .any((c) => c.row == row && c.col == col);
        final isInFoundWord = gameState.foundWordColors.entries.any((entry) {
          final word = gameState.puzzle.words[entry.key];
          return word.cells.any((c) => c.row == row && c.col == col);
        });

        final textColor = (isInSelection || isInFoundWord)
            ? Colors.white
            : (isDark ? Colors.white : const Color(0xFF3E2723));

        final textPainter = TextPainter(
          text: TextSpan(
            text: letter,
            style: TextStyle(
              fontSize: cellSize * 0.5,
              fontWeight: FontWeight.w800,
              color: textColor,
              fontFamily: 'Quicksand',
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            col * cellSize + (cellSize - textPainter.width) / 2,
            row * cellSize + (cellSize - textPainter.height) / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.gameState != gameState ||
        oldDelegate.hintCell != hintCell ||
        oldDelegate.hintOpacity != hintOpacity;
  }
}
