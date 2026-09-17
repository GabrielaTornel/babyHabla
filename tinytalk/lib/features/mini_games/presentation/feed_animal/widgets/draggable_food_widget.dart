import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/localization/app_language.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../shared/models/learning_word.dart';
import '../../../../../shared/models/learning_word_extensions.dart';
import '../../../../../shared/providers/app_language_providers.dart';
import '../../../../../shared/providers/service_providers.dart';
import '../../../providers/feed_animal_provider.dart';

class DraggableFoodWidget extends ConsumerWidget {
  const DraggableFoodWidget({super.key, required this.food});

  final LearningWord food;

  Future<void> _playAudio(WidgetRef ref, AppLanguage language) async {
    final played = await ref
        .read(audioServiceProvider)
        .playAsset(food.localizedAudio(language));
    if (!played) {
      await ref.read(ttsServiceProvider).speakWord(
            food.localizedTitle(language),
            languageCode: language.ttsCode,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(feedAnimalProvider).valueOrNull;
    final language =
        ref.watch(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;
    final title = food.localizedTitle(language);

    final isFed = gameState?.fedFoodId == food.id;
    final isDisabled =
        (gameState?.isFeeding ?? false) && !isFed;

    // Correct food shrinks away after being fed
    return AnimatedScale(
      scale: isFed ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInBack,
      child: isDisabled
          ? _FoodCard(food: food, title: title, isDisabled: true)
          : Draggable<String>(
              data: food.id,
              onDragStarted: () {
                _playAudio(ref, language);
                ref.read(feedAnimalProvider.notifier).onDragStarted();
              },
              onDragEnd: (_) =>
                  ref.read(feedAnimalProvider.notifier).onDragEnded(),
              feedback: Material(
                color: Colors.transparent,
                child: Transform.scale(
                  scale: 1.14,
                  child: _FoodCard(
                    food: food,
                    title: title,
                    isDragging: true,
                  ),
                ),
              ),
              childWhenDragging: _FoodCard(
                food: food,
                title: title,
                isPlaceholder: true,
              ),
              child: _FoodCard(food: food, title: title),
            ),
    );
  }
}

// ─────────────────────────────────────────────
// Food card visual
// ─────────────────────────────────────────────

class _FoodCard extends StatelessWidget {
  const _FoodCard({
    required this.food,
    required this.title,
    this.isDragging = false,
    this.isPlaceholder = false,
    this.isDisabled = false,
  });

  final LearningWord food;
  final String title;
  final bool isDragging;
  final bool isPlaceholder;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPlaceholder
          ? 0.20
          : isDisabled
              ? 0.32
              : 1.0,
      child: Container(
        width: 96,
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: (isPlaceholder || isDisabled)
              ? []
              : [
                  BoxShadow(
                    color: isDragging
                        ? const Color(0x55A020F0)
                        : const Color(0x22000000),
                    blurRadius: isDragging ? 28 : 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(path: food.image, size: 68),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2F1B5E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
