import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:word_quest/core/theme.dart';
import 'package:word_quest/data/services/sound_service.dart';
import 'package:word_quest/domain/models/settings.dart';
import 'package:word_quest/features/game/game_providers.dart';

/// Settings notifier backed by Hive.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  final storage = ref.read(storageRepositoryProvider);
  return SettingsNotifier(storage);
});

class SettingsNotifier extends StateNotifier<Settings> {
  final dynamic _storage;

  SettingsNotifier(this._storage) : super(_storage.loadSettings());

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _storage.saveSettings(state);
  }

  void toggleSound() {
    state = state.copyWith(isSoundEnabled: !state.isSoundEnabled);
    _storage.saveSettings(state);
    SoundService().setSoundEnabled(state.isSoundEnabled);
  }

  void toggleMusic() {
    state = state.copyWith(isMusicEnabled: !state.isMusicEnabled);
    _storage.saveSettings(state);
    SoundService().setMusicEnabled(state.isMusicEnabled);
    if (!state.isMusicEnabled) {
      SoundService().stopMusic();
    }
  }

  void toggleHaptic() {
    state = state.copyWith(isHapticEnabled: !state.isHapticEnabled);
    _storage.saveSettings(state);
  }
}

/// Settings screen with toggles for dark mode, sound, music, haptics.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackground
              : AppTheme.warmBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.goNamed('home'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Dark Mode
                    _buildSettingsTile(
                      context,
                      icon: Icons.dark_mode_rounded,
                      iconColor: const Color(0xFF5C6BC0),
                      title: 'Dark Mode',
                      subtitle: 'Enable dark theme',
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: settings.isDarkMode,
                        onChanged: (_) => settingsNotifier.toggleDarkMode(),
                        activeTrackColor: const Color(0xFF4CAF50),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Sound Effects
                    _buildSettingsTile(
                      context,
                      icon: Icons.volume_up_rounded,
                      iconColor: const Color(0xFF03A9F4),
                      title: 'Sound Effects',
                      subtitle: 'Game sound effects',
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: settings.isSoundEnabled,
                        onChanged: (_) => settingsNotifier.toggleSound(),
                        activeTrackColor: const Color(0xFF4CAF50),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Music
                    _buildSettingsTile(
                      context,
                      icon: Icons.music_note_rounded,
                      iconColor: const Color(0xFFE91E63),
                      title: 'Background Music',
                      subtitle: 'Game background music',
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: settings.isMusicEnabled,
                        onChanged: (_) => settingsNotifier.toggleMusic(),
                        activeTrackColor: const Color(0xFF4CAF50),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Haptic
                    _buildSettingsTile(
                      context,
                      icon: Icons.vibration_rounded,
                      iconColor: const Color(0xFFFF9800),
                      title: 'Haptic Feedback',
                      subtitle: 'Vibrate on interaction',
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: settings.isHapticEnabled,
                        onChanged: (_) => settingsNotifier.toggleHaptic(),
                        activeTrackColor: const Color(0xFF4CAF50),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Reset Progress
                    _buildSettingsTile(
                      context,
                      icon: Icons.restore_rounded,
                      iconColor: const Color(0xFFE53935),
                      title: 'Reset Progress',
                      subtitle: 'Delete all game data',
                      isDark: isDark,
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? Colors.white24 : Colors.grey.shade400,
                      ),
                      onTap: () => _showResetDialog(context, ref),
                    ),

                    const SizedBox(height: 32),

                    // About
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Word Quest',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'English word search game\nfor everyone 🇬🇧',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('⚠️ Reset'),
        content: const Text(
          'Are you sure you want to delete all progress?\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(storageRepositoryProvider).resetAllProgress();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All progress has been reset'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
