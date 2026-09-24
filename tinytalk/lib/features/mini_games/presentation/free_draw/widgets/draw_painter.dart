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

      canvas.drawPath(path, _paintFor(stroke));
    }
  }

  Paint _paintFor(DrawStroke stroke) {
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..style = PaintingStyle.stroke;

    switch (stroke.brushType) {
      case BrushType.pencil:
        paint
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
      case BrushType.marker:
        paint
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter;
      case BrushType.brush:
        paint
          ..color = stroke.color.withValues(alpha: 0.92)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.width * 0.12);
      case BrushType.watercolor:
        paint
          ..color = stroke.color.withValues(alpha: 0.35)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.width * 0.25);
    }
    return paint;
  }

  @override
  bool shouldRepaint(DrawPainter oldDelegate) => oldDelegate.strokes != strokes;
}
