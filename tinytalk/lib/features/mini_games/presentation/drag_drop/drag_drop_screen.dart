import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_language.dart';
import '../../../../core/widgets/playful_background.dart';
import '../../../../core/widgets/primary_bouncy_button.dart';
import '../../../../shared/providers/app_language_providers.dart';
import '../../providers/drag_drop_providers.dart';
import 'widgets/draggable_item_widget.dart';
import 'widgets/drop_target_widget.dart';
import 'widgets/success_overlay.dart';

class DragDropScreen extends ConsumerWidget {
  const DragDropScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(dragDropProvider);
    final copy = ref.watch(appCopyProvider);

    return Scaffold(
      body: PlayfulBackground(
        child: Stack(
          children: [
            // ── Game body ──────────────────────────────────────────
            gameState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (state) => state.isFinished
                  ? _FinishedOverlay(
                      score: state.score,
                      total: state.total,
                      onPlayAgain: () =>
                          ref.read(dragDropProvider.notifier).restart(),
                      onBack: () => context.pop(),
                    )
                  : _GameContent(state: state, copy: copy),
            ),

            // ── Top bar (back · score · progress) ─────────────────
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
                    gameState
                            .whenData((s) => _ScoreBadge(score: s.score))
                            .valueOrNull ??
                        const SizedBox.shrink(),
                    const SizedBox(width: 8),
                    gameState
                            .whenData(
                              (s) => _ProgressBadge(
                                current:
                                    s.currentIndex.clamp(0, s.total),
                                total: s.total,
                                copy: copy,
                              ),
                            )
                            .valueOrNull ??
                        const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            // ── Success flash ──────────────────────────────────────
            if (gameState.valueOrNull?.showSuccess == true)
              SuccessOverlay(
                onDismissed: () =>
                    ref.read(dragDropProvider.notifier).nextChallenge(),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Main game content
// ─────────────────────────────────────────────

class _GameContent extends ConsumerWidget {
  const _GameContent({required this.state, required this.copy});

  final DragDropState state;
  final AppCopy copy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = state.current!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
        child: Column(
          children: [
            // Instruction label
            Text(
              copy.whereDoesItBelong,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF3642C7),
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const Spacer(),

            // Draggable word card
            DraggableItemWidget(
              key: ValueKey(challenge.word.id),
              word: challenge.word,
            ),

            const Spacer(),

            // Hint
            Text(
              copy.dragInstruction,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7A7A9D),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),

            // Drop targets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: challenge.targets
                  .map(
                    (cat) => DropTargetWidget(
                      category: cat,
                      label: copy.categoryTitle(cat.id),
                      onAccepted: () =>
                          ref.read(dragDropProvider.notifier).onCorrectDrop(),
                    ),
                  )
                  .toList(),
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

class _FinishedOverlay extends ConsumerWidget {
  const _FinishedOverlay({
    required this.score,
    required this.total,
    required this.onPlayAgain,
    required this.onBack,
  });

  final int score;
  final int total;
  final VoidCallback onPlayAgain;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = ref.watch(appCopyProvider);

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
                const Text('🎊🎉🎊', style: TextStyle(fontSize: 40)),
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
                const SizedBox(height: 8),
                Text(
                  copy.timeUp,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: const Color(0xFF7A7A9D)),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
  const _ProgressBadge({
    required this.current,
    required this.total,
    required this.copy,
  });

  final int current;
  final int total;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return _GlassBadge(
      child: Text(
        copy.challengeOf(current + 1, total),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}
