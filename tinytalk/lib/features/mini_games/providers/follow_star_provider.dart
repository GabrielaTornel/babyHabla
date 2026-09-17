import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/star_path.dart';

class FollowStarState {
  const FollowStarState({
    this.touchCount = 0,
    this.roundsCompleted = 0,
    this.showCelebration = false,
    this.currentPathIndex = 0,
  });

  final int touchCount;
  final int roundsCompleted;
  final bool showCelebration;
  final int currentPathIndex;

  StarPathData get currentPath => StarPathData.all[currentPathIndex];

  FollowStarState copyWith({
    int? touchCount,
    int? roundsCompleted,
    bool? showCelebration,
    int? currentPathIndex,
  }) =>
      FollowStarState(
        touchCount: touchCount ?? this.touchCount,
        roundsCompleted: roundsCompleted ?? this.roundsCompleted,
        showCelebration: showCelebration ?? this.showCelebration,
        currentPathIndex: currentPathIndex ?? this.currentPathIndex,
      );
}

class FollowStarNotifier extends Notifier<FollowStarState> {
  final _rng = math.Random();

  @override
  FollowStarState build() => const FollowStarState();

  /// Called each time the child successfully touches the star.
  void onTouch() {
    final newCount = state.touchCount + 1;
    // Celebrate every 5 successful touches
    state = state.copyWith(
      touchCount: newCount,
      showCelebration: newCount % 5 == 0,
    );
  }

  /// Called when the star finishes its current path.
  void onPathCompleted() {
    // Pick a different path from the current one
    int next;
    do {
      next = _rng.nextInt(StarPathData.all.length);
    } while (next == state.currentPathIndex &&
        StarPathData.all.length > 1);

    state = state.copyWith(
      roundsCompleted: state.roundsCompleted + 1,
      currentPathIndex: next,
      showCelebration: false,
    );
  }

  void dismissCelebration() =>
      state = state.copyWith(showCelebration: false);

  void restart() => state = const FollowStarState();
}

final followStarProvider =
    NotifierProvider<FollowStarNotifier, FollowStarState>(
  FollowStarNotifier.new,
);
