import 'package:flutter/material.dart';

/// A very subtle, abstract dot/bead pattern — a generic string-of-beads
/// texture, not tied to any single tradition's iconography.
class BeadPatternBackground extends StatelessWidget {
  final Widget child;
  const BeadPatternBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _BeadDotsPainter(isDark: isDark),
          ),
        ),
        child,
      ],
    );
  }
}

class _BeadDotsPainter extends CustomPainter {
  final bool isDark;
  _BeadDotsPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF2E2233))
          .withValues(alpha: isDark ? 0.05 : 0.04);
    const spacing = 34.0;
    const radius = 1.6;
    for (double y = 0; y < size.height; y += spacing) {
      final rowOffset = ((y / spacing).floor().isOdd) ? spacing / 2 : 0.0;
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x + rowOffset, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BeadDotsPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
