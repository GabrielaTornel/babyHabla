import '../../../app/constants/category_data.dart';
import '../../../shared/models/learning_word.dart';

class DragChallenge {
  const DragChallenge({
    required this.word,
    required this.targets,
    required this.correctCategoryId,
  });

  final LearningWord word;
  final List<LearningCategoryData> targets;
  final String correctCategoryId;
}
