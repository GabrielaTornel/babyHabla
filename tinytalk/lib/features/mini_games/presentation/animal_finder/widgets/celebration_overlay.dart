import 'dart:math' as math;

import 'package:flutter/material.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key, required this.onDismissed});

  final VoidCallback onDismissed;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _Star {
  _Star(math.Random rng)
      : x = rng.nextDouble(),
        startY = 0.05 + rng.nextDouble() * 0.30,
        emoji = _emojis[rng.nextInt(_emojis.length)],
        size = 18.0 + rng.nextDouble() * 14.0,
        speed = 0.20 + rng.nextDouble() * 0.30,
        rotationDir = rng.nextBool() ? 1.0 : -1.0;

  final double x, startY, size, speed, rotationDir;
  final String emoji;

  static const _emojis = ['⭐', '🌟', '✨', '🎉', '🎊', '💫', '🐾'];
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _stars = List.generate(16, (_) => _Star(rng));

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          final size = MediaQuery.of(context).size;
          return Stack(
            children: _stars.map((s) {
              final currentY = s.startY + s.speed * t;
              final opacity = (1.0 - t * 1.3).clamp(0.0, 1.0);
              return Positioned(
                left: size.width * s.x,
                top: size.height * currentY,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: s.rotationDir * t * math.pi * 2,
                    child: Text(
                      s.emoji,
                      style: TextStyle(fontSize: s.size),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
