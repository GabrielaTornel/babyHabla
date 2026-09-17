import '../../../shared/models/learning_word.dart';

class ColorChallenge {
  const ColorChallenge({
    required this.correctWord,
    required this.options,
  });

  final LearningWord correctWord;

  // Always contains correctWord; order is shuffled.
  final List<LearningWord> options;
}
