import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/category_data.dart';
import '../../../shared/providers/word_providers.dart';
import '../models/drag_challenge.dart';

const _challengeCount = 10;

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

class DragDropState {
  const DragDropState({
    required this.challenges,
    this.currentIndex = 0,
    this.score = 0,
    this.showSuccess = false,
  });

  final List<DragChallenge> challenges;
  final int currentIndex;
  final int score;
  final bool showSuccess;

  bool get isFinished => currentIndex >= challenges.length;
  DragChallenge? get current =>
      isFinished ? null : challenges[currentIndex];
  int get total => challenges.length;

  DragDropState copyWith({
    int? currentIndex,
    int? score,
    bool? showSuccess,
  }) =>
      DragDropState(
        challenges: challenges,
        currentIndex: currentIndex ?? this.currentIndex,
        score: score ?? this.score,
        showSuccess: showSuccess ?? this.showSuccess,
      );
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class DragDropNotifier extends AsyncNotifier<DragDropState> {
  @override
  Future<DragDropState> build() async {
    final words = await ref.watch(wordsProvider.future);
    if (words.isEmpty) return const DragDropState(challenges: []);

    final rng = math.Random();
    final shuffled = List.of(words)..shuffle(rng);

    final challenges = <DragChallenge>[];
    for (var i = 0; i < _challengeCount && i < shuffled.length; i++) {
      final word = shuffled[i];
      final correctCat = learningCategories.firstWhere(
        (c) => c.id == word.category,
        orElse: () => learningCategories.first,
      );

      final decoys = learningCategories
          .where((c) => c.id != word.category)
          .toList()
        ..shuffle(rng);

      final targets = [correctCat, decoys.first]..shuffle(rng);

      challenges.add(DragChallenge(
        word: word,
        targets: targets,
        correctCategoryId: word.category,
      ));
    }

    return DragDropState(challenges: challenges);
  }

  void onCorrectDrop() {
    final current = state.valueOrNull;
    if (current == null || current.showSuccess) return;
    state = AsyncData(current.copyWith(
      score: current.score + 1,
      showSuccess: true,
    ));
  }

  void nextChallenge() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      currentIndex: current.currentIndex + 1,
      showSuccess: false,
    ));
  }

  void restart() => ref.invalidateSelf();
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final dragDropProvider =
    AsyncNotifierProvider<DragDropNotifier, DragDropState>(
  DragDropNotifier.new,
);
