import 'package:flutter/material.dart';

import '../../../models/free_draw.dart';

/// Paints every finger stroke, styled per its [BrushType].
class DrawPainter extends CustomPainter {
  const DrawPainter({required this.strokes});

  final List<DrawStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;

      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, stroke.toPaint());
    }
  }

  @override
  bool shouldRepaint(DrawPainter oldDelegate) => oldDelegate.strokes != strokes;
}
