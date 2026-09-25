import 'package:flutter/material.dart';

import '../../../models/trace_path.dart';

/// Draws the dotted guide path and the golden progress fill on top of it.
class PathPainter extends CustomPainter {
  const PathPainter({
    required this.shape,
    required this.progress,
    required this.screenSize,
  });

  final TracePathShape shape;
  final double progress;
  final Size screenSize;

  static const int _dotCount = 40;
  static const double _dotRadius = 5.0;
  static const double _fillRadius = 9.0;

  Offset _toScreen(Offset normalized) => Offset(
        normalized.dx * screenSize.width,
        normalized.dy * screenSize.height,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final guideOutline = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final guidePaint = Paint()..color = const Color(0xFF3642C7);
    final fillOutline = Paint()..color = Colors.white;
    final fillPaint = Paint()..color = const Color(0xFFFFD700);
    final headPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (var i = 0; i <= _dotCount; i++) {
      final t = i / _dotCount;
      final pos = _toScreen(shape.positionAt(t));
      canvas.drawCircle(pos, _dotRadius + 1.5, guideOutline);
      canvas.drawCircle(pos, _dotRadius, guidePaint);
      if (t <= progress) {
        final isHead = t + 1 / _dotCount > progress;
        canvas.drawCircle(pos, _fillRadius + 2, fillOutline);
        canvas.drawCircle(pos, _fillRadius, isHead ? headPaint : fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.shape != shape ||
      oldDelegate.screenSize != screenSize;
}
