import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_language.dart';
import 'storage_providers.dart';

final appLanguageControllerProvider =
    AsyncNotifierProvider<AppLanguageController, AppLanguage?>(
  AppLanguageController.new,
);

final appCopyProvider = Provider<AppCopy>((ref) {
  final language = ref.watch(appLanguageControllerProvider).valueOrNull ??
      AppLanguage.spanish;
  return AppCopy(language);
});

class AppLanguageController extends AsyncNotifier<AppLanguage?> {
  static const _languageKey = 'app_language';

  @override
  Future<AppLanguage?> build() async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    final code = preferences.getString(_languageKey);

    if (code == null) {
      return null;
    }

    return AppLanguage.fromCode(code);
  }

  Future<void> selectLanguage(AppLanguage language) async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setString(_languageKey, language.code);
    state = AsyncData(language);
  }
}
