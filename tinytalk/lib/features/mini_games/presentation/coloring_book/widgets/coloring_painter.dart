import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../models/free_draw.dart';

/// Paints the child's color strokes on a white sheet, then the black-and-white
/// line art on top using [BlendMode.multiply]: white areas of the line art
/// become transparent (letting the colors show through) while black lines
/// stay black regardless of what's underneath.
class ColoringPainter extends CustomPainter {
  const ColoringPainter({required this.strokes, required this.lineArt});

  final List<DrawStroke> strokes;
  final ui.Image lineArt;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, stroke.toPaint());
    }

    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: lineArt,
      fit: BoxFit.contain,
      blendMode: BlendMode.multiply,
    );
  }

  @override
  bool shouldRepaint(ColoringPainter oldDelegate) =>
      oldDelegate.strokes != strokes || oldDelegate.lineArt != lineArt;
}
