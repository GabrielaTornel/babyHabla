import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_language.dart';
import '../../../../core/widgets/playful_background.dart';
import '../../../../core/widgets/primary_bouncy_button.dart';
import '../../../../shared/models/learning_word_extensions.dart';
import '../../../../shared/providers/app_language_providers.dart';
import '../../providers/feed_animal_provider.dart';
import '../animal_finder/widgets/celebration_overlay.dart';
import 'widgets/animal_drop_target.dart';
import 'widgets/draggable_food_widget.dart';

class FeedAnimalScreen extends ConsumerStatefulWidget {
  const FeedAnimalScreen({super.key});

  @override
  ConsumerState<FeedAnimalScreen> createState() => _FeedAnimalScreenState();
}

class _FeedAnimalScreenState extends ConsumerState<FeedAnimalScreen> {
  Timer? _advanceTimer;

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _scheduleAdvance() {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 2700), () {
      if (mounted) {
        ref.read(feedAnimalProvider.notifier).nextChallenge();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Start the auto-advance timer the moment feeding begins
    ref.listen<AsyncValue<FeedAnimalState>>(feedAnimalProvider,
        (prev, next) {
      final wasFeeding = prev?.valueOrNull?.isFeeding ?? false;
      final isFeeding = next.valueOrNull?.isFeeding ?? false;
      if (!wasFeeding && isFeeding) {
        _scheduleAdvance();
      }
    });

    final gameAsync = ref.watch(feedAnimalProvider);
    final copy = ref.watch(appCopyProvider);

    return Scaffold(
      body: PlayfulBackground(
        child: Stack(
          children: [
            // ── Game body ─────────────────────────────────────────
            gameAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (state) => state.isFinished
                  ? _FinishedView(
                      score: state.score,
                      total: state.total,
                      onPlayAgain: () =>
                          ref.read(feedAnimalProvider.notifier).restart(),
                      onBack: () => context.pop(),
                      copy: copy,
                    )
                  : _GameContent(state: state, copy: copy),
            ),

            // ── Top bar ───────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _GlassButton(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF3642C7)),
                    ),
                    const Spacer(),
                    gameAsync
                            .whenData((s) => _ScoreBadge(score: s.score))
                            .valueOrNull ??
                        const SizedBox.shrink(),
                    const SizedBox(width: 8),
                    gameAsync
                            .whenData(
                              (s) => _ProgressBadge(
                                current:
                                    s.currentIndex.clamp(0, s.total),
                                total: s.total,
                              ),
                            )
                            .valueOrNull ??
                        const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            // ── Celebration stars (correct feed only) ─────────────
            if (gameAsync.valueOrNull?.showCelebration == true)
              CelebrationOverlay(
                key: ValueKey(gameAsync.valueOrNull?.currentIndex),
                onDismissed: () {},
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Game content
// ─────────────────────────────────────────────

class _GameContent extends ConsumerWidget {
  const _GameContent({required this.state, required this.copy});

  final FeedAnimalState state;
  final AppCopy copy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = state.current!;
    final language =
        ref.watch(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;
    final animalName = challenge.animal.localizedTitle(language);
    final foodName = challenge.correctFood.localizedTitle(language);

    final prompt = state.isFeeding
        ? copy.greatJob
        : copy.feedPrompt(foodName, animalName);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 72, 16, 20),
        child: Column(
          children: [
            // Coco mascot speech bubble
            _CocoPrompt(prompt: prompt),
            const SizedBox(height: 16),

            // Animal drop target — centered, large
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: AnimalDropTarget(
                    key: ValueKey('animal_${state.currentIndex}'),
                    animal: challenge.animal,
                    correctFoodId: challenge.correctFood.id,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Drag hint (fades away while feeding)
            AnimatedOpacity(
              opacity: state.isFeeding ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                copy.dragFoodInstruction,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7A7A9D),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 16),

            // Food options row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: challenge.foodOptions.map(
                (food) => DraggableFoodWidget(
                  key: ValueKey('${state.currentIndex}_${food.id}'),
                  food: food,
                ),
              ).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Coco mascot prompt bubble
// ─────────────────────────────────────────────

class _CocoPrompt extends StatelessWidget {
  const _CocoPrompt({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale:
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
      child: Container(
        key: ValueKey(prompt),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 16,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐨', style: TextStyle(fontSize: 34)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                prompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF3642C7),
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Finished overlay
// ─────────────────────────────────────────────

class _FinishedView extends StatelessWidget {
  const _FinishedView({
    required this.score,
    required this.total,
    required this.onPlayAgain,
    required this.onBack,
    required this.copy,
  });

  final int score;
  final int total;
  final VoidCallback onPlayAgain;
  final VoidCallback onBack;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.8 + 0.2 * value, child: child),
      ),
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 40,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎊🍎🎊', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 16),
                Text(
                  copy.congratulations,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(
                        color: const Color(0xFF3642C7),
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF97316), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    copy.correctOf(score, total),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryBouncyButton(
                  label: copy.playAgain,
                  onPressed: onPlayAgain,
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: onBack,
                  child: Text(
                    copy.goBack,
                    style: const TextStyle(
                      color: Color(0xFF7A7A9D),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Score badge
// ─────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: _GlassBadge(
        key: ValueKey(score),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 5),
            Text(
              '$score',
              style: const TextStyle(
                color: Color(0xFF3642C7),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Progress badge
// ─────────────────────────────────────────────

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return _GlassBadge(
      child: Text(
        '$current / $total',
        style: const TextStyle(
          color: Color(0xFF3642C7),
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Glass helpers
// ─────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassBadge(
        child: SizedBox(width: 24, height: 24, child: child),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
