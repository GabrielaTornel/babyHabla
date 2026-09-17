import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_language.dart';
import '../../../../core/widgets/playful_background.dart';
import '../../../../core/widgets/primary_bouncy_button.dart';
import '../../../../shared/providers/app_language_providers.dart';
import '../../../../shared/providers/service_providers.dart';
import '../../models/dress_up_accessory.dart';
import '../../providers/dress_up_provider.dart';
import '../animal_finder/widgets/celebration_overlay.dart';
import 'widgets/accessory_card_widget.dart';
import 'widgets/coco_dress_up_widget.dart';

class DressUpScreen extends ConsumerStatefulWidget {
  const DressUpScreen({super.key});

  @override
  ConsumerState<DressUpScreen> createState() => _DressUpScreenState();
}

class _DressUpScreenState extends ConsumerState<DressUpScreen> {
  Timer? _celebrationTimer;

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    super.dispose();
  }

  void _playEquipSound() {
    final language =
        ref.read(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;
    ref.read(ttsServiceProvider).speakWord(
          language == AppLanguage.spanish ? '¡Qué bonito!' : 'So cute!',
          languageCode: language.ttsCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Auto-dismiss celebration after 2.2 s
    ref.listen<DressUpState>(dressUpProvider, (prev, next) {
      if (next.showCelebration && !(prev?.showCelebration ?? false)) {
        _playEquipSound();
        _celebrationTimer?.cancel();
        _celebrationTimer = Timer(const Duration(milliseconds: 2200), () {
          if (mounted) {
            ref.read(dressUpProvider.notifier).dismissCelebration();
          }
        });
      }
    });

    final state = ref.watch(dressUpProvider);
    final copy = ref.watch(appCopyProvider);

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // ── Main layout ───────────────────────────────────
              Column(
                children: [
                  // Top bar
                  Padding(
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
                        // Equipped count badge
                        if (!state.isEmpty)
                          _CountBadge(count: state.equippedCount),
                        const SizedBox(width: 8),
                        // Clear all button
                        if (!state.isEmpty)
                          _GlassButton(
                            onTap: () =>
                                ref.read(dressUpProvider.notifier).clearAll(),
                            child: const Icon(Icons.refresh_rounded,
                                color: Color(0xFF3642C7)),
                          ),
                      ],
                    ),
                  ),

                  // Prompt bubble
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: _PromptBubble(
                      text: state.isEmpty
                          ? copy.dressUpPrompt
                          : copy.dressUpCelebration,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Coco character area (drag target)
                  const Expanded(
                    child: Center(child: CocoDressUpWidget()),
                  ),

                  const SizedBox(height: 12),

                  // Accessories tray
                  _AccessoriesTray(
                    accessories: DressUpAccessory.all,
                    equipped: state.equipped,
                  ),

                  const SizedBox(height: 16),
                ],
              ),

              // ── Celebration overlay ───────────────────────────
              if (state.showCelebration)
                CelebrationOverlay(
                  key: ValueKey(state.totalEquips),
                  onDismissed: () =>
                      ref.read(dressUpProvider.notifier).dismissCelebration(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Prompt bubble (Coco speaks)
// ─────────────────────────────────────────────

class _PromptBubble extends StatelessWidget {
  const _PromptBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
      child: Container(
        key: ValueKey(text),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐨', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF3642C7),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
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
// Accessories tray
// ─────────────────────────────────────────────

class _AccessoriesTray extends StatelessWidget {
  const _AccessoriesTray({
    required this.accessories,
    required this.equipped,
  });

  final List<DressUpAccessory> accessories;
  final Map<AccessorySlot, String> equipped;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: accessories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final acc = accessories[index];
          final isEquipped =
              equipped[acc.slot] == acc.id;
          return AccessoryCardWidget(
            key: ValueKey(acc.id),
            accessory: acc,
            isEquipped: isEquipped,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Equipped count badge
// ─────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: _GlassBadge(
        key: ValueKey(count),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎀', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFF3642C7),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared glass helpers
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
        child: SizedBox(width: 22, height: 22, child: child),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

// ─────────────────────────────────────────────
// Unused but kept for future use in finished overlay
// ─────────────────────────────────────────────

// ignore: unused_element
class _FinishedBanner extends StatelessWidget {
  const _FinishedBanner({required this.copy, required this.onClear});

  final AppCopy copy;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: PrimaryBouncyButton(
          label: copy.playAgain,
          onPressed: onClear,
        ),
      ),
    );
  }
}
