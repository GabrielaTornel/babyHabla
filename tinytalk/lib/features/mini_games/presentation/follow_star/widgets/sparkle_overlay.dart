import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

class SparkleData {
  SparkleData({required this.position})
      : id = '${DateTime.now().microsecondsSinceEpoch}_${math.Random().nextInt(99999)}',
        startMs = DateTime.now().millisecondsSinceEpoch,
        size = 10.0 + math.Random().nextDouble() * 14.0,
        angle = math.Random().nextDouble() * 2 * math.pi,
        spread = 28.0 + math.Random().nextDouble() * 32.0,
        emoji = _emojis[math.Random().nextInt(_emojis.length)];

  final String id;
  final Offset position;
  final int startMs;
  final double size;
  final double angle;
  final double spread;
  final String emoji;

  static const int lifetimeMs = 900;

  static const _emojis = ['✨', '⭐', '💫', '✦', '🌟', '✦', '✨', '✨'];

  double progress(int nowMs) =>
      ((nowMs - startMs) / lifetimeMs).clamp(0.0, 1.0);
}

// ─────────────────────────────────────────────
// Overlay widget
// ─────────────────────────────────────────────

/// Stateless — parent passes [sparkles] and rebuilds at 60fps
/// by wrapping this in an [AnimatedBuilder] or via setState.
class SparkleOverlay extends StatelessWidget {
  const SparkleOverlay({super.key, required this.sparkles});

  final List<SparkleData> sparkles;

  @override
  Widget build(BuildContext context) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    return IgnorePointer(
      child: Stack(
        children: sparkles.map((s) {
          final p = s.progress(nowMs);
          // Fade in quickly, fade out slowly
          final opacity =
              p < 0.25 ? p / 0.25 : (1.0 - (p - 0.25) / 0.75);
          final traveled = p * s.spread;
          final dx = math.cos(s.angle) * traveled;
          final dy = math.sin(s.angle) * traveled - p * 18; // gentle rise

          return Positioned(
            left: s.position.dx - s.size / 2 + dx,
            top: s.position.dy - s.size / 2 + dy,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: (1.0 - p * 0.45).clamp(0.5, 1.0),
                child: Text(
                  s.emoji,
                  style: TextStyle(fontSize: s.size),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
