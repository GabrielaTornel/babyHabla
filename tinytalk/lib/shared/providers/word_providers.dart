import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/learning_word.dart';
import '../repositories/local_word_repository.dart';
import '../repositories/word_repository.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return LocalWordRepository();
});

final wordsProvider = FutureProvider<List<LearningWord>>((ref) {
  return ref.watch(wordRepositoryProvider).getWords();
});

final wordsByCategoryProvider =
    FutureProvider.family<List<LearningWord>, String>((ref, categoryId) {
  return ref.watch(wordRepositoryProvider).getWordsByCategory(categoryId);
});

final wordByIdProvider =
    FutureProvider.family<LearningWord?, String>((ref, wordId) {
  return ref.watch(wordRepositoryProvider).getWordById(wordId);
});
