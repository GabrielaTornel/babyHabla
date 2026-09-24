import 'dart:ui';

import '../../../shared/models/learning_word.dart';

/// A normalized (0-1) curved path shape the child traces with a finger.
class TracePathShape {
  const TracePathShape({required this.waypoints});

  final List<Offset> waypoints;

  Offset get start => waypoints.first;
  Offset get end => waypoints.last;

  /// Smooth-step interpolation along waypoints at progress [t] ∈ [0, 1].
  Offset positionAt(double t) {
    if (waypoints.length < 2) return waypoints.first;
    final segCount = waypoints.length - 1;
    final raw = (t * segCount).clamp(0.0, segCount.toDouble());
    final idx = raw.floor().clamp(0, segCount - 1);
    final localT = raw - idx;
    final s = localT * localT * (3 - 2 * localT);
    return Offset.lerp(waypoints[idx], waypoints[idx + 1], s)!;
  }

  static const List<TracePathShape> all = [
    // Gentle arc bottom-left → top-right
    TracePathShape(waypoints: [
      Offset(0.14, 0.72), Offset(0.34, 0.50), Offset(0.58, 0.42),
      Offset(0.82, 0.24),
    ]),
    // Bouncy zigzag left → right
    TracePathShape(waypoints: [
      Offset(0.14, 0.30), Offset(0.38, 0.68), Offset(0.60, 0.28),
      Offset(0.82, 0.62),
    ]),
    // Diagonal sweep top-left → bottom-right
    TracePathShape(waypoints: [
      Offset(0.16, 0.22), Offset(0.40, 0.38), Offset(0.60, 0.55),
      Offset(0.82, 0.74),
    ]),
    // S-curve bottom → top
    TracePathShape(waypoints: [
      Offset(0.20, 0.76), Offset(0.62, 0.66), Offset(0.30, 0.40),
      Offset(0.78, 0.24),
    ]),
  ];
}

/// Pairs the two words the child connects, plus the curve between them.
class TracePathRound {
  const TracePathRound({
    required this.start,
    required this.end,
    required this.shape,
  });

  final LearningWord start;
  final LearningWord end;
  final TracePathShape shape;
}
