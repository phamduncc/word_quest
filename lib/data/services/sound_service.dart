import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Service for playing sound effects and background music.
///
/// Gracefully handles missing audio assets by catching errors silently.
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
    if (!enabled) {
      _sfxPlayer.stop();
    }
  }

  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    }
  }

  /// Play a short sound effect.
  Future<void> playTap() => _playSfx('assets/audio/tap.mp3');
  Future<void> playWordFound() => _playSfx('assets/audio/word_found.mp3');
  Future<void> playLevelComplete() =>
      _playSfx('assets/audio/level_complete.mp3');
  Future<void> playHint() => _playSfx('assets/audio/hint.mp3');
  Future<void> playStar() => _playSfx('assets/audio/star.mp3');
  Future<void> playButtonPress() => _playSfx('assets/audio/button.mp3');

  /// Play haptic feedback.
  Future<void> playHaptic() async {
    await HapticFeedback.lightImpact();
  }

  /// Play heavy haptic for important events.
  Future<void> playHeavyHaptic() async {
    await HapticFeedback.heavyImpact();
  }

  Future<void> _playSfx(String assetPath) async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (_) {
      // Audio file not found — silently ignore
    }
  }

  /// Start background music loop.
  Future<void> startMusic() async {
    if (!_isMusicEnabled) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.3);
      await _musicPlayer
          .play(AssetSource('audio/background_music.mp3'));
    } catch (_) {
      // Music file not found — silently ignore
    }
  }

  /// Stop background music.
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  /// Clean up resources.
  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
