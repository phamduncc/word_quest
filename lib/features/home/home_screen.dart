import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:word_quest/core/theme.dart';
import 'package:word_quest/features/game/game_providers.dart';
import 'package:word_quest/widgets/animated_button.dart';
import 'package:word_quest/widgets/gradient_text.dart';
import 'package:word_quest/widgets/particle_background.dart';

/// Home screen with Play button, navigation menu, and animated background.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _menuController;
  late AnimationController _playController;
  late Animation<double> _titleAnimation;
  late Animation<double> _playPulse;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    );

    _menuController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _menuController.forward();
    });

    _playController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _playPulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _playController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _menuController.dispose();
    _playController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.read(storageRepositoryProvider).loadPlayerProfile();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackground
              : AppTheme.warmBackground,
        ),
        child: ParticleBackground(
          particleCount: 15,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // ── App Title ──
                    ScaleTransition(
                      scale: _titleAnimation,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GradientText(
                            text: 'WORD QUEST',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            gradient: isDark
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF66BB6A),
                                      Color(0xFF4FC3F7)
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFF2E7D32),
                                      Color(0xFF4CAF50)
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'English Word Search Game',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Play Button ──
                    ScaleTransition(
                      scale: _playPulse,
                      child: AnimatedButton(
                        onPressed: () {
                          final storage = ref.read(storageRepositoryProvider);
                          int nextLevel = 1;
                          for (var i = 1; i <= 200; i++) {
                            final level = storage.loadLevel(i);
                            if (!level.isCompleted) {
                              nextLevel = i;
                              break;
                            }
                          }
                          context.goNamed('game', pathParameters: {
                            'levelId': nextLevel.toString(),
                          });
                        },
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: AppTheme.buttonShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 32),
                            const SizedBox(width: 8),
                            const Text(
                              'PLAY',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Menu Grid ──
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _menuController,
                        curve: Curves.easeOut,
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _menuController,
                          curve: Curves.easeOut,
                        )),
                        child: _buildMenuGrid(context, isDark),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Player Stats Summary ──
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _menuController,
                        curve: Curves.easeOut,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniStat(
                              icon: Icons.star_rounded,
                              value: '${profile.totalStarsEarned}',
                              label: 'Stars',
                              color: const Color(0xFFFFB300),
                              isDark: isDark,
                            ),
                            _buildMiniStat(
                              icon: Icons.emoji_events_rounded,
                              value: '${profile.levelsCompleted}',
                              label: 'Levels',
                              color: const Color(0xFF4CAF50),
                              isDark: isDark,
                            ),
                            _buildMiniStat(
                              icon: Icons.local_fire_department_rounded,
                              value: '${profile.currentStreak}',
                              label: 'Streak',
                              color: const Color(0xFFFF5722),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, bool isDark) {
    final items = [
      _MenuItem(
        icon: Icons.grid_view_rounded,
        label: 'Levels',
        color: const Color(0xFF4CAF50),
        onTap: () => context.goNamed('levels'),
      ),
      _MenuItem(
        icon: Icons.today_rounded,
        label: 'Daily',
        color: const Color(0xFF03A9F4),
        onTap: () {
          final now = DateTime.now();
          final dailyLevelId =
              100000 + now.year * 10000 + now.month * 100 + now.day;
          context.goNamed('game', pathParameters: {
            'levelId': dailyLevelId.toString(),
          });
        },
      ),
      _MenuItem(
        icon: Icons.emoji_events_rounded,
        label: 'Awards',
        color: const Color(0xFFFF9800),
        onTap: () => context.goNamed('achievements'),
      ),
      _MenuItem(
        icon: Icons.bar_chart_rounded,
        label: 'Stats',
        color: const Color(0xFF9C27B0),
        onTap: () => context.goNamed('statistics'),
      ),
      _MenuItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
        color: const Color(0xFF607D8B),
        onTap: () => context.goNamed('settings'),
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        return AnimatedButton(
          onPressed: item.onTap,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: item.color.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            width: 100,
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
