import 'dart:math' as math;

import 'package:flutter/material.dart';

class NightSkyBackground extends StatefulWidget {
  const NightSkyBackground({super.key, required this.child});

  final Widget child;

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkleCtrl;
  late final List<_BackgroundStar> _bgStars;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42); // fixed seed = stable layout
    _bgStars = List.generate(
      32,
      (_) => _BackgroundStar(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.75,
        size: 1.5 + rng.nextDouble() * 2.8,
        phase: rng.nextDouble(),
      ),
    );

    _twinkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _twinkleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Night sky gradient ────────────────────────────────────
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.22, 0.45, 0.65, 0.82, 1.0],
              colors: [
                Color(0xFF12082E), // deep midnight
                Color(0xFF1E1050), // dark indigo
                Color(0xFF30186A), // indigo
                Color(0xFF52228A), // purple
                Color(0xFF8A3A9E), // soft magenta-purple
                Color(0xFFD07898), // warm pink horizon
              ],
            ),
          ),
        ),

        // ── Twinkling background dots ─────────────────────────────
        AnimatedBuilder(
          animation: _twinkleCtrl,
          builder: (_, __) => CustomPaint(
            painter: _TwinklePainter(
              stars: _bgStars,
              animValue: _twinkleCtrl.value,
            ),
          ),
        ),

        // ── Soft cloud wisps at bottom ────────────────────────────
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 130,
          child: _CloudWisps(),
        ),

        // ── Content ───────────────────────────────────────────────
        widget.child,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────

class _BackgroundStar {
  const _BackgroundStar({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
  });

  final double x, y, size, phase;
}

// ─────────────────────────────────────────────
// Background star painter
// ─────────────────────────────────────────────

class _TwinklePainter extends CustomPainter {
  const _TwinklePainter({
    required this.stars,
    required this.animValue,
  });

  final List<_BackgroundStar> stars;
  final double animValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    for (final s in stars) {
      final twinkle =
          0.3 + 0.7 * math.sin((animValue + s.phase) * math.pi);
      paint.color = Colors.white.withValues(alpha: twinkle * 0.80);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size * (0.65 + 0.35 * twinkle),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TwinklePainter old) =>
      old.animValue != animValue;
}

// ─────────────────────────────────────────────
// Cloud wisps
// ─────────────────────────────────────────────

class _CloudWisps extends StatelessWidget {
  const _CloudWisps();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _WispPainter());
  }
}

class _WispPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Left wisp
    _drawWisp(
      canvas,
      size,
      path: Path()
        ..moveTo(0, size.height * 0.55)
        ..cubicTo(
          size.width * 0.18, size.height * 0.10,
          size.width * 0.38, size.height * 0.30,
          size.width * 0.55, size.height * 0.15,
        )
        ..cubicTo(
          size.width * 0.65, size.height * 0.05,
          size.width * 0.72, size.height * 0.22,
          size.width * 0.80, size.height * 0.18,
        )
        ..lineTo(size.width * 0.80, size.height)
        ..lineTo(0, size.height)
        ..close(),
      alpha: 0.10,
    );

    // Right wisp
    _drawWisp(
      canvas,
      size,
      path: Path()
        ..moveTo(size.width * 0.70, size.height * 0.60)
        ..cubicTo(
          size.width * 0.78, size.height * 0.20,
          size.width * 0.88, size.height * 0.35,
          size.width, size.height * 0.25,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(size.width * 0.70, size.height)
        ..close(),
      alpha: 0.08,
    );
  }

  void _drawWisp(Canvas canvas, Size size,
      {required Path path, required double alpha}) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: alpha),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WispPainter _) => false;
}
