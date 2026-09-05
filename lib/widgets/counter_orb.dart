import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The large tap target on the Counter screen: a soft glowing orb with a
/// circular progress ring, showing `count / target`. Handles its own tap
/// bounce and exposes [CounterOrbState.playCompletionPulse] for the brighter
/// glow pulse when a round completes.
class CounterOrb extends StatefulWidget {
  final int count;
  final int target;
  final VoidCallback onTap;
  final double size;

  const CounterOrb({
    super.key,
    required this.count,
    required this.target,
    required this.onTap,
    this.size = 260,
  });

  @override
  State<CounterOrb> createState() => CounterOrbState();
}

class CounterOrbState extends State<CounterOrb> with TickerProviderStateMixin {
  late final AnimationController _tapController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.94).animate(
    CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _tapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) => _tapController.reverse());
    widget.onTap();
  }

  void playCompletionPulse() {
    _pulseController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.target == 0
        ? 0.0
        : (widget.count / widget.target).clamp(0.0, 1.0);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_tapController, _pulseController]),
        builder: (context, child) {
          final pulseValue = math.sin(_pulseController.value * math.pi);
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: BeadlyColors.accentGold
                        .withValues(alpha: 0.18 + 0.35 * pulseValue),
                    blurRadius: 50 + 40 * pulseValue,
                    spreadRadius: 4 + 14 * pulseValue,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _RingPainter(
                  progress: progress,
                  trackColor: (isDark ? Colors.white : BeadlyColors.lightText)
                      .withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Container(
                    width: widget.size - 34,
                    height: widget.size - 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                      gradient: RadialGradient(
                        colors: [
                          BeadlyColors.accentGold
                              .withValues(alpha: isDark ? 0.16 : 0.10),
                          Theme.of(context).colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.count}',
                          style: textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '/ ${widget.target}',
                          style: textTheme.titleMedium?.copyWith(
                            color: textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  _RingPainter({required this.progress, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 12) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;
    final foreground = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: sweep,
        colors: const [BeadlyColors.accentGold, BeadlyColors.accentRose],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, foreground);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.trackColor != trackColor;
}
