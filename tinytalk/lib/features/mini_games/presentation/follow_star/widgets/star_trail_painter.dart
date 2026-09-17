import 'package:flutter/material.dart';

/// Draws a fading golden trail behind the moving star.
class StarTrailPainter extends CustomPainter {
  const StarTrailPainter({required this.trail});

  final List<Offset> trail;

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.length < 2) return;

    final len = trail.length;
    for (int i = 1; i < len; i++) {
      final t = i / len; // 0 = oldest, 1 = newest
      final alpha = t * t * 0.65; // quadratic fade
      final radius = 2.0 + t * 5.5;

      final paint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.7);

      canvas.drawCircle(trail[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(StarTrailPainter oldDelegate) =>
      oldDelegate.trail != trail;
}
