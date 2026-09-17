import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_providers.dart';

final welcomeControllerProvider =
    AsyncNotifierProvider<WelcomeController, bool>(
  WelcomeController.new,
);

class WelcomeController extends AsyncNotifier<bool> {
  static const _welcomeSeenKey = 'welcome_seen';

  @override
  Future<bool> build() async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    return preferences.getBool(_welcomeSeenKey) ?? false;
  }

  Future<void> completeWelcome() async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setBool(_welcomeSeenKey, true);
    state = const AsyncData(true);
  }
}

final kokoIntroControllerProvider =
    AsyncNotifierProvider<KokoIntroController, bool>(
  KokoIntroController.new,
);

class KokoIntroController extends AsyncNotifier<bool> {
  static const _introSeenKey = 'koko_intro_seen';

  @override
  Future<bool> build() async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    return preferences.getBool(_introSeenKey) ?? false;
  }

  Future<void> completeIntro() async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setBool(_introSeenKey, true);
    state = const AsyncData(true);
  }
}
