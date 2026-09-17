import 'dart:convert';

import 'package:flutter/services.dart';

import '../../app/constants/app_constants.dart';
import '../models/learning_word.dart';
import 'word_repository.dart';

class LocalWordRepository implements WordRepository {
  LocalWordRepository({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  List<LearningWord>? _cache;

  @override
  Future<List<LearningWord>> getWords() async {
    final cachedWords = _cache;
    if (cachedWords != null) {
      return cachedWords;
    }

    final jsonString = await _assetBundle.loadString(
      AppConstants.wordsAssetPath,
    );
    final jsonList = jsonDecode(jsonString) as List<dynamic>;

    final words = jsonList
        .map((item) => LearningWord.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    _cache = words;
    return words;
  }

  @override
  Future<List<LearningWord>> getWordsByCategory(String categoryId) async {
    final words = await getWords();
    return words
        .where((word) => word.category == categoryId)
        .toList(growable: false);
  }

  @override
  Future<LearningWord?> getWordById(String wordId) async {
    final words = await getWords();

    for (final word in words) {
      if (word.id == wordId) {
        return word;
      }
    }

    return null;
  }
}
