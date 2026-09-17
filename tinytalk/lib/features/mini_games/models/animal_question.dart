import '../../../shared/models/learning_word.dart';

class AnimalQuestion {
  const AnimalQuestion({
    required this.correctWord,
    required this.options,
  });

  final LearningWord correctWord;

  // Always contains correctWord; shuffled order.
  final List<LearningWord> options;
}
