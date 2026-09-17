import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/learning_word.dart';
import '../../../shared/providers/word_providers.dart';
import '../models/color_challenge.dart';

const _questionsPerGame = 8;
const _optionsCount = 4;

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

class TouchColorState {
  const TouchColorState({
    required this.challenges,
    this.currentIndex = 0,
    this.score = 0,
    this.selectedWordId,
    this.showCelebration = false,
  });

  final List<ColorChallenge> challenges;
  final int currentIndex;
  final int score;
  final String? selectedWordId;
  final bool showCelebration;

  bool get isFinished => currentIndex >= challenges.length;
  ColorChallenge? get current =>
      isFinished ? null : challenges[currentIndex];
  int get total => challenges.length;
  bool get hasSelection => selectedWordId != null;
  bool get isCorrect =>
      selectedWordId == current?.correctWord.id;

  TouchColorState copyWith({
    int? currentIndex,
    int? score,
    String? selectedWordId,
    bool? showCelebration,
    bool clearSelection = false,
  }) =>
      TouchColorState(
        challenges: challenges,
        currentIndex: currentIndex ?? this.currentIndex,
        score: score ?? this.score,
        selectedWordId: clearSelection
            ? null
            : (selectedWordId ?? this.selectedWordId),
        showCelebration: showCelebration ?? this.showCelebration,
      );
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class TouchColorNotifier extends AsyncNotifier<TouchColorState> {
  @override
  Future<TouchColorState> build() async {
    final allWords = await ref.watch(wordsProvider.future);
    final colors =
        allWords.where((w) => w.category == 'colors').toList();

    if (colors.length < 2) {
      return const TouchColorState(challenges: []);
    }

    final effectiveOptions = math.min(_optionsCount, colors.length);
    final rng = math.Random();
    final shuffled = List.of(colors)..shuffle(rng);

    // Cycle through the available colors until we have _questionsPerGame entries,
    // so the game always runs the full 8 rounds even with only 3 colors.
    final List<LearningWord> picked = [];
    final cycle = List.of(shuffled);
    while (picked.length < _questionsPerGame) {
      cycle.shuffle(rng);
      picked.addAll(cycle);
    }
    picked.length = _questionsPerGame;

    final challenges = picked.map((correct) {
      final decoys = List.of(colors)
        ..removeWhere((w) => w.id == correct.id)
        ..shuffle(rng);
      final options = [correct, ...decoys.take(effectiveOptions - 1)]
        ..shuffle(rng);
      return ColorChallenge(correctWord: correct, options: options);
    }).toList();

    return TouchColorState(challenges: challenges);
  }

  void onSelect(String wordId) {
    final s = state.valueOrNull;
    if (s == null || s.hasSelection) return;

    final isCorrect = wordId == s.current?.correctWord.id;
    state = AsyncData(s.copyWith(
      selectedWordId: wordId,
      score: isCorrect ? s.score + 1 : s.score,
      showCelebration: isCorrect,
    ));
  }

  void nextQuestion() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(
      currentIndex: s.currentIndex + 1,
      showCelebration: false,
      clearSelection: true,
    ));
  }

  void restart() => ref.invalidateSelf();
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final touchColorProvider =
    AsyncNotifierProvider<TouchColorNotifier, TouchColorState>(
  TouchColorNotifier.new,
);
