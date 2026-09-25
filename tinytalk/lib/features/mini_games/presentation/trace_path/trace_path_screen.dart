import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_language.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/playful_background.dart';
import '../../../../shared/models/learning_word_extensions.dart';
import '../../../../shared/providers/app_language_providers.dart';
import '../../../../shared/providers/service_providers.dart';
import '../../models/trace_path.dart';
import '../../providers/trace_path_provider.dart';
import '../animal_finder/widgets/celebration_overlay.dart';
import '../follow_star/widgets/sparkle_overlay.dart';
import 'widgets/path_painter.dart';

const double _hitRadius = 90.0;
const double _completionThreshold = 0.98;
const int _maxSparkles = 28;
const int _sampleSteps = 120;

class TracePathScreen extends ConsumerStatefulWidget {
  const TracePathScreen({super.key});

  @override
  ConsumerState<TracePathScreen> createState() => _TracePathScreenState();
}

class _TracePathScreenState extends ConsumerState<TracePathScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _frameCtrl;
  final List<SparkleData> _sparkles = [];

  double _progress = 0.0;
  bool _completed = false;
  int _lastIndex = -1;

  String? _cachedStartPath;
  String? _cachedEndPath;
  Widget? _startImage;
  Widget? _endImage;

  @override
  void initState() {
    super.initState();
    _frameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(_onFrame);
  }

  @override
  void dispose() {
    _frameCtrl
      ..removeListener(_onFrame)
      ..dispose();
    super.dispose();
  }

  void _onFrame() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _sparkles.removeWhere((s) => s.progress(nowMs) >= 1.0);
    });
    if (_sparkles.isEmpty) _frameCtrl.stop();
  }

  void _resetRound() {
    setState(() {
      _progress = 0.0;
      _completed = false;
    });
  }

  void _emitSparkles(Offset pos, {int count = 6}) {
    final newOnes = List.generate(count, (_) => SparkleData(position: pos));
    setState(() {
      _sparkles.addAll(newOnes);
      if (_sparkles.length > _maxSparkles) {
        _sparkles.removeRange(0, _sparkles.length - _maxSparkles);
      }
    });
    if (!_frameCtrl.isAnimating) _frameCtrl.repeat();
  }

  /// Reuses the same [AppImage] instance across drag-frame rebuilds so
  /// Flutter skips its build() (and the async asset-exists lookup) unless
  /// the underlying word image actually changed.
  Widget _startImageFor(String path) {
    if (_cachedStartPath != path) {
      _cachedStartPath = path;
      _startImage = AppImage(path: path, size: 110);
    }
    return _startImage!;
  }

  Widget _endImageFor(String path) {
    if (_cachedEndPath != path) {
      _cachedEndPath = path;
      _endImage = AppImage(path: path, size: 110);
    }
    return _endImage!;
  }

  void _handleDrag(Offset touchPos, TracePathShape shape, Size screenSize) {
    if (_completed) return;

    double bestT = -1;
    for (var i = 0; i <= _sampleSteps; i++) {
      final t = i / _sampleSteps;
      if (t < _progress) continue;
      final normPos = shape.positionAt(t);
      final screenPos = Offset(
        normPos.dx * screenSize.width,
        normPos.dy * screenSize.height,
      );
      if ((touchPos - screenPos).distance < _hitRadius) {
        bestT = t;
      }
    }

    if (bestT < 0) return;

    _emitSparkles(touchPos, count: 4);
    setState(() => _progress = bestT);

    if (bestT >= _completionThreshold) {
      _completed = true;
      _emitSparkles(touchPos, count: 12);
      ref.read(tracePathProvider.notifier).onPathCompleted();
      _playEndWordAudio();
    }
  }

  Future<void> _playEndWordAudio() async {
    final round = ref.read(tracePathProvider).valueOrNull?.current;
    if (round == null) return;
    final language = ref.read(appLanguageControllerProvider).valueOrNull ??
        AppLanguage.spanish;

    final played = await ref
        .read(audioServiceProvider)
        .playAsset(round.end.localizedAudio(language));

    if (!played) {
      await ref.read(ttsServiceProvider).speakWord(
            round.end.localizedTitle(language),
            languageCode: language.ttsCode,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(tracePathProvider);
    final copy = ref.watch(appCopyProvider);
    final language = ref.watch(appLanguageControllerProvider).valueOrNull ??
        AppLanguage.spanish;

    return Scaffold(
      body: PlayfulBackground(
        child: gameAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (state) {
            final round = state.current;
            if (round == null) {
              return Center(child: Text(copy.wordNotFound));
            }

            if (state.currentIndex != _lastIndex) {
              _lastIndex = state.currentIndex;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _resetRound();
              });
            }

            return LayoutBuilder(
              builder: (_, constraints) {
                final screenSize = constraints.biggest;
                final babyPos = Offset(
                  round.shape.positionAt(_progress).dx * screenSize.width,
                  round.shape.positionAt(_progress).dy * screenSize.height,
                );
                final endPos = Offset(
                  round.shape.end.dx * screenSize.width,
                  round.shape.end.dy * screenSize.height,
                );

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTapDown: (d) =>
                          _handleDrag(d.localPosition, round.shape, screenSize),
                      onPanStart: (d) =>
                          _handleDrag(d.localPosition, round.shape, screenSize),
                      onPanUpdate: (d) =>
                          _handleDrag(d.localPosition, round.shape, screenSize),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    ),
                    // A CustomPaint with an explicit `size` always absorbs hit
                    // tests within its bounds, even without a painter.hitTest
                    // override — IgnorePointer keeps it purely decorative so
                    // touches reach the GestureDetector behind it.
                    IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: PathPainter(
                            shape: round.shape,
                            progress: _progress,
                            screenSize: screenSize,
                          ),
                          size: screenSize,
                        ),
                      ),
                    ),
                    SparkleOverlay(sparkles: List.of(_sparkles)),
                    Positioned(
                      left: babyPos.dx - 55,
                      top: babyPos.dy - 55,
                      child: IgnorePointer(
                        child: _startImageFor(round.start.image),
                      ),
                    ),
                    Positioned(
                      left: endPos.dx - 55,
                      top: endPos.dy - 55,
                      child: IgnorePointer(
                        child: _endImageFor(round.end.image),
                      ),
                    ),
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, top: 8),
                          child: _GlassButton(
                            onTap: () => context.pop(),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF3642C7),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_progress == 0.0)
                      Positioned(
                        bottom: 40,
                        left: 28,
                        right: 28,
                        child: IgnorePointer(
                          child: _PromptBubble(
                            text: copy.followThePathTo(
                              round.end.localizedTitle(language),
                            ),
                          ),
                        ),
                      ),
                    if (state.showCelebration)
                      CelebrationOverlay(
                        key: ValueKey(state.roundsCompleted),
                        onDismissed: () => ref
                            .read(tracePathProvider.notifier)
                            .dismissCelebration(),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Prompt bubble
// ─────────────────────────────────────────────

class _PromptBubble extends StatelessWidget {
  const _PromptBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF3642C7),
          fontWeight: FontWeight.w900,
          fontSize: 19,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Glass button
// ─────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
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
        child: SizedBox(width: 22, height: 22, child: child),
      ),
    );
  }
}
