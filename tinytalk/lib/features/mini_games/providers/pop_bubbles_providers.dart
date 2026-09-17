import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/learning_word.dart';
import '../../../shared/providers/word_providers.dart';
import '../models/bubble_data.dart';

const _maxBubbles = 5;
const _gameDuration = 60; // seconds

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

class PopBubblesState {
  const PopBubblesState({
    required this.bubbles,
    required this.wordPool,
    this.totalPopped = 0,
    this.timeRemaining = _gameDuration,
  });

  final List<BubbleData> bubbles;
  final List<LearningWord> wordPool;
  final int totalPopped;
  final int timeRemaining;

  bool get isFinished => timeRemaining <= 0;

  String get timerLabel {
    final m = timeRemaining ~/ 60;
    final s = timeRemaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  PopBubblesState copyWith({
    List<BubbleData>? bubbles,
    int? totalPopped,
    int? timeRemaining,
  }) =>
      PopBubblesState(
        bubbles: bubbles ?? this.bubbles,
        wordPool: wordPool,
        totalPopped: totalPopped ?? this.totalPopped,
        timeRemaining: timeRemaining ?? this.timeRemaining,
      );
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class PopBubblesNotifier extends AsyncNotifier<PopBubblesState> {
  Timer? _timer;

  @override
  Future<PopBubblesState> build() async {
    ref.onDispose(() => _timer?.cancel());

    final words = await ref.watch(wordsProvider.future);
    if (words.isEmpty) {
      return const PopBubblesState(bubbles: [], wordPool: []);
    }

    final pool = List.of(words)..shuffle();
    final rng = math.Random();

    final bubbles = List.generate(_maxBubbles, (i) {
      return BubbleData.random(
        id: 'bubble_$i',
        word: pool[i % pool.length],
        startFraction: rng.nextDouble() * 0.75,
      );
    });

    final initialState = PopBubblesState(bubbles: bubbles, wordPool: pool);
    _startTimer();
    return initialState;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state.valueOrNull;
      if (current == null) return;

      final next = current.timeRemaining - 1;
      if (next <= 0) {
        _timer?.cancel();
        state = AsyncData(current.copyWith(timeRemaining: 0));
      } else {
        state = AsyncData(current.copyWith(timeRemaining: next));
      }
    });
  }

  void onFloatedAway(String bubbleId) => _replace(bubbleId, popped: false);

  void onPopped(String bubbleId) => _replace(bubbleId, popped: true);

  void _replace(String bubbleId, {required bool popped}) {
    final current = state.valueOrNull;
    if (current == null || current.isFinished || current.wordPool.isEmpty) {
      return;
    }

    final rng = math.Random();
    final newWord = current.wordPool[rng.nextInt(current.wordPool.length)];

    final updated = current.bubbles.map((b) {
      if (b.id != bubbleId) return b;
      return b.respawn(newWord: newWord);
    }).toList();

    state = AsyncData(
      current.copyWith(
        bubbles: updated,
        totalPopped: popped ? current.totalPopped + 1 : current.totalPopped,
      ),
    );
  }

  /// Restart the entire game.
  void restart() {
    _timer?.cancel();
    ref.invalidateSelf();
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final popBubblesProvider =
    AsyncNotifierProvider<PopBubblesNotifier, PopBubblesState>(
  PopBubblesNotifier.new,
);
