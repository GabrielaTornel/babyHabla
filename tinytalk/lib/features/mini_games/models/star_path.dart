import 'dart:ui';

class StarPathData {
  const StarPathData({
    required this.waypoints,
    required this.durationMs,
  });

  // Normalized (0–1) waypoints; star visits each in sequence.
  final List<Offset> waypoints;
  final int durationMs;

  /// Smooth-step interpolation along waypoints at progress [t] ∈ [0, 1].
  Offset positionAt(double t) {
    if (waypoints.length < 2) return waypoints.first;
    final segCount = waypoints.length - 1;
    final raw = (t * segCount).clamp(0.0, segCount.toDouble());
    final idx = raw.floor().clamp(0, segCount - 1);
    final localT = raw - idx;
    // Hermite smooth-step for organic feel
    final s = localT * localT * (3 - 2 * localT);
    return Offset.lerp(waypoints[idx], waypoints[idx + 1], s)!;
  }

  static const List<StarPathData> all = [
    // Gentle arc left → right
    StarPathData(
      durationMs: 6500,
      waypoints: [
        Offset(0.12, 0.62), Offset(0.32, 0.28), Offset(0.50, 0.48),
        Offset(0.68, 0.28), Offset(0.88, 0.62),
      ],
    ),
    // Bouncy zigzag
    StarPathData(
      durationMs: 7000,
      waypoints: [
        Offset(0.15, 0.70), Offset(0.38, 0.22), Offset(0.60, 0.72),
        Offset(0.82, 0.22), Offset(0.50, 0.50),
      ],
    ),
    // Diagonal sweep
    StarPathData(
      durationMs: 6000,
      waypoints: [
        Offset(0.08, 0.22), Offset(0.30, 0.42), Offset(0.55, 0.30),
        Offset(0.78, 0.55), Offset(0.92, 0.78),
      ],
    ),
    // Circular loop (approx)
    StarPathData(
      durationMs: 9000,
      waypoints: [
        Offset(0.50, 0.18), Offset(0.82, 0.38), Offset(0.72, 0.72),
        Offset(0.28, 0.72), Offset(0.18, 0.38), Offset(0.50, 0.18),
      ],
    ),
    // S-curve right → left
    StarPathData(
      durationMs: 7500,
      waypoints: [
        Offset(0.88, 0.25), Offset(0.62, 0.18), Offset(0.42, 0.42),
        Offset(0.22, 0.62), Offset(0.42, 0.80), Offset(0.72, 0.68),
      ],
    ),
    // Slow center drift (calming)
    StarPathData(
      durationMs: 8500,
      waypoints: [
        Offset(0.30, 0.35), Offset(0.55, 0.28), Offset(0.72, 0.50),
        Offset(0.55, 0.70), Offset(0.30, 0.62), Offset(0.42, 0.40),
      ],
    ),
  ];
}
