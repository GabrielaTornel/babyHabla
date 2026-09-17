import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/localization/app_language.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../shared/models/learning_word.dart';
import '../../../../../shared/models/learning_word_extensions.dart';
import '../../../../../shared/providers/app_language_providers.dart';
import '../../../../../shared/providers/service_providers.dart';
import '../../../providers/feed_animal_provider.dart';

class AnimalDropTarget extends ConsumerStatefulWidget {
  const AnimalDropTarget({
    super.key,
    required this.animal,
    required this.correctFoodId,
  });

  final LearningWord animal;
  final String correctFoodId;

  @override
  ConsumerState<AnimalDropTarget> createState() =>
      _AnimalDropTargetState();
}

class _AnimalDropTargetState extends ConsumerState<AnimalDropTarget>
    with TickerProviderStateMixin {
  late final AnimationController _eatCtrl;
  late final AnimationController _hoverCtrl;
  late final Animation<double> _eatScaleAnim;
  late final Animation<double> _hoverScaleAnim;

  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    _eatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Eating: quick squish → big jump → settle
    _eatScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.86), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 0.86, end: 1.28), weight: 32),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 0.94), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.04), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.00), weight: 10),
    ]).animate(
        CurvedAnimation(parent: _eatCtrl, curve: Curves.easeInOut));

    // Hover: gentle scale-up while food is floating over target
    _hoverScaleAnim = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _eatCtrl.dispose();
    _hoverCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCorrectFeed(String foodId) async {
    ref.read(feedAnimalProvider.notifier).onCorrectFeed(foodId);
    await _eatCtrl.forward(from: 0);

    if (!mounted) return;
    final language =
        ref.read(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;

    // Speak the animal name as educational reinforcement
    final played = await ref
        .read(audioServiceProvider)
        .playAsset(widget.animal.localizedAudio(language));
    if (!played && mounted) {
      await ref.read(ttsServiceProvider).speakWord(
            widget.animal.localizedTitle(language),
            languageCode: language.ttsCode,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(feedAnimalProvider).valueOrNull;
    final isDraggingFood = gameState?.isDraggingFood ?? false;
    final isFeeding = gameState?.isFeeding ?? false;
    final language =
        ref.watch(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;
    final title = widget.animal.localizedTitle(language);

    return DragTarget<String>(
      // Accept any food drop; success logic runs only for the correct ID
      onWillAcceptWithDetails: (details) {
        if (isFeeding) return false;
        setState(() => _isHovering = true);
        _hoverCtrl.forward();
        return true;
      },
      onLeave: (_) {
        setState(() => _isHovering = false);
        _hoverCtrl.reverse();
      },
      onAcceptWithDetails: (details) {
        setState(() => _isHovering = false);
        _hoverCtrl.reverse();
        if (details.data == widget.correctFoodId) {
          _onCorrectFeed(details.data);
        }
        // Wrong food: no punishment — food returns to its position
      },
      builder: (context, candidateData, _) {
        final isHoveredCorrect = _isHovering &&
            candidateData.isNotEmpty &&
            candidateData.first == widget.correctFoodId;

        return AnimatedBuilder(
          animation: Listenable.merge([_eatScaleAnim, _hoverScaleAnim]),
          builder: (_, child) => Transform.scale(
            scale: _eatScaleAnim.value * _hoverScaleAnim.value,
            child: child,
          ),
          child: _AnimalCard(
            animal: widget.animal,
            title: title,
            isDraggingFood: isDraggingFood,
            isHoveredCorrect: isHoveredCorrect,
            isFeeding: isFeeding,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Animal card visual
// ─────────────────────────────────────────────

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.title,
    required this.isDraggingFood,
    required this.isHoveredCorrect,
    required this.isFeeding,
  });

  final LearningWord animal;
  final String title;
  final bool isDraggingFood;
  final bool isHoveredCorrect;
  final bool isFeeding;

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    double borderWidth = 0;
    List<BoxShadow> shadows = const [
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ];

    if (isHoveredCorrect) {
      // Correct food is hovering → bright green glow
      borderColor = const Color(0xFF66BB6A);
      borderWidth = 4;
      shadows = [
        BoxShadow(
          color: const Color(0xFF66BB6A).withValues(alpha: 0.60),
          blurRadius: 36,
          spreadRadius: 8,
        ),
      ];
    } else if (isDraggingFood) {
      // Any food is being dragged → soft golden pulse
      borderColor = const Color(0xFFFFD700).withValues(alpha: 0.65);
      borderWidth = 3;
      shadows = [
        BoxShadow(
          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
          blurRadius: 26,
          spreadRadius: 4,
        ),
      ];
    } else if (isFeeding) {
      // Just ate → golden border
      borderColor = const Color(0xFFFFD700);
      borderWidth = 4;
      shadows = [
        BoxShadow(
          color: const Color(0xFFFFD700).withValues(alpha: 0.50),
          blurRadius: 30,
          spreadRadius: 6,
        ),
      ];
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: borderWidth > 0
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
        boxShadow: shadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppImage(path: animal.image, size: 150),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF2F1B5E),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isFeeding
                ? const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('😋', style: TextStyle(fontSize: 30)),
                  )
                : isDraggingFood
                    ? const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child:
                            Text('👐', style: TextStyle(fontSize: 26)),
                      )
                    : const SizedBox(height: 38),
          ),
        ],
      ),
    );
  }
}
