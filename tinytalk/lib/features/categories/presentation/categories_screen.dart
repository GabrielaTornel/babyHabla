import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/category_data.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/widgets/playful_background.dart';
import '../../../shared/providers/app_language_providers.dart';
import '../../../shared/providers/progress_providers.dart';
import '../../../shared/providers/service_providers.dart';
import '../../../shared/providers/word_providers.dart';
import '../../words/widgets/word_card.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({
    required this.categoryId,
    super.key,
  });

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = learningCategories.firstWhere(
      (item) => item.id == categoryId,
      orElse: () => learningCategories.first,
    );
    final words = ref.watch(wordsByCategoryProvider(categoryId));
    final progress = ref.watch(progressControllerProvider).valueOrNull ?? {};
    final copy = ref.watch(appCopyProvider);
    final language = ref.watch(appLanguageControllerProvider).valueOrNull;

    final bgAsset = categoryId == 'animals'
        ? 'assets/images/layouts/backgroundAnimals.png'
        : null;

    return Scaffold(
      body: PlayfulBackground(
        useForest: bgAsset == null,
        backgroundAsset: bgAsset,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WoodTitle(title: copy.categoryTitle(category.id)),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: () {
                        ref.read(ttsServiceProvider).speakWord(
                              copy.categoryTitle(category.id),
                              languageCode: language?.ttsCode ?? 'es-US',
                            );
                      },
                      icon: const Icon(Icons.volume_up_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: words.when(
                  data: (items) => GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 190,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final word = items[index];

                      return WordCard(
                        word: word,
                        language: language,
                        isCompleted: progress.contains(word.id),
                        onTap: () => context.push(AppRoutes.wordPath(word.id)),
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(copy.couldNotLoadWords(error)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WoodTitle extends StatelessWidget {
  const _WoodTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFD8913E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFC36F), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF743F00),
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}
