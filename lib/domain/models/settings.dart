import 'package:equatable/equatable.dart';

/// App settings persisted locally.
class Settings extends Equatable {
  final bool isDarkMode;
  final bool isSoundEnabled;
  final bool isMusicEnabled;
  final bool isHapticEnabled;

  const Settings({
    this.isDarkMode = false,
    this.isSoundEnabled = true,
    this.isMusicEnabled = true,
    this.isHapticEnabled = true,
  });

  Settings copyWith({
    bool? isDarkMode,
    bool? isSoundEnabled,
    bool? isMusicEnabled,
    bool? isHapticEnabled,
  }) {
    return Settings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isHapticEnabled: isHapticEnabled ?? this.isHapticEnabled,
    );
  }

  @override
  List<Object?> get props =>
      [isDarkMode, isSoundEnabled, isMusicEnabled, isHapticEnabled];
}
