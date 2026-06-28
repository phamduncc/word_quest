import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_quest/core/router.dart';
import 'package:word_quest/core/theme.dart';
import 'package:word_quest/data/hive/hive_boxes.dart';
import 'package:word_quest/data/services/sound_service.dart';
import 'package:word_quest/features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await HiveBoxes.initialize();

  // Initialize sound service
  SoundService();

  runApp(
    const ProviderScope(
      child: WordQuestApp(),
    ),
  );
}

/// Root application widget.
class WordQuestApp extends ConsumerWidget {
  const WordQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // Update system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      settings.isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: const Color(0xFF0F0F23),
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: const Color(0xFFF1F8E9),
            ),
    );

    return MaterialApp.router(
      title: 'Word Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
