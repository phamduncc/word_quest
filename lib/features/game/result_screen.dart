import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_quest/core/extensions.dart';
import 'package:word_quest/core/theme.dart';
import 'package:word_quest/widgets/star_display.dart';

/// Level completion result screen with celebration animations.
class ResultScreen extends StatefulWidget {
  final int levelId;
  final int score;
  final int timeSeconds;
  final int wordsFound;
  final int totalWords;
  final int hintsUsed;

  const ResultScreen({
    super.key,
    required this.levelId,
    required this.score,
    required this.timeSeconds,
    required this.wordsFound,
    required this.totalWords,
    required this.hintsUsed,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _starsController;
  late AnimationController _scoreController;
  late AnimationController _buttonsController;
  late Animation<double> _starsAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _buttonsAnimation;

  int get _stars {
    // Simple star calculation
    final ratio = widget.wordsFound / widget.totalWords;
    if (ratio >= 1.0 && widget.hintsUsed == 0) return 3;
    if (ratio >= 1.0) return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _starsAnimation = CurvedAnimation(
      parent: _starsController,
      curve: Curves.elasticOut,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutBack,
    );

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonsAnimation = CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOutCubic,
    );

    // Staggered entrance
    _confettiController.play();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _starsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _scoreController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _buttonsController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _starsController.dispose();
    _scoreController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duration = Duration(seconds: widget.timeSeconds);

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
              // Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        'COMPLETED! 🎉',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Level ${widget.levelId}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Stars
                      ScaleTransition(
                        scale: _starsAnimation,
                        child: StarDisplay(
                          stars: _stars,
                          maxStars: 3,
                          size: 56,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Stats cards
                      FadeTransition(
                        opacity: _scoreAnimation,
                        child: ScaleTransition(
                          scale: _scoreAnimation,
                          child: _buildStatsGrid(isDark, duration),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Buttons
                      FadeTransition(
                        opacity: _buttonsAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_buttonsAnimation),
                          child: Column(
                            children: [
                              // Next Level
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.goNamed('game', pathParameters: {
                                      'levelId':
                                          (widget.levelId + 1).toString(),
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('NEXT LEVEL'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Replay
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.goNamed('game', pathParameters: {
                                      'levelId': widget.levelId.toString(),
                                    });
                                  },
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('REPLAY'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark
                                        ? Colors.white
                                        : const Color(0xFF4CAF50),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    side: BorderSide(
                                      color: isDark
                                          ? Colors.white30
                                          : const Color(0xFF4CAF50),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Home
                              TextButton.icon(
                                onPressed: () => context.goNamed('home'),
                                icon: const Icon(Icons.home_rounded),
                                label: const Text('Home'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      isDark ? Colors.white54 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 20,
                  minBlastForce: 5,
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.15,
                  colors: const [
                    Color(0xFF4CAF50),
                    Color(0xFFFF9800),
                    Color(0xFF03A9F4),
                    Color(0xFFE91E63),
                    Color(0xFFFFEB3B),
                    Color(0xFF9C27B0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark, Duration duration) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFB300),
                  label: 'Score',
                  value: '${widget.score}',
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.timer_rounded,
                  iconColor: const Color(0xFF03A9F4),
                  label: 'Time',
                  value: duration.mmss,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.search_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  label: 'Words Found',
                  value: '${widget.wordsFound}/${widget.totalWords}',
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.lightbulb_outline_rounded,
                  iconColor: const Color(0xFFFFC107),
                  label: 'Hints',
                  value: '${widget.hintsUsed}',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
