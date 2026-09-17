import '../models/learning_word.dart';

abstract class WordRepository {
  Future<List<LearningWord>> getWords();

  Future<List<LearningWord>> getWordsByCategory(String categoryId);

  Future<LearningWord?> getWordById(String wordId);
}
