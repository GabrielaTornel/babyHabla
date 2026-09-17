import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/playful_background.dart';
import '../../../shared/models/learning_word_extensions.dart';
import '../../../shared/providers/app_language_providers.dart';
import '../../../shared/providers/progress_providers.dart';
import '../../../shared/providers/service_providers.dart';
import '../../../shared/providers/word_providers.dart';

class WordDetailScreen extends ConsumerWidget {
  const WordDetailScreen({
    required this.wordId,
    super.key,
  });

  final String wordId;

  static String? _bgForCategory(String? category) {
    return switch (category) {
      'animals' => 'assets/images/layouts/backgroundAnimals.png',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordState = ref.watch(wordByIdProvider(wordId));
    final language = ref.watch(appLanguageControllerProvider).valueOrNull;
    final copy = ref.watch(appCopyProvider);

    final bgAsset = _bgForCategory(wordState.valueOrNull?.category);

    return Scaffold(
      body: PlayfulBackground(
        backgroundAsset: bgAsset,
        child: SafeArea(
          child: wordState.when(
            data: (word) {
              if (word == null) {
                return Center(child: Text(copy.wordNotFound));
              }

              final selectedLanguage = language!;
              final title = word.localizedTitle(selectedLanguage);

              Future<void> playAudio() async {
                final didPlayAudio =
                    await ref.read(audioServiceProvider).playAsset(
                          word.localizedAudio(selectedLanguage),
                        );

                if (!didPlayAudio) {
                  await ref.read(ttsServiceProvider).speakWord(
                        title,
                        languageCode: selectedLanguage.ttsCode,
                      );
                }

                await ref
                    .read(progressControllerProvider.notifier)
                    .markCompleted(word.id);
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.85),
                            foregroundColor: const Color(0xFF3642C7),
                          ),
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: playAudio,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: word.animation == null
                              ? AppImage(path: word.image, size: 260)
                              : Lottie.asset(
                                  word.animation!,
                                  width: 260,
                                  height: 260,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return AppImage(path: word.image, size: 260);
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                  _WordTitleBanner(title: title),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: Icons.volume_up_rounded,
                          label: copy.play,
                          color: const Color(0xFF4CAF50),
                          onPressed: playAudio,
                        ),
                        _ActionButton(
                          icon: Icons.mic_rounded,
                          label: copy.record,
                          color: const Color(0xFFFF7043),
                          onPressed: () {},
                        ),
                        _ActionButton(
                          icon: Icons.play_circle_rounded,
                          label: copy.playback,
                          color: const Color(0xFF42A5F5),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(copy.couldNotLoadWord(error)),
            ),
          ),
        ),
      ),
    );
  }
}

class _WordTitleBanner extends StatelessWidget {
  const _WordTitleBanner({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                shadows: [
                  const Shadow(
                    color: Color(0x55000000),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
      child: Ink(
        width: 90,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
