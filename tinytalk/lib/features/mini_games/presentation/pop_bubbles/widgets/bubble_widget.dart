import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/localization/app_language.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../shared/models/learning_word_extensions.dart';
import '../../../../../shared/providers/app_language_providers.dart';
import '../../../../../shared/providers/service_providers.dart';
import '../../../models/bubble_data.dart';

class BubbleWidget extends ConsumerStatefulWidget {
  const BubbleWidget({
    required this.bubble,
    required this.screenWidth,
    required this.screenHeight,
    required this.onPopped,
    required this.onFloatedAway,
    super.key,
  });

  final BubbleData bubble;
  final double screenWidth;
  final double screenHeight;
  final void Function(String id) onPopped;
  final void Function(String id) onFloatedAway;

  @override
  ConsumerState<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends ConsumerState<BubbleWidget>
    with TickerProviderStateMixin {
  // Float animation: value 0.0 (bottom) → 1.0 (off top of screen)
  late AnimationController _floatCtrl;

  // Pop burst animation: plays once when tapped
  late AnimationController _popCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  bool _isPopped = false;

  @override
  void initState() {
    super.initState();
    _buildControllers();
  }

  void _buildControllers() {
    final duration = Duration(
      milliseconds: (9000 / widget.bubble.speedFactor).round(),
    );

    _floatCtrl = AnimationController(vsync: this, duration: duration)
      ..value = widget.bubble.startFraction
      ..addStatusListener(_onFloatStatus)
      ..forward();

    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.7).animate(
      CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut),
    );
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _popCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(BubbleWidget old) {
    super.didUpdateWidget(old);
    // A new word has been assigned to this slot — restart the float.
    if (old.bubble.word.id != widget.bubble.word.id) {
      _isPopped = false;
      _popCtrl.reset();

      final newDuration = Duration(
        milliseconds: (9000 / widget.bubble.speedFactor).round(),
      );
      _floatCtrl
        ..duration = newDuration
        ..value = widget.bubble.startFraction
        ..forward();
    }
  }

  void _onFloatStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isPopped) {
      widget.onFloatedAway(widget.bubble.id);
    }
  }

  Future<void> _handleTap() async {
    if (_isPopped) return;
    _isPopped = true;
    _floatCtrl.stop();

    // Pronounce the word using available audio or TTS fallback
    final language =
        ref.read(appLanguageControllerProvider).valueOrNull ?? AppLanguage.spanish;
    final title = widget.bubble.word.localizedTitle(language);

    final played = await ref
        .read(audioServiceProvider)
        .playAsset(widget.bubble.word.localizedAudio(language));

    if (!played) {
      await ref
          .read(ttsServiceProvider)
          .speakWord(title, languageCode: language.ttsCode);
    }

    await _popCtrl.forward();
    widget.onPopped(widget.bubble.id);
  }

  @override
  void dispose() {
    _floatCtrl
      ..removeStatusListener(_onFloatStatus)
      ..dispose();
    _popCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubble = widget.bubble;

    return AnimatedBuilder(
      // Single listener for both controllers — efficient, no double-rebuild
      animation: Listenable.merge([_floatCtrl, _popCtrl]),
      child: RepaintBoundary(
        // Isolates the bubble's repaint from siblings — key for performance
        child: GestureDetector(
          onTap: _handleTap,
          child: _BubbleVisual(bubble: bubble),
        ),
      ),
      builder: (context, child) {
        final progress = _floatCtrl.value; // 0.0 → 1.0

        // Y: moves from below the screen to above it
        final yPos = widget.screenHeight * (1.0 - progress) - bubble.size;

        // X: gentle sinusoidal drift (3 half-waves during the full float)
        final drift = math.sin(progress * math.pi * 3) * 22.0;
        final xPos = (widget.screenWidth * bubble.xFraction + drift)
            .clamp(0.0, widget.screenWidth - bubble.size);

        return Positioned(
          left: xPos,
          top: yPos,
          width: bubble.size,
          height: bubble.size,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: Opacity(
              opacity: _fadeAnim.value,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Pure visual widget — never rebuilds during animation
// ─────────────────────────────────────────────

class _BubbleVisual extends StatelessWidget {
  const _BubbleVisual({required this.bubble});

  final BubbleData bubble;

  @override
  Widget build(BuildContext context) {
    final size = bubble.size;
    final imageSize = size * 0.68;

    return Consumer(
      builder: (context, ref, _) {
        final language =
            ref.watch(appLanguageControllerProvider).valueOrNull ??
                AppLanguage.spanish;
        final title = bubble.word.localizedTitle(language);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Bubble body ──────────────────────────────────────
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bubble.color,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.75),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: bubble.color.withValues(alpha: 0.45),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // ── Shine highlight (top-left arc) ───────────────────
            Positioned(
              top: size * 0.11,
              left: size * 0.18,
              child: Container(
                width: size * 0.32,
                height: size * 0.18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ),

            // ── Word image (centered, takes most of the bubble) ──
            Positioned(
              top: size * 0.08,
              left: (size - imageSize) / 2,
              child: AppImage(path: bubble.word.image, size: imageSize),
            ),

            // ── Word label ───────────────────────────────────────
            Positioned(
              bottom: size * 0.04,
              left: 4,
              right: 4,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF2F1B5E),
                  fontWeight: FontWeight.w900,
                  fontSize: (size * 0.13).clamp(11.0, 15.0),
                  shadows: const [
                    Shadow(color: Colors.white, blurRadius: 5),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
