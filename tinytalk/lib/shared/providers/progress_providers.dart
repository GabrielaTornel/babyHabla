import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/progress_repository.dart';
import 'storage_providers.dart';

final progressRepositoryProvider =
    FutureProvider<ProgressRepository>((ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return ProgressRepository(preferences);
});

final progressControllerProvider =
    AsyncNotifierProvider<ProgressController, Set<String>>(
  ProgressController.new,
);

class ProgressController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final repository = await ref.watch(progressRepositoryProvider.future);
    return repository.getCompletedWordIds();
  }

  Future<void> markCompleted(String wordId) async {
    final repository = await ref.read(progressRepositoryProvider.future);
    final current = state.valueOrNull ?? {};
    final updated = {...current, wordId};

    state = AsyncData(updated);
    await repository.saveCompletedWordIds(updated);
  }

  Future<void> reset() async {
    final repository = await ref.read(progressRepositoryProvider.future);
    state = const AsyncData({});
    await repository.saveCompletedWordIds({});
  }
}
