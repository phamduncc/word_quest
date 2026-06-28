import 'package:flutter/material.dart';
import 'package:word_quest/core/extensions.dart';

/// Animated timer display widget.
class GameTimer extends StatelessWidget {
  final int elapsedSeconds;

  const GameTimer({super.key, required this.elapsedSeconds});

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: elapsedSeconds);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            duration.mmss,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
