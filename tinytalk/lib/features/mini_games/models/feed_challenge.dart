import '../../../shared/models/learning_word.dart';

class FeedChallenge {
  const FeedChallenge({
    required this.animal,
    required this.correctFood,
    required this.foodOptions,
  });

  final LearningWord animal;
  final LearningWord correctFood;

  // Includes correctFood; order is shuffled.
  final List<LearningWord> foodOptions;
}
