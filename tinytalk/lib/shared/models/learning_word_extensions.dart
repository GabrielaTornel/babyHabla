import '../../app/localization/app_language.dart';
import 'learning_word.dart';

extension LearningWordLocalization on LearningWord {
  String localizedTitle(AppLanguage language) {
    return switch (language) {
      AppLanguage.spanish => titleEs ?? title,
      AppLanguage.english => title,
    };
  }

  String localizedAudio(AppLanguage language) {
    return switch (language) {
      AppLanguage.spanish => audioEs ?? audio,
      AppLanguage.english => audioEn ?? audio,
    };
  }
}
