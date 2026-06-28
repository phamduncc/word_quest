import 'dart:math';
import 'package:flutter/material.dart';

/// Floating particles/bubbles background decoration.
class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color? particleColor;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    final random = Random();
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 4 + random.nextDouble() * 12,
        speed: 0.02 + random.nextDouble() * 0.05,
        opacity: 0.05 + random.nextDouble() * 0.15,
        wobble: random.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Particles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                color: widget.particleColor ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF4CAF50)),
              ),
              size: Size.infinite,
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double wobble;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.wobble,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y =
          (particle.y - progress * particle.speed) % 1.0;
      final wobbleX =
          sin(progress * 2 * pi + particle.wobble) * 0.02;
      final x = (particle.x + wobbleX) % 1.0;

      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
