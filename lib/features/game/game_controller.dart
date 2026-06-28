import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_quest/core/constants.dart';
import 'package:word_quest/core/enums.dart';
import 'package:word_quest/data/repositories/storage_repository.dart';
import 'package:word_quest/data/services/sound_service.dart';
import 'package:word_quest/domain/models/cell.dart';
import 'package:word_quest/domain/models/game_state.dart';
import 'package:word_quest/domain/models/puzzle.dart';

/// Controls the game session: puzzle state, timer, scoring, word validation.
class GameController extends StateNotifier<GameState> {
  final StorageRepository _storage;
  final SoundService _sound;
  final int levelId;
  Timer? _timer;
  int _colorIndex = 0;

  GameController({
    required Puzzle puzzle,
    required StorageRepository storage,
    required SoundService sound,
    required this.levelId,
  })  : _storage = storage,
        _sound = sound,
        super(GameState(puzzle: puzzle));

  /// Start the game and timer.
  void startGame() {
    state = state.copyWith(status: GameStatus.playing);
    _startTimer();
  }

  /// Pause the game.
  void pauseGame() {
    _timer?.cancel();
    state = state.copyWith(status: GameStatus.paused);
  }

  /// Resume from pause.
  void resumeGame() {
    state = state.copyWith(status: GameStatus.playing);
    _startTimer();
  }

  /// Handle drag start on a cell.
  void onSelectionStart(CellPosition cell) {
    if (!state.isPlaying) return;
    state = state.copyWith(
      currentSelection: [cell],
      selectionStart: cell,
    );
  }

  /// Handle drag update — calculate the line of cells from start to current.
  void onSelectionUpdate(CellPosition cell) {
    if (!state.isPlaying || state.selectionStart == null) return;

    final start = state.selectionStart!;
    final cells = _calculateLineCells(start, cell);

    if (cells.isNotEmpty) {
      state = state.copyWith(currentSelection: cells);
    }
  }

  /// Handle drag end — validate the selection against word list.
  void onSelectionEnd() {
    if (!state.isPlaying || state.currentSelection.isEmpty) {
      state = state.copyWith(clearSelection: true);
      return;
    }

    final selectedWord = _getSelectedWord(state.currentSelection);
    final reverseWord = selectedWord.split('').reversed.join();

    // Check if selection matches any unfound word
    int? foundIndex;
    for (var i = 0; i < state.puzzle.words.length; i++) {
      final word = state.puzzle.words[i];
      if (!word.isFound &&
          (word.gridWord == selectedWord || word.gridWord == reverseWord)) {
        foundIndex = i;
        break;
      }
    }

    if (foundIndex != null) {
      _onWordFound(foundIndex);
    } else {
      state = state.copyWith(clearSelection: true);
    }
  }

  /// Use a hint: highlight the first letter of a random unfound word.
  CellPosition? useHint() {
    if (!state.isPlaying) return null;

    final unfoundWords = <int>[];
    for (var i = 0; i < state.puzzle.words.length; i++) {
      if (!state.puzzle.words[i].isFound) {
        unfoundWords.add(i);
      }
    }

    if (unfoundWords.isEmpty) return null;

    // Pick a random unfound word
    unfoundWords.shuffle();
    final wordIndex = unfoundWords.first;
    final word = state.puzzle.words[wordIndex];
    final firstCell = word.cells.first;

    state = state.copyWith(
      hintsUsed: state.hintsUsed + 1,
      score: (state.score - AppConstants.hintPenalty).clamp(0, 999999),
    );

    _sound.playHint();
    return firstCell;
  }

  /// Calculate star rating based on performance.
  int calculateStars() {
    final puzzle = state.puzzle;
    final timeLimit =
        AppConstants.timeLimitForDifficulty(puzzle.difficulty.gridSize);
    final maxScore = puzzle.totalWords * AppConstants.baseScorePerWord +
        timeLimit * AppConstants.bonusPerRemainingSecond;

    final ratio = state.score / maxScore;

    if (ratio >= AppConstants.threeStarThreshold) return 3;
    if (ratio >= AppConstants.twoStarThreshold) return 2;
    return 1;
  }

