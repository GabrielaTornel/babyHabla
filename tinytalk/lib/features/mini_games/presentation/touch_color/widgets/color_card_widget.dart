import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/localization/app_language.dart';
import '../../../../../shared/models/learning_word.dart';
import '../../../../../shared/models/learning_word_extensions.dart';
import '../../../../../shared/providers/app_language_providers.dart';
import '../../../../../shared/providers/service_providers.dart';
import '../../../providers/touch_color_provider.dart';
import 'color_mapper.dart';

class ColorCardWidget extends ConsumerStatefulWidget {
  const ColorCardWidget({super.key, required this.word});

  final LearningWord word;

  @override
  ConsumerState<ColorCardWidget> createState() => _ColorCardWidgetState();
}

class _ColorCardWidgetState extends ConsumerState<ColorCardWidget>
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
      duration: const Duration(milliseconds: 650),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.20), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.20, end: 0.94), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.07), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.07, end: 1.00), weight: 25),
    ]).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: -5.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 20),
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
    final s = ref.read(touchColorProvider).valueOrNull;
    if (s == null || s.hasSelection) return;

    final isCorrect = widget.word.id == s.current?.correctWord.id;

    // Immediate state update → visual feedback starts
    ref.read(touchColorProvider.notifier).onSelect(widget.word.id);

    if (isCorrect) {
      _bounceCtrl.forward(from: 0);
    } else {
      _shakeCtrl.forward(from: 0);
    }

    // Audio: try asset first, fall back to TTS
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
    final gameState = ref.watch(touchColorProvider).valueOrNull;
    final hasSelection = gameState?.hasSelection ?? false;
    final selectedId = gameState?.selectedWordId;
    final correctId = gameState?.current?.correctWord.id;
    final language =
        ref.watch(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;

    final title = widget.word.localizedTitle(language);
    final isCorrectCard = correctId == widget.word.id;
    final isWrongSelection =
        hasSelection && selectedId == widget.word.id && !isCorrectCard;
    final shouldGlow = hasSelection && isCorrectCard;

    Widget card = _buildCard(
      context,
      title: title,
      shouldGlow: shouldGlow,
      isWrongSelection: isWrongSelection,
    );

    // Shake transform (wrong tap)
    card = AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: card,
    );

    // Bounce/scale transform (correct tap)
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
    required String title,
    required bool shouldGlow,
    required bool isWrongSelection,
  }) {
    final primary = ColorMapper.primary(widget.word.title);
    final secondary = ColorMapper.secondary(widget.word.title);
    final labelColor = ColorMapper.textColor(widget.word.title);

    // Light cards (white, yellow) need a subtle border to stand out
    final needsBorder = primary.computeLuminance() > 0.7;

    List<BoxShadow> shadows = [
      BoxShadow(
        color: primary.withValues(alpha: 0.45),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];

    Border? border;

    if (shouldGlow) {
      shadows = [
        BoxShadow(
          color: primary.withValues(alpha: 0.75),
          blurRadius: 36,
          spreadRadius: 8,
        ),
        BoxShadow(
          color: const Color(0xFFFFD700).withValues(alpha: 0.50),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
      border = Border.all(
        color: const Color(0xFFFFD700),
        width: 4,
      );
    } else if (isWrongSelection) {
      shadows = [
        BoxShadow(
          color: const Color(0xFFFF8FAB).withValues(alpha: 0.50),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
      border = Border.all(
        color: const Color(0xFFFF8FAB).withValues(alpha: 0.70),
        width: 3,
      );
    } else if (needsBorder) {
      border = Border.all(
        color: const Color(0x22000000),
        width: 1.5,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, secondary],
        ),
        borderRadius: BorderRadius.circular(28),
        border: border,
        boxShadow: shadows,
      ),
      child: Column(
        children: [
          // ── Color fill area ──────────────────────────────────────
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: shouldGlow
                    ? const Text(
                        '⭐',
                        style: TextStyle(fontSize: 44),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),

          // ── Name label (frosted pill) ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: labelColor == Colors.white
                      ? const Color(0xFF2F1B5E)
                      : labelColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
