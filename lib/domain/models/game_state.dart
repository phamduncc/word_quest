import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:word_quest/core/enums.dart';
import 'package:word_quest/domain/models/cell.dart';
import 'package:word_quest/domain/models/puzzle.dart';

/// Current state of a game session.
class GameState extends Equatable {
  final Puzzle puzzle;
  final GameStatus status;
  final int score;
  final int elapsedSeconds;
  final int hintsUsed;
  final List<CellPosition> currentSelection;
  final CellPosition? selectionStart;
  final Map<int, Color> foundWordColors; // wordIndex -> highlight color
  final int consecutiveWordsFound; // for combo bonus

  const GameState({
    required this.puzzle,
    this.status = GameStatus.notStarted,
    this.score = 0,
    this.elapsedSeconds = 0,
    this.hintsUsed = 0,
    this.currentSelection = const [],
    this.selectionStart,
    this.foundWordColors = const {},
    this.consecutiveWordsFound = 0,
  });

  bool get isPlaying => status == GameStatus.playing;
  bool get isPaused => status == GameStatus.paused;
  bool get isCompleted => status == GameStatus.completed;

  int get wordsFound => puzzle.foundWords;
  int get totalWords => puzzle.totalWords;
  double get progress =>
      totalWords > 0 ? wordsFound / totalWords : 0.0;

  GameState copyWith({
    Puzzle? puzzle,
    GameStatus? status,
    int? score,
    int? elapsedSeconds,
    int? hintsUsed,
    List<CellPosition>? currentSelection,
    CellPosition? selectionStart,
    bool clearSelection = false,
    Map<int, Color>? foundWordColors,
    int? consecutiveWordsFound,
  }) {
    return GameState(
      puzzle: puzzle ?? this.puzzle,
      status: status ?? this.status,
      score: score ?? this.score,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      currentSelection: clearSelection
          ? const []
          : (currentSelection ?? this.currentSelection),
      selectionStart:
          clearSelection ? null : (selectionStart ?? this.selectionStart),
      foundWordColors: foundWordColors ?? this.foundWordColors,
      consecutiveWordsFound:
          consecutiveWordsFound ?? this.consecutiveWordsFound,
    );
  }

  @override
  List<Object?> get props => [
        puzzle,
        status,
        score,
        elapsedSeconds,
        hintsUsed,
        currentSelection,
        selectionStart,
        foundWordColors,
        consecutiveWordsFound,
      ];
}
