import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/app_language_providers.dart';
import '../../models/coloring_page.dart';
import '../../providers/free_draw_provider.dart';
import '../../widgets/drawing_palette.dart';
import 'widgets/coloring_painter.dart';

class ColoringCanvasScreen extends StatelessWidget {
  const ColoringCanvasScreen({required this.pageId, super.key});

  final String pageId;

  @override
  Widget build(BuildContext context) {
    final page = coloringPages.firstWhere(
      (p) => p.id == pageId,
      orElse: () => coloringPages.first,
    );

    // Fresh palette state per coloring page: shadow the shared free-draw
    // provider with a new instance scoped to this screen's subtree.
    return ProviderScope(
      overrides: [freeDrawProvider],
      child: _ColoringCanvasBody(page: page),
    );
  }
}

class _ColoringCanvasBody extends ConsumerStatefulWidget {
  const _ColoringCanvasBody({required this.page});

  final ColoringPage page;

  @override
  ConsumerState<_ColoringCanvasBody> createState() =>
      _ColoringCanvasBodyState();
}

class _ColoringCanvasBodyState extends ConsumerState<_ColoringCanvasBody> {
  ui.Image? _lineArt;

  @override
  void initState() {
    super.initState();
    _loadLineArt();
  }

  Future<void> _loadLineArt() async {
    final bytes = await rootBundle.load(widget.page.assetPath);
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) setState(() => _lineArt = frame.image);
  }

  @override
  Widget build(BuildContext context) {
    final lineArt = _lineArt;
    if (lineArt == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(freeDrawProvider);
    final notifier = ref.read(freeDrawProvider.notifier);
    final copy = ref.watch(appCopyProvider);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ── Coloring canvas (line art on top) ──────────────────────
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) =>
                    notifier.startStroke(details.localPosition),
                onPanUpdate: (details) =>
                    notifier.extendStroke(details.localPosition),
                child: CustomPaint(
                  painter: ColoringPainter(
                    strokes: state.strokes,
                    lineArt: lineArt,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            // ── Top bar (back · clear) ───────────────────────────────
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GlassButton(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF3642C7)),
                    ),
                    const Spacer(),
                    GlassButton(
                      onTap: notifier.clear,
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFF3642C7)),
                    ),
                  ],
                ),
              ),
            ),

            // ── Color palette (bottom in portrait, side in landscape) ──
            Positioned(
              left: (isLandscape || !state.isPanelOpen) ? null : 0,
              right: 0,
              bottom: 0,
              top: isLandscape ? 0 : null,
              child: SafeArea(
                child: state.isPanelOpen
                    ? DrawingPalette(
                        isVertical: isLandscape,
                        selectedColor: state.selectedColor,
                        onColorPicked: notifier.selectColor,
                        selectedBrush: state.selectedBrush,
                        onBrushPicked: notifier.selectBrush,
                        selectedSize: state.selectedSize,
                        onSizePicked: notifier.selectSize,
                        hint: copy.freeDrawHint,
                        onTogglePanel: notifier.togglePanel,
                      )
                    : Padding(
                        padding: isLandscape
                            ? const EdgeInsets.only(top: 64, right: 12)
                            : const EdgeInsets.only(bottom: 16, right: 16),
                        child: PanelReopenButton(
                          color: state.selectedColor,
                          onTap: notifier.togglePanel,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
