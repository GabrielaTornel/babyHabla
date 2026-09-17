import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/playful_background.dart';
import '../../../../core/widgets/primary_bouncy_button.dart';
import '../../../../shared/providers/app_language_providers.dart';
import '../../providers/pop_bubbles_providers.dart';
import 'widgets/bubble_widget.dart';

class PopBubblesScreen extends ConsumerWidget {
  const PopBubblesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(popBubblesProvider);
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: PlayfulBackground(
        child: Stack(
          children: [
            // ── Floating bubbles ───────────────────────────────────
            gameState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (state) => Stack(
                clipBehavior: Clip.none,
                children: state.isFinished
                    ? [] // stop showing bubbles when time is up
                    : state.bubbles
                        .map(
                          (bubble) => BubbleWidget(
                            key: ValueKey(bubble.id),
                            bubble: bubble,
                            screenWidth: screenSize.width,
                            screenHeight: screenSize.height,
                            onPopped: (id) => ref
                                .read(popBubblesProvider.notifier)
                                .onPopped(id),
                            onFloatedAway: (id) => ref
                                .read(popBubblesProvider.notifier)
                                .onFloatedAway(id),
                          ),
                        )
                        .toList(),
              ),
            ),

            // ── Top UI bar (back · timer · score) ─────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Back button
                    _GlassButton(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF3642C7)),
                    ),

                    const Spacer(),

                    // Countdown timer
                    gameState.whenData(
                      (s) => _TimerBadge(
                        label: s.timerLabel,
                        isUrgent: s.timeRemaining <= 10,
                      ),
                    ).valueOrNull ?? const SizedBox.shrink(),

                    const SizedBox(width: 10),

                    // Pop counter
                    gameState.whenData(
                      (s) => _ScoreBadge(count: s.totalPopped),
                    ).valueOrNull ?? const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            // ── Game-over overlay ──────────────────────────────────
            gameState.whenData((s) => s.isFinished).valueOrNull == true
                ? _GameOverOverlay(
                    totalPopped: gameState.valueOrNull?.totalPopped ?? 0,
                    onPlayAgain: () =>
                        ref.read(popBubblesProvider.notifier).restart(),
                    onBack: () => context.pop(),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Timer badge
// ─────────────────────────────────────────────

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.label, required this.isUrgent});

  final String label;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent
            ? const Color(0xFFFF4444)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded,
              size: 18,
              color: isUrgent ? Colors.white : const Color(0xFF3642C7)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isUrgent ? Colors.white : const Color(0xFF3642C7),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Score badge
// ─────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: _GlassBadge(
        key: ValueKey(count),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 5),
            Text(
              '$count',
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
// Game-over overlay
// ─────────────────────────────────────────────

class _GameOverOverlay extends ConsumerWidget {
  const _GameOverOverlay({
    required this.totalPopped,
    required this.onPlayAgain,
    required this.onBack,
  });

  final int totalPopped;
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
                // Stars decoration
                const Text('🌟⭐🌟',
                    style: TextStyle(fontSize: 40)),
                const SizedBox(height: 16),

                // Title
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

                // Time-up label
                Text(
                  copy.timeUp,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF7A7A9D),
                      ),
                ),
                const SizedBox(height: 20),

                // Score card
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B61FF), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    copy.bubblesPopped(totalPopped),
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

                // Buttons
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
// Shared glass-style helpers
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
              color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}
