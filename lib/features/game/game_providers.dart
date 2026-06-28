import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_quest/data/repositories/storage_repository.dart';
import 'package:word_quest/data/services/puzzle_generator.dart';
import 'package:word_quest/data/services/sound_service.dart';
import 'package:word_quest/domain/models/game_state.dart';
import 'package:word_quest/domain/models/level.dart';
import 'package:word_quest/domain/models/puzzle.dart';
import 'package:word_quest/features/game/game_controller.dart';

// ── Storage ──
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

// ── Sound ──
final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});

// ── Level Data ──
final levelProvider = Provider.family<Level, int>((ref, levelId) {
  final storage = ref.read(storageRepositoryProvider);
  return storage.loadLevel(levelId);
});

// ── Puzzle Generation ──
final puzzleProvider = Provider.autoDispose.family<Puzzle, int>((ref, levelId) {
  final level = ref.read(levelProvider(levelId));
  final randomSeed = DateTime.now().microsecondsSinceEpoch ^ levelId;
  return PuzzleGenerator.generate(
    difficulty: level.difficulty,
    category: level.category,
    seed: randomSeed,
    levelId: levelId,
  );
});

// ── Settings ──
final settingsProvider = Provider<dynamic>((ref) {
  final storage = ref.read(storageRepositoryProvider);
  return storage.loadSettings();
});

// ── Game Controller ──
final gameControllerProvider =
    StateNotifierProvider.autoDispose.family<GameController, GameState, int>(
  (ref, levelId) {
    final puzzle = ref.read(puzzleProvider(levelId));
    final storage = ref.read(storageRepositoryProvider);
    final sound = ref.read(soundServiceProvider);

    return GameController(
      puzzle: puzzle,
      storage: storage,
      sound: sound,
      levelId: levelId,
    );
  },
);
