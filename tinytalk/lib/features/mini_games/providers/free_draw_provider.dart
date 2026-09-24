import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/free_draw.dart';

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

class FreeDrawState {
  const FreeDrawState({
    this.strokes = const [],
    this.selectedColor = const Color(0xFFE53935),
    this.selectedBrush = BrushType.pencil,
    this.selectedSize = BrushSize.medium,
    this.isPanelOpen = true,
  });

  final List<DrawStroke> strokes;
  final Color selectedColor;
  final BrushType selectedBrush;
  final BrushSize selectedSize;
  final bool isPanelOpen;

  FreeDrawState copyWith({
    List<DrawStroke>? strokes,
    Color? selectedColor,
    BrushType? selectedBrush,
    BrushSize? selectedSize,
    bool? isPanelOpen,
  }) =>
      FreeDrawState(
        strokes: strokes ?? this.strokes,
        selectedColor: selectedColor ?? this.selectedColor,
        selectedBrush: selectedBrush ?? this.selectedBrush,
        selectedSize: selectedSize ?? this.selectedSize,
        isPanelOpen: isPanelOpen ?? this.isPanelOpen,
      );
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class FreeDrawNotifier extends Notifier<FreeDrawState> {
  @override
  FreeDrawState build() => FreeDrawState(
        selectedColor: FreeDrawPalette.colors.first,
      );

  void selectColor(Color color) => state = state.copyWith(selectedColor: color);

  void selectBrush(BrushType brush) =>
      state = state.copyWith(selectedBrush: brush);

  void selectSize(BrushSize size) => state = state.copyWith(selectedSize: size);

  void startStroke(Offset point) {
    final stroke = DrawStroke(
      color: state.selectedColor,
      points: [point],
      brushType: state.selectedBrush,
      width: state.selectedBrush.widthFor(state.selectedSize),
    );
    state = state.copyWith(strokes: [...state.strokes, stroke]);
  }

  void extendStroke(Offset point) {
    if (state.strokes.isEmpty) return;
    final updated = List<DrawStroke>.from(state.strokes);
    updated[updated.length - 1] = updated.last.withPoint(point);
    state = state.copyWith(strokes: updated);
  }

  void clear() => state = state.copyWith(strokes: const []);

  void togglePanel() => state = state.copyWith(isPanelOpen: !state.isPanelOpen);
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final freeDrawProvider =
    NotifierProvider<FreeDrawNotifier, FreeDrawState>(FreeDrawNotifier.new);
