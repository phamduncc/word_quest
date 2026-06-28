import 'package:flutter/material.dart';

/// Reusable star rating display with optional animation.
class StarDisplay extends StatelessWidget {
  final int stars;
  final int maxStars;
  final double size;
  final bool animated;

  const StarDisplay({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 32,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final isFilled = index < stars;

        if (animated) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isFilled ? 1.0 : 0.3),
            duration: Duration(milliseconds: 500 + (200 * index)),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: size,
                    color: isFilled
                        ? Color.lerp(
                            Colors.grey, const Color(0xFFFFB300), value)
                        : Colors.grey.shade400,
                  ),
                ),
              );
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color:
                isFilled ? const Color(0xFFFFB300) : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}
