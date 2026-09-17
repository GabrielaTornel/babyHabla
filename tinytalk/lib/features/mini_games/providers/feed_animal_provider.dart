import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/word_providers.dart';
import '../models/feed_challenge.dart';

const _challengeCount = 8;
const _foodOptionsCount = 3;

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

class FeedAnimalState {
  const FeedAnimalState({
    required this.challenges,
    this.currentIndex = 0,
    this.score = 0,
    this.isFeeding = false,
    this.showCelebration = false,
    this.isDraggingFood = false,
    this.fedFoodId,
  });

  final List<FeedChallenge> challenges;
  final int currentIndex;
  final int score;

  /// True while the eating animation is playing.
  final bool isFeeding;

  /// True immediately after a correct feed (triggers overlay).
  final bool showCelebration;

  /// True while any food item is being dragged (drives target glow).
  final bool isDraggingFood;

  /// ID of the food just successfully fed (drives disappear animation).
  final String? fedFoodId;

  bool get isFinished => currentIndex >= challenges.length;
  FeedChallenge? get current =>
      isFinished ? null : challenges[currentIndex];
  int get total => challenges.length;

  FeedAnimalState copyWith({
    int? currentIndex,
    int? score,
    bool? isFeeding,
    bool? showCelebration,
    bool? isDraggingFood,
    String? fedFoodId,
    bool clearFeedState = false,
  }) {
    if (clearFeedState) {
      return FeedAnimalState(
        challenges: challenges,
        currentIndex: currentIndex ?? this.currentIndex,
        score: score ?? this.score,
      );
    }
    return FeedAnimalState(
      challenges: challenges,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      isFeeding: isFeeding ?? this.isFeeding,
      showCelebration: showCelebration ?? this.showCelebration,
      isDraggingFood: isDraggingFood ?? this.isDraggingFood,
      fedFoodId: fedFoodId ?? this.fedFoodId,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class FeedAnimalNotifier extends AsyncNotifier<FeedAnimalState> {
  @override
  Future<FeedAnimalState> build() async {
    final allWords = await ref.watch(wordsProvider.future);
    final animals =
        allWords.where((w) => w.category == 'animals').toList();
    final foods =
        allWords.where((w) => w.category == 'food').toList();

    if (animals.isEmpty || foods.isEmpty) {
      return const FeedAnimalState(challenges: []);
    }

    // Use however many food options are available, up to the configured max.
    final effectiveOptions = math.min(_foodOptionsCount, foods.length);

    final rng = math.Random();
    final shuffledAnimals = List.of(animals)..shuffle(rng);
    final picked = shuffledAnimals
        .take(math.min(_challengeCount, animals.length))
        .toList();

    final challenges = picked.map((animal) {
      final shuffledFoods = List.of(foods)..shuffle(rng);
      final correctFood = shuffledFoods.first;
      final decoys = shuffledFoods
          .skip(1)
          .take(effectiveOptions - 1)
          .toList();
      final options = [correctFood, ...decoys]..shuffle(rng);
      return FeedChallenge(
        animal: animal,
        correctFood: correctFood,
        foodOptions: options,
      );
    }).toList();

    return FeedAnimalState(challenges: challenges);
  }

  void onDragStarted() {
    final s = state.valueOrNull;
    if (s == null || s.isFeeding) return;
    state = AsyncData(s.copyWith(isDraggingFood: true));
  }

  void onDragEnded() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isDraggingFood: false));
  }

  void onCorrectFeed(String foodId) {
    final s = state.valueOrNull;
    if (s == null || s.isFeeding) return;
    state = AsyncData(s.copyWith(
      score: s.score + 1,
      isFeeding: true,
      showCelebration: true,
      isDraggingFood: false,
      fedFoodId: foodId,
    ));
  }

  void nextChallenge() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(
      currentIndex: s.currentIndex + 1,
      clearFeedState: true,
    ));
  }

  void restart() => ref.invalidateSelf();
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final feedAnimalProvider =
    AsyncNotifierProvider<FeedAnimalNotifier, FeedAnimalState>(
  FeedAnimalNotifier.new,
);
