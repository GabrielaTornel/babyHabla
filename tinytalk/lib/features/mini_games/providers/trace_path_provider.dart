import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/word_providers.dart';
import '../models/trace_path.dart';

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

class TracePathState {
  const TracePathState({
    this.rounds = const [],
    this.currentIndex = 0,
    this.roundsCompleted = 0,
    this.showCelebration = false,
  });

  final List<TracePathRound> rounds;
  final int currentIndex;
  final int roundsCompleted;
  final bool showCelebration;

  TracePathRound? get current =>
      rounds.isEmpty ? null : rounds[currentIndex];

  TracePathState copyWith({
    int? currentIndex,
    int? roundsCompleted,
    bool? showCelebration,
  }) =>
      TracePathState(
        rounds: rounds,
        currentIndex: currentIndex ?? this.currentIndex,
        roundsCompleted: roundsCompleted ?? this.roundsCompleted,
        showCelebration: showCelebration ?? this.showCelebration,
      );
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class TracePathNotifier extends AsyncNotifier<TracePathState> {
  final _rng = math.Random();

  @override
  Future<TracePathState> build() async {
    final allWords = await ref.watch(wordsProvider.future);
    final family = allWords.where((w) => w.category == 'family').toList();
    if (family.length < 2) return const TracePathState();

    final baby = family.firstWhere(
      (w) => w.id == 'family_baby',
      orElse: () => family.first,
    );
    final others = family.where((w) => w.id != baby.id).toList()
      ..shuffle(_rng);

    final shapes = TracePathShape.all;
    final rounds = [
      for (var i = 0; i < others.length; i++)
        TracePathRound(
          start: baby,
          end: others[i],
          shape: shapes[i % shapes.length],
        ),
    ];

    return TracePathState(rounds: rounds);
  }

  /// Called when the child's finger reaches the end of the current path.
  void onPathCompleted() {
    final s = state.valueOrNull;
    if (s == null || s.rounds.isEmpty) return;

    int next;
    do {
      next = _rng.nextInt(s.rounds.length);
    } while (next == s.currentIndex && s.rounds.length > 1);

    state = AsyncData(s.copyWith(
      currentIndex: next,
      roundsCompleted: s.roundsCompleted + 1,
      showCelebration: true,
    ));
  }

  void dismissCelebration() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(showCelebration: false));
  }

  void restart() => ref.invalidateSelf();
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final tracePathProvider =
    AsyncNotifierProvider<TracePathNotifier, TracePathState>(
  TracePathNotifier.new,
);
