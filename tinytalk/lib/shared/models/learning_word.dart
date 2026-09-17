import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_word.freezed.dart';
part 'learning_word.g.dart';

@freezed
class LearningWord with _$LearningWord {
  const factory LearningWord({
    required String id,
    required String title,
    String? titleEs,
    required String image,
    required String audio,
    String? audioEs,
    String? audioEn,
    required String category,
    String? animation,
    required int difficultyLevel,
  }) = _LearningWord;

  factory LearningWord.fromJson(Map<String, dynamic> json) =>
      _$LearningWordFromJson(json);
}
