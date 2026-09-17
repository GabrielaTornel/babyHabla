import 'package:shared_preferences/shared_preferences.dart';

class ProgressRepository {
  ProgressRepository(this._preferences);

  static const _completedWordIdsKey = 'completed_word_ids';

  final SharedPreferences _preferences;

  Set<String> getCompletedWordIds() {
    return _preferences.getStringList(_completedWordIdsKey)?.toSet() ?? {};
  }

  Future<void> saveCompletedWordIds(Set<String> ids) {
    return _preferences.setStringList(_completedWordIdsKey, ids.toList());
  }
}
