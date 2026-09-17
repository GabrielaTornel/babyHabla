import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/localization/app_language.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../shared/models/learning_word.dart';
import '../../../../../shared/models/learning_word_extensions.dart';
import '../../../../../shared/providers/app_language_providers.dart';
import '../../../../../shared/providers/service_providers.dart';

class DraggableItemWidget extends ConsumerWidget {
  const DraggableItemWidget({required this.word, super.key});

  final LearningWord word;

  Future<void> _playAudio(WidgetRef ref, AppLanguage language) async {
    final played = await ref
        .read(audioServiceProvider)
        .playAsset(word.localizedAudio(language));
    if (!played) {
      await ref
          .read(ttsServiceProvider)
          .speakWord(word.localizedTitle(language), languageCode: language.ttsCode);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language =
        ref.watch(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;
    final title = word.localizedTitle(language);

    return Draggable<String>(
      data: word.category,
      onDragStarted: () => _playAudio(ref, language),
      feedback: Material(
        color: Colors.transparent,
        child: _WordCard(word: word, title: title, scale: 1.06),
      ),
      childWhenDragging: _WordCard(word: word, title: title, isDragging: true),
      child: _WordCard(word: word, title: title),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.word,
    required this.title,
    this.isDragging = false,
    this.scale = 1.0,
  });

  final LearningWord word;
  final String title;
  final bool isDragging;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: isDragging ? 0.3 : 1.0,
        child: Container(
          width: 170,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isDragging
                ? []
                : const [
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppImage(path: word.image, size: 110),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2F1B5E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
