import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:word_quest/core/theme.dart';
import 'package:word_quest/features/game/game_providers.dart';
import 'package:word_quest/features/game/widgets/game_grid.dart';
import 'package:word_quest/features/game/widgets/game_timer.dart';
import 'package:word_quest/features/game/widgets/hint_button.dart';
import 'package:word_quest/features/game/widgets/pause_dialog.dart';
import 'package:word_quest/features/game/widgets/word_list_panel.dart';
import 'package:word_quest/widgets/animated_counter.dart';

/// Main game screen with grid, timer, word list, and controls.
class GameScreen extends ConsumerStatefulWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  final GlobalKey<GameGridWidgetState> _gridKey =
      GlobalKey<GameGridWidgetState>();
  bool _showPause = false;
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;

  // Word found animation
  late AnimationController _wordFoundController;
  late Animation<double> _wordFoundScale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );

    _wordFoundController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _wordFoundScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _wordFoundController, curve: Curves.elasticOut),
    );

    // Start game after entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
      ref.read(gameControllerProvider(widget.levelId).notifier).startGame();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _wordFoundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider(widget.levelId));
    final controller =
        ref.read(gameControllerProvider(widget.levelId).notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = ref.read(levelProvider(widget.levelId));

    // Navigate to result on completion and trigger animations
    ref.listen(gameControllerProvider(widget.levelId), (prev, next) {
      if (prev?.isCompleted != true && next.isCompleted) {
        _wordFoundController.forward(from: 0);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!context.mounted) return;
          controller.saveResults();
          context.goNamed('result', pathParameters: {
            'levelId': widget.levelId.toString()
          }, extra: {
            'score': next.score,
            'timeSeconds': next.elapsedSeconds,
            'wordsFound': next.wordsFound,
            'totalWords': next.totalWords,
            'hintsUsed': next.hintsUsed,
          });
        });
      }

      // Trigger word found animation
      if (prev != null && next.wordsFound > prev.wordsFound) {
        _wordFoundController.forward(from: 0);
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackground
              : AppTheme.warmBackground,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // ── Top Bar ──
                  _buildTopBar(context, gameState, level, isDark),

                  // ── Progress Bar ──
                  _buildProgressBar(gameState, isDark),

                  // ── Grid ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: FadeTransition(
                        opacity: _entranceAnimation,
                        child: ScaleTransition(
                          scale: _entranceAnimation,
                          child: GameGrid(
                            key: _gridKey,
                            levelId: widget.levelId,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Word List ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'WORD LIST',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        WordListPanel(levelId: widget.levelId),
                      ],
                    ),
                  ),

                  // ── Bottom Controls ──
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HintButton(
                          hintsRemaining: ref
                              .read(storageRepositoryProvider)
                              .loadPlayerProfile()
                              .hintsRemaining,
                          enabled: gameState.isPlaying,
                          onPressed: () {
                            final cell = controller.useHint();
                            if (cell != null) {
                              _gridKey.currentState?.showHint(cell);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Pause overlay
              if (_showPause)
                PauseDialog(
                  onResume: () {
                    setState(() => _showPause = false);
                    controller.resumeGame();
                  },
                  onRestart: () {
                    setState(() => _showPause = false);
                    ref.invalidate(puzzleProvider(widget.levelId));
                    ref.invalidate(gameControllerProvider(widget.levelId));
                    ref
                        .read(gameControllerProvider(widget.levelId).notifier)
                        .startGame();
                  },
                  onQuit: () {
                    setState(() => _showPause = false);
                    context.goNamed('home');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    dynamic gameState,
    dynamic level,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Pause button
          _buildIconButton(
            icon: Icons.pause_rounded,
            isDark: isDark,
            onTap: () {
              ref
                  .read(gameControllerProvider(widget.levelId).notifier)
                  .pauseGame();
              setState(() => _showPause = true);
            },
          ),

          const SizedBox(width: 8),

          // Level info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Level ${widget.levelId}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          const Spacer(),

          // Score
          ScaleTransition(
            scale: _wordFoundScale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  AnimatedCounter(value: gameState.score),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Timer
          GameTimer(elapsedSeconds: gameState.elapsedSeconds),
        ],
      ),
    );
  }

  Widget _buildProgressBar(dynamic gameState, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${gameState.wordsFound}/${gameState.totalWords} words',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
              Text(
                '${(gameState.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: gameState.progress,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }
}
