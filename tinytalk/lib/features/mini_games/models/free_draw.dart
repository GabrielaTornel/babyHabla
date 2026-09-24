import 'dart:ui';

/// The rendering style applied to a stroke.
enum BrushType { pencil, brush, watercolor, marker }

/// Fixed stroke-thickness presets a child can pick between.
enum BrushSize { small, medium, large }

extension BrushWidth on BrushType {
  /// Base stroke width for this brush at the given size preset.
  double widthFor(BrushSize size) {
    final scale = switch (this) {
      BrushType.pencil => const (small: 3.0, medium: 6.0, large: 10.0),
      BrushType.marker => const (small: 8.0, medium: 14.0, large: 22.0),
      BrushType.brush => const (small: 8.0, medium: 16.0, large: 26.0),
      BrushType.watercolor => const (small: 12.0, medium: 22.0, large: 34.0),
    };
    return switch (size) {
      BrushSize.small => scale.small,
      BrushSize.medium => scale.medium,
      BrushSize.large => scale.large,
    };
  }
}

/// One continuous finger stroke: its color, brush style and ordered points.
class DrawStroke {
  const DrawStroke({
    required this.color,
    required this.points,
    required this.brushType,
    required this.width,
  });

  final Color color;
  final List<Offset> points;
  final BrushType brushType;
  final double width;

  DrawStroke withPoint(Offset point) => DrawStroke(
        color: color,
        points: [...points, point],
        brushType: brushType,
        width: width,
      );
}

/// Fixed color palette for the free-draw canvas, matching the
/// touch-color mini-game's color set for visual consistency.
class FreeDrawPalette {
  FreeDrawPalette._();

  static const colors = <Color>[
    Color(0xFFE53935), // red
    Color(0xFF1E88E5), // blue
    Color(0xFFFDD835), // yellow
    Color(0xFF43A047), // green
    Color(0xFFFB8C00), // orange
    Color(0xFF8E24AA), // purple
    Color(0xFFE91E63), // pink
    Color(0xFF424242), // black
  ];
}
