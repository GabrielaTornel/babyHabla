import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_language.dart';
import '../../../../shared/providers/app_language_providers.dart';
import '../../../../shared/providers/service_providers.dart';
import '../../providers/follow_star_provider.dart';
import '../animal_finder/widgets/celebration_overlay.dart';
import 'widgets/glowing_star_widget.dart';
import 'widgets/night_sky_background.dart';
import 'widgets/sparkle_overlay.dart';
import 'widgets/star_trail_painter.dart';

class FollowStarScreen extends ConsumerStatefulWidget {
  const FollowStarScreen({super.key});

  @override
  ConsumerState<FollowStarScreen> createState() => _FollowStarScreenState();
}

class _FollowStarScreenState extends ConsumerState<FollowStarScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ────────────────────────────────────
  late AnimationController _pathCtrl;

  // ── Local animation state (updated at 60fps) ─────────────────
  final List<Offset> _trail = [];
  final List<SparkleData> _sparkles = [];

  // ── Layout ───────────────────────────────────────────────────
  Size _screenSize = Size.zero;

  // ── Constants ────────────────────────────────────────────────
  static const double _hitRadius = 88.0;
  static const double _starHalfSize = 63.0; // half of GlowingStarWidget total
  static const int _maxTrailLength = 38;
  static const int _maxSparkles = 28;

  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initPath();
  }

  void _initPath() {
    final path = ref.read(followStarProvider).currentPath;
    _pathCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: path.durationMs),
    )
      ..addListener(_onFrame)
      ..addStatusListener(_onPathDone)
      ..forward();
  }

  void _onFrame() {
    if (_screenSize == Size.zero || !mounted) return;
    final pos = _starScreenPos();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _trail.add(pos);
      if (_trail.length > _maxTrailLength) _trail.removeAt(0);
      _sparkles.removeWhere((s) => s.progress(nowMs) >= 1.0);
    });
  }

  void _onPathDone(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    // Post-frame to avoid mutating provider inside animation callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(followStarProvider.notifier).onPathCompleted();
      setState(_trail.clear);
      _pathCtrl
        ..removeListener(_onFrame)
        ..removeStatusListener(_onPathDone)
        ..dispose();
      _initPath();
    });
  }

  Offset _starScreenPos() {
    final norm =
        ref.read(followStarProvider).currentPath.positionAt(_pathCtrl.value);
    return Offset(norm.dx * _screenSize.width, norm.dy * _screenSize.height);
  }

  // ─────────────────────────────────────────────────────────────
  // Touch handling
  // ─────────────────────────────────────────────────────────────

  void _handleTouch(Offset touchPos) {
    final starPos = _starScreenPos();
    final isHit = (touchPos - starPos).distance < _hitRadius;

    // Always show sparkles — no punishment for missing (toddler UX)
    _emitSparkles(touchPos, count: isHit ? 9 : 4);

    if (isHit) {
      ref.read(followStarProvider.notifier).onTouch();
      _playFeedback();
    }
  }

  void _emitSparkles(Offset pos, {int count = 6}) {
    final newOnes = List.generate(count, (_) => SparkleData(position: pos));
    setState(() {
      _sparkles.addAll(newOnes);
      if (_sparkles.length > _maxSparkles) {
        _sparkles.removeRange(0, _sparkles.length - _maxSparkles);
      }
    });
  }

  void _playFeedback() {
    final state = ref.read(followStarProvider);
    // Every 5th touch: say "¡Muy bien!" via TTS
    if (state.touchCount % 5 == 0) {
      final language =
          ref.read(appLanguageControllerProvider).valueOrNull ??
              AppLanguage.spanish;
      ref.read(ttsServiceProvider).speakWord(
            language == AppLanguage.spanish ? '¡Muy bien!' : 'Great job!',
            languageCode: language.ttsCode,
          );
    }
  }

  @override
  void dispose() {
    _pathCtrl
      ..removeListener(_onFrame)
      ..removeStatusListener(_onPathDone)
      ..dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(followStarProvider);
    final copy = ref.watch(appCopyProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (_, constraints) {
          _screenSize = constraints.biggest;
          final starPos = _starScreenPos();

          return NightSkyBackground(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Full-screen gesture capture ───────────────────
                GestureDetector(
                  onTapDown: (d) => _handleTouch(d.localPosition),
                  onPanUpdate: (d) => _handleTouch(d.localPosition),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),

                // ── Star trail ────────────────────────────────────
                RepaintBoundary(
                  child: CustomPaint(
                    painter: StarTrailPainter(trail: List.of(_trail)),
                    size: _screenSize,
                  ),
                ),

                // ── Sparkles ─────────────────────────────────────
                SparkleOverlay(sparkles: List.of(_sparkles)),

                // ── Moving star ───────────────────────────────────
                Positioned(
                  left: starPos.dx - _starHalfSize,
                  top: starPos.dy - _starHalfSize,
                  child: const RepaintBoundary(
                    child: GlowingStarWidget(size: 70),
                  ),
                ),

                // ── Star count badge ──────────────────────────────
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 16, top: 8),
                      child: _StarCountBadge(
                        count: gameState.touchCount,
                      ),
                    ),
                  ),
                ),

                // ── Back button ───────────────────────────────────
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: _GlassButton(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Prompt (only before first touch) ─────────────
                if (gameState.touchCount == 0)
                  Positioned(
                    bottom: 64,
                    left: 28,
                    right: 28,
                    child: _FollowPrompt(text: copy.followTheStar),
                  ),

                // ── Celebration overlay ───────────────────────────
                if (gameState.showCelebration)
                  CelebrationOverlay(
                    key: ValueKey(gameState.touchCount),
                    onDismissed: () => ref
                        .read(followStarProvider.notifier)
                        .dismissCelebration(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Star count badge
// ─────────────────────────────────────────────

class _StarCountBadge extends StatelessWidget {
  const _StarCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: _NightGlassBadge(
        key: ValueKey(count),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
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
// Prompt bubble
// ─────────────────────────────────────────────

class _FollowPrompt extends StatefulWidget {
  const _FollowPrompt({required this.text});

  final String text;

  @override
  State<_FollowPrompt> createState() => _FollowPromptState();
}

class _FollowPromptState extends State<_FollowPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeCtrl,
      builder: (_, __) => Opacity(
        opacity: 0.55 + 0.45 * _fadeCtrl.value,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              shadows: [
                Shadow(
                  color: Color(0x88000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
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
// Night-themed glass helpers
// ─────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _NightGlassBadge(
        child: SizedBox(width: 22, height: 22, child: child),
      ),
    );
  }
}

class _NightGlassBadge extends StatelessWidget {
  const _NightGlassBadge({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
