import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/localization/app_language.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../shared/models/learning_word.dart';
import '../../../../../shared/models/learning_word_extensions.dart';
import '../../../../../shared/providers/app_language_providers.dart';
import '../../../../../shared/providers/service_providers.dart';
import '../../../providers/animal_finder_provider.dart';

class AnimalCardWidget extends ConsumerStatefulWidget {
  const AnimalCardWidget({super.key, required this.word});

  final LearningWord word;

  @override
  ConsumerState<AnimalCardWidget> createState() => _AnimalCardWidgetState();
}

class _AnimalCardWidgetState extends ConsumerState<AnimalCardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 0.93), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.93, end: 1.06), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.00), weight: 25),
    ]).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 20),
    ]).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final s = ref.read(animalFinderProvider).valueOrNull;
    if (s == null || s.hasSelection) return;

    final isCorrect = widget.word.id == s.current?.correctWord.id;

    // Immediate state update for instant visual feedback
    ref.read(animalFinderProvider.notifier).onSelect(widget.word.id);

    if (isCorrect) {
      _bounceCtrl.forward(from: 0);
    } else {
      _shakeCtrl.forward(from: 0);
    }

    // Play audio; fall back to TTS if no asset found
    final language =
        ref.read(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;

    final played = await ref
        .read(audioServiceProvider)
        .playAsset(widget.word.localizedAudio(language));

    if (!played && mounted) {
      await ref.read(ttsServiceProvider).speakWord(
            widget.word.localizedTitle(language),
            languageCode: language.ttsCode,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(animalFinderProvider).valueOrNull;
    final hasSelection = gameState?.hasSelection ?? false;
    final selectedId = gameState?.selectedWordId;
    final correctId = gameState?.current?.correctWord.id;
    final language =
        ref.watch(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;

    final isThisSelected = selectedId == widget.word.id;
    final isCorrectCard = correctId == widget.word.id;
    final isWrongSelection =
        hasSelection && isThisSelected && !isCorrectCard;
    final shouldGlow = hasSelection && isCorrectCard;

    // Build base card
    Widget card = _buildCard(
      context,
      language: language,
      shouldGlow: shouldGlow,
      isWrongSelection: isWrongSelection,
    );

    // Shake transform (wrong answer)
    card = AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: card,
    );

    // Bounce/scale transform (correct answer)
    card = AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: card,
    );

    return GestureDetector(
      onTap: hasSelection ? null : _onTap,
      child: card,
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required AppLanguage language,
    required bool shouldGlow,
    required bool isWrongSelection,
  }) {
    final title = widget.word.localizedTitle(language);

    Color borderColor = Colors.transparent;
    double borderWidth = 0;
    Color bgColor = Colors.white;
    List<BoxShadow> shadows = const [
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 14,
        offset: Offset(0, 5),
      ),
    ];

    if (shouldGlow) {
      borderColor = const Color(0xFFFFD700);
      borderWidth = 4;
      bgColor = const Color(0xFFFFFDE7);
      shadows = [
        BoxShadow(
          color: const Color(0xFFFFD700).withValues(alpha: 0.55),
          blurRadius: 28,
          spreadRadius: 6,
        ),
      ];
    } else if (isWrongSelection) {
      borderColor = const Color(0xFFFF8FAB).withValues(alpha: 0.8);
      borderWidth = 3;
      bgColor = const Color(0xFFFFF0F3);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: borderWidth > 0
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
        boxShadow: shadows,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => AppImage(
                path: widget.word.image,
                size: constraints.biggest.shortestSide,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF2F1B5E),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: shouldGlow
                ? const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('⭐', style: TextStyle(fontSize: 20)),
                  )
                : const SizedBox(height: 26),
          ),
        ],
      ),
    );
  }
}
