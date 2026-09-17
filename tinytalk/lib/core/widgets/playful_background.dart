import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class PlayfulBackground extends StatelessWidget {
  const PlayfulBackground({
    required this.child,
    this.useForest = false,
    this.backgroundAsset,
    super.key,
  });

  final Widget child;
  final bool useForest;

  /// Override the default orientation-based background with a specific asset.
  final String? backgroundAsset;

  @override
  Widget build(BuildContext context) {
    final String bgImage;
    if (backgroundAsset != null) {
      bgImage = backgroundAsset!;
    } else {
      final isPortrait =
          MediaQuery.orientationOf(context) == Orientation.portrait;
      bgImage = isPortrait
          ? 'assets/images/layouts/backgroundYellowVertical.png'
          : 'assets/images/layouts/backgroundYellow.png';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bgImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          const Positioned(top: 44, left: 26, child: _Cloud(width: 88)),
          const Positioned(top: 86, right: 34, child: _Cloud(width: 68)),
          const Positioned(top: 150, left: 8, child: _Star(size: 18)),
          const Positioned(top: 108, right: 86, child: _Star(size: 15)),
          if (useForest) ...const [
            Positioned(top: -8, left: -24, child: _Tree(size: 118)),
            Positioned(top: -18, right: -10, child: _Tree(size: 136)),
          ],
          child,
        ],
      ),
    );
  }
}

class BabyBear extends StatelessWidget {
  const BabyBear({this.size = 220, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BabyBearPainter(),
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.42),
      painter: _CloudPainter(),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star_rounded, color: AppColors.yellowPastel, size: size);
  }
}

class _Tree extends StatelessWidget {
  const _Tree({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _TreePainter());
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(size.width * 0.24, size.height * 0.62),
        size.height * 0.36, paint);
    canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.44),
        size.height * 0.48, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.62),
        size.height * 0.32, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.54, size.width * 0.78,
            size.height * 0.36),
        Radius.circular(size.height),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunk = Paint()..color = const Color(0xFF9A6B32);
    final leaf = Paint()..color = const Color(0xFF59C934);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.44, size.height * 0.48, size.width * 0.16,
            size.height * 0.48),
        const Radius.circular(12),
      ),
      trunk,
    );
    for (final center in [
      Offset(size.width * 0.3, size.height * 0.28),
      Offset(size.width * 0.52, size.height * 0.2),
      Offset(size.width * 0.72, size.height * 0.33),
      Offset(size.width * 0.46, size.height * 0.42),
    ]) {
      canvas.drawCircle(center, size.width * 0.22, leaf);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BabyBearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink = Paint()..color = AppColors.roseSoft;
    final deepPink = Paint()..color = AppColors.roseMauve;
    final cream = Paint()..color = AppColors.cream;
    final ink = Paint()..color = AppColors.darkPurple;
    final white = Paint()..color = Colors.white;

    final center = Offset(size.width / 2, size.height * 0.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.62),
        width: size.width * 0.62,
        height: size.height * 0.7,
      ),
      pink,
    );
    canvas.drawCircle(
        Offset(size.width * 0.26, size.height * 0.25), size.width * 0.16, pink);
    canvas.drawCircle(
        Offset(size.width * 0.74, size.height * 0.25), size.width * 0.16, pink);
    canvas.drawCircle(center, size.width * 0.35, pink);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.58),
        width: size.width * 0.36,
        height: size.height * 0.28,
      ),
      cream,
    );
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.45),
        size.width * 0.055, white);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.45),
        size.width * 0.055, white);
    canvas.drawCircle(
        Offset(size.width * 0.38, size.height * 0.45), size.width * 0.03, ink);
    canvas.drawCircle(
        Offset(size.width * 0.62, size.height * 0.45), size.width * 0.03, ink);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.54),
        width: size.width * 0.14,
        height: size.height * 0.09,
      ),
      deepPink,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.57),
        width: size.width * 0.2,
        height: size.height * 0.16,
      ),
      0,
      3.14,
      false,
      Paint()
        ..color = AppColors.darkPurple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
