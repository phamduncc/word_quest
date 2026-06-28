import 'package:flutter/material.dart';

/// Convenience extensions on [BuildContext].
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mq => MediaQuery.of(this);
  double get screenWidth => mq.size.width;
  double get screenHeight => mq.size.height;
  bool get isDarkMode => theme.brightness == Brightness.dark;
}

/// Duration formatting for timer display.
extension DurationX on Duration {
  /// Format as "mm:ss".
  String get mmss {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format as "hh:mm:ss" for longer durations.
  String get hhmmss {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

/// List utilities.
extension ListX<T> on List<T> {
  /// Returns a new shuffled copy without modifying the original.
  List<T> shuffledCopy() {
    final copy = List<T>.from(this);
    copy.shuffle();
    return copy;
  }
}
