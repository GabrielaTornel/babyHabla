import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/word_providers.dart';
import '../models/animal_question.dart';

const _questionsPerGame = 8;
const _optionsCount = 3;

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

class AnimalFinderState {
  const AnimalFinderState({
    required this.questions,
    this.currentIndex = 0,
    this.score = 0,
    this.selectedWordId,
    this.showCelebration = false,
  });

  final List<AnimalQuestion> questions;
  final int currentIndex;
  final int score;
  final String? selectedWordId;
  final bool showCelebration;

  bool get isFinished => currentIndex >= questions.length;
  AnimalQuestion? get current =>
      isFinished ? null : questions[currentIndex];
  int get total => questions.length;
  bool get hasSelection => selectedWordId != null;

  AnimalFinderState copyWith({
    int? currentIndex,
    int? score,
    String? selectedWordId,
    bool? showCelebration,
    bool clearSelection = false,
  }) =>
      AnimalFinderState(
        questions: questions,
        currentIndex: currentIndex ?? this.currentIndex,
        score: score ?? this.score,
        selectedWordId:
            clearSelection ? null : (selectedWordId ?? this.selectedWordId),
        showCelebration: showCelebration ?? this.showCelebration,
      );
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class AnimalFinderNotifier extends AsyncNotifier<AnimalFinderState> {
  @override
  Future<AnimalFinderState> build() async {
    final allWords = await ref.watch(wordsProvider.future);
    final animals =
        allWords.where((w) => w.category == 'animals').toList();

    if (animals.length < _optionsCount) {
      return const AnimalFinderState(questions: []);
    }

    final rng = math.Random();
    final shuffled = List.of(animals)..shuffle(rng);
    final picked =
        shuffled.take(math.min(_questionsPerGame, animals.length)).toList();

    final questions = picked.map((correct) {
      final decoys = List.of(animals)
        ..removeWhere((w) => w.id == correct.id)
        ..shuffle(rng);
      final options = [correct, ...decoys.take(_optionsCount - 1)]
        ..shuffle(rng);
      return AnimalQuestion(correctWord: correct, options: options);
    }).toList();

    return AnimalFinderState(questions: questions);
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

final animalFinderProvider =
    AsyncNotifierProvider<AnimalFinderNotifier, AnimalFinderState>(
  AnimalFinderNotifier.new,
);
