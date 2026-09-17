import 'package:flutter/material.dart';

/// Maps a color word title (English or Spanish) to a pair of
/// Flutter colors used to render the gradient card.
class ColorMapper {
  ColorMapper._();

  static Color primary(String wordTitle) =>
      _map[wordTitle.toLowerCase().trim()]?.$1 ?? const Color(0xFF9E9E9E);

  static Color secondary(String wordTitle) =>
      _map[wordTitle.toLowerCase().trim()]?.$2 ?? const Color(0xFFBDBDBD);

  /// Returns white or darkPurple depending on the card's perceived brightness,
  /// so text is always readable against any color.
  static Color textColor(String wordTitle) {
    final bg = primary(wordTitle);
    return bg.computeLuminance() > 0.55
        ? const Color(0xFF2F1B5E)
        : Colors.white;
  }

  static const _map = <String, (Color, Color)>{
    // ── Reds ─────────────────────────────────────────────
    'red': (Color(0xFFE53935), Color(0xFFEF9A9A)),
    'rojo': (Color(0xFFE53935), Color(0xFFEF9A9A)),
    // ── Blues ────────────────────────────────────────────
    'blue': (Color(0xFF1E88E5), Color(0xFF90CAF9)),
    'azul': (Color(0xFF1E88E5), Color(0xFF90CAF9)),
    // ── Yellows ──────────────────────────────────────────
    'yellow': (Color(0xFFFDD835), Color(0xFFFFF59D)),
    'amarillo': (Color(0xFFFDD835), Color(0xFFFFF59D)),
    // ── Greens ───────────────────────────────────────────
    'green': (Color(0xFF43A047), Color(0xFFA5D6A7)),
    'verde': (Color(0xFF43A047), Color(0xFFA5D6A7)),
    // ── Oranges ──────────────────────────────────────────
    'orange': (Color(0xFFFB8C00), Color(0xFFFFCC80)),
    'naranja': (Color(0xFFFB8C00), Color(0xFFFFCC80)),
    // ── Purples ──────────────────────────────────────────
    'purple': (Color(0xFF8E24AA), Color(0xFFCE93D8)),
    'morado': (Color(0xFF8E24AA), Color(0xFFCE93D8)),
    'violeta': (Color(0xFF7B1FA2), Color(0xFFCE93D8)),
    // ── Pinks ────────────────────────────────────────────
    'pink': (Color(0xFFE91E63), Color(0xFFF48FB1)),
    'rosa': (Color(0xFFE91E63), Color(0xFFF48FB1)),
    // ── Neutrals ─────────────────────────────────────────
    'white': (Color(0xFFF5F5F5), Color(0xFFEEEEEE)),
    'blanco': (Color(0xFFF5F5F5), Color(0xFFEEEEEE)),
    'black': (Color(0xFF424242), Color(0xFF757575)),
    'negro': (Color(0xFF424242), Color(0xFF757575)),
    'gray': (Color(0xFF757575), Color(0xFFBDBDBD)),
    'grey': (Color(0xFF757575), Color(0xFFBDBDBD)),
    'gris': (Color(0xFF757575), Color(0xFFBDBDBD)),
    // ── Browns ───────────────────────────────────────────
    'brown': (Color(0xFF6D4C41), Color(0xFFBCAAA4)),
    'café': (Color(0xFF6D4C41), Color(0xFFBCAAA4)),
    'marron': (Color(0xFF6D4C41), Color(0xFFBCAAA4)),
    // ── Extras ───────────────────────────────────────────
    'turquoise': (Color(0xFF00ACC1), Color(0xFF80DEEA)),
    'turquesa': (Color(0xFF00ACC1), Color(0xFF80DEEA)),
    'gold': (Color(0xFFFFB300), Color(0xFFFFE082)),
    'dorado': (Color(0xFFFFB300), Color(0xFFFFE082)),
  };
}
