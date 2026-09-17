import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/models/learning_word.dart';

// Soft translucent pastel bubble colors
const _bubbleColors = [
  Color(0xBBFFB3C6), // rose
  Color(0xBBC8B6FF), // lavender
  Color(0xBBAFD6FF), // sky blue
  Color(0xBBB9F0D1), // mint
  Color(0xBBFFE08A), // yellow
  Color(0xBBFFCBA4), // peach
  Color(0xBBA8F0C0), // green
];

class BubbleData {
  const BubbleData({
    required this.id,
    required this.word,
    required this.color,
    required this.size,
    required this.xFraction,
    required this.speedFactor,
    required this.startFraction,
  });

  /// Stable slot identifier ("bubble_0" … "bubble_4"). Never changes.
  final String id;
  final LearningWord word;
  final Color color;

  /// Visual diameter in logical pixels (90 – 145).
  final double size;

  /// Horizontal start position as fraction of screen width (0.05 – 0.85).
  final double xFraction;

  /// Speed multiplier – higher = faster float (0.6 – 1.4).
  final double speedFactor;

  /// Animation start fraction (0.0 = bottom, 1.0 = top).
  /// Used so bubbles begin staggered on game start; resets to 0 on respawn.
  final double startFraction;

  factory BubbleData.random({
    required String id,
    required LearningWord word,
    double startFraction = 0.0,
  }) {
    final rng = math.Random();
    return BubbleData(
      id: id,
      word: word,
      color: _bubbleColors[rng.nextInt(_bubbleColors.length)],
      size: 90 + rng.nextDouble() * 55,
      xFraction: 0.05 + rng.nextDouble() * 0.80,
      speedFactor: 0.6 + rng.nextDouble() * 0.8,
      startFraction: startFraction,
    );
  }

  BubbleData respawn({required LearningWord newWord}) {
    final rng = math.Random();
    return BubbleData(
      id: id,
      word: newWord,
      color: _bubbleColors[rng.nextInt(_bubbleColors.length)],
      size: 90 + rng.nextDouble() * 55,
      xFraction: 0.05 + rng.nextDouble() * 0.80,
      speedFactor: 0.6 + rng.nextDouble() * 0.8,
      startFraction: 0.0,
    );
  }
}