  /// Save game results to storage.
  Future<void> saveResults() async {
    final stars = calculateStars();

    // Save level progress
    var level = _storage.loadLevel(levelId);
    final isNewBest = state.score > level.bestScore;
    level = level.copyWith(
      stars: stars > level.stars ? stars : level.stars,
      isUnlocked: true,
      bestScore: isNewBest ? state.score : level.bestScore,
      bestTimeSeconds: level.bestTimeSeconds == 0 ||
              state.elapsedSeconds < level.bestTimeSeconds
          ? state.elapsedSeconds
          : level.bestTimeSeconds,
    );
    await _storage.saveLevel(level);

    // Unlock next level
    final nextLevel = _storage.loadLevel(levelId + 1);
    if (!nextLevel.isUnlocked) {
      await _storage.saveLevel(nextLevel.copyWith(isUnlocked: true));
    }

    // Update player profile
    var profile = _storage.loadPlayerProfile();
    final now = DateTime.now();
    final lastPlayed = profile.lastPlayedDate;
    final dayDiff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastPlayed.year, lastPlayed.month, lastPlayed.day))
        .inDays;

    int newStreak = profile.currentStreak;
    if (dayDiff == 1) {
      newStreak = profile.currentStreak + 1;
    } else if (dayDiff > 1) {
      newStreak = 1;
    }

    profile = profile.copyWith(
      totalScore: profile.totalScore + state.score,
      totalStarsEarned: profile.totalStarsEarned + stars,
      levelsCompleted: profile.levelsCompleted + 1,
      wordsFound: profile.wordsFound + state.wordsFound,
      currentStreak: newStreak,
      bestStreak:
          newStreak > profile.bestStreak ? newStreak : profile.bestStreak,
      hintsRemaining:
          (profile.hintsRemaining - state.hintsUsed).clamp(0, AppConstants.maxHints),
      lastPlayedDate: now,
      gamesPlayed: profile.gamesPlayed + 1,
    );
    await _storage.savePlayerProfile(profile);

    // Update statistics
    var stats = _storage.loadStatistics();
    stats = stats.copyWith(
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalWordsFound: stats.totalWordsFound + state.wordsFound,
      totalScore: stats.totalScore + state.score,
      totalPlayTimeSeconds: stats.totalPlayTimeSeconds + state.elapsedSeconds,
      levelsCompleted: stats.levelsCompleted + 1,
      totalHintsUsed: stats.totalHintsUsed + state.hintsUsed,
      totalThreeStarLevels:
          stats.totalThreeStarLevels + (stars == 3 ? 1 : 0),
      longestStreak: newStreak > stats.longestStreak
          ? newStreak
          : stats.longestStreak,
    );
    await _storage.saveStatistics(stats);
  }

  // ── Private Helpers ──

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isPlaying) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void _onWordFound(int wordIndex) {
    final highlightColor = AppConstants
        .highlightColors[_colorIndex % AppConstants.highlightColors.length];
    _colorIndex++;

    final updatedPuzzle = state.puzzle.withWordFound(wordIndex);
    final newFoundColors = Map<int, Color>.from(state.foundWordColors);
    newFoundColors[wordIndex] = highlightColor;

    // Calculate score for this word
    final word = state.puzzle.words[wordIndex];
    final wordScore = AppConstants.baseScorePerWord +
        (word.gridWord.length * AppConstants.streakMultiplier) +
        (state.consecutiveWordsFound * AppConstants.streakMultiplier);

    state = state.copyWith(
      puzzle: updatedPuzzle,
      score: state.score + wordScore,
      foundWordColors: newFoundColors,
      consecutiveWordsFound: state.consecutiveWordsFound + 1,
      clearSelection: true,
    );

    _sound.playWordFound();

    // Check for completion
    if (updatedPuzzle.isComplete) {
      _timer?.cancel();
      // Add time bonus
      final timeLimit = AppConstants.timeLimitForDifficulty(
          updatedPuzzle.difficulty.gridSize);
      final remainingTime = (timeLimit - state.elapsedSeconds).clamp(0, timeLimit);
      final timeBonus =
          remainingTime * AppConstants.bonusPerRemainingSecond;

      state = state.copyWith(
        status: GameStatus.completed,
        score: state.score + timeBonus,
      );

      _sound.playLevelComplete();
    }
  }

  /// Calculate a straight line of cells from start to end.
  /// Returns empty list if not a valid straight line.
  List<CellPosition> _calculateLineCells(
    CellPosition start,
    CellPosition end,
  ) {
    final dr = end.row - start.row;
    final dc = end.col - start.col;

    // Must be a straight line (horizontal, vertical, or diagonal)
    if (dr != 0 && dc != 0 && dr.abs() != dc.abs()) {
      return [];
    }

    final steps = [dr.abs(), dc.abs()].reduce((a, b) => a > b ? a : b);
    if (steps == 0) return [start];

    final stepR = dr == 0 ? 0 : dr ~/ dr.abs();
    final stepC = dc == 0 ? 0 : dc ~/ dc.abs();

    final cells = <CellPosition>[];
    for (var i = 0; i <= steps; i++) {
      final pos = CellPosition(
        row: start.row + i * stepR,
        col: start.col + i * stepC,
      );
      if (pos.isInBounds(state.puzzle.rows, state.puzzle.cols)) {
        cells.add(pos);
      } else {
        return [];
      }
    }

    return cells;
  }

  /// Get the word string from selected cells.
  String _getSelectedWord(List<CellPosition> cells) {
    return cells
        .map((c) => state.puzzle.letterAt(c.row, c.col))
        .join();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
