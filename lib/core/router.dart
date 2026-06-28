import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_quest/features/home/home_screen.dart';
import 'package:word_quest/features/game/game_screen.dart';
import 'package:word_quest/features/game/result_screen.dart';
import 'package:word_quest/features/levels/levels_screen.dart';
import 'package:word_quest/features/levels/theme_levels_screen.dart';
import 'package:word_quest/core/enums.dart';
import 'package:word_quest/features/settings/settings_screen.dart';
import 'package:word_quest/features/achievements/achievements_screen.dart';
import 'package:word_quest/features/statistics/statistics_screen.dart';

/// App router configuration using GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/levels',
      name: 'levels',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LevelsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/theme/:categoryIndex',
      name: 'theme_levels',
      pageBuilder: (context, state) {
        final idx = int.parse(state.pathParameters['categoryIndex']!);
        final category = WordCategory.values[idx.clamp(0, WordCategory.values.length - 1)];
        return CustomTransitionPage(
          key: state.pageKey,
          child: ThemeLevelsScreen(category: category),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeInOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/game/:levelId',
      name: 'game',
      pageBuilder: (context, state) {
        final levelId = int.parse(state.pathParameters['levelId']!);
        return CustomTransitionPage(
          key: state.pageKey,
          child: GameScreen(levelId: levelId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/result/:levelId',
      name: 'result',
      pageBuilder: (context, state) {
        final levelId = int.parse(state.pathParameters['levelId']!);
        final extra = state.extra as Map<String, dynamic>?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ResultScreen(
            levelId: levelId,
            score: extra?['score'] ?? 0,
            timeSeconds: extra?['timeSeconds'] ?? 0,
            wordsFound: extra?['wordsFound'] ?? 0,
            totalWords: extra?['totalWords'] ?? 0,
            hintsUsed: extra?['hintsUsed'] ?? 0,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                      parent: animation, curve: Curves.elasticOut),
                ),
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/achievements',
      name: 'achievements',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AchievementsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/statistics',
      name: 'statistics',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const StatisticsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ),
  ],
);
