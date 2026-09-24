import 'package:flutter/material.dart';

class MiniGameData {
  const MiniGameData({
    required this.id,
    required this.titleEs,
    required this.titleEn,
    required this.emoji,
    required this.gradientColors,
    required this.descriptionEs,
    required this.descriptionEn,
  });

  final String id;
  final String titleEs;
  final String titleEn;
  final String emoji;
  final List<Color> gradientColors;
  final String descriptionEs;
  final String descriptionEn;
}

const miniGames = <MiniGameData>[
  MiniGameData(
    id: 'pop_bubbles',
    titleEs: 'Revienta Burbujas',
    titleEn: 'Pop Bubbles',
    emoji: '🫧',
    gradientColors: [Color(0xFF64B5F6), Color(0xFF1565C0)],
    descriptionEs: '¡Toca las burbujas!',
    descriptionEn: 'Pop the bubbles!',
  ),
  MiniGameData(
    id: 'drag_drop',
    titleEs: 'Arrastra y Ordena',
    titleEn: 'Drag & Sort',
    emoji: '🧩',
    gradientColors: [Color(0xFFF97316), Color(0xFFEC4899)],
    descriptionEs: '¡Arrastra al lugar correcto!',
    descriptionEn: 'Drag to the right place!',
  ),
  MiniGameData(
    id: 'animal_finder',
    titleEs: '¿Dónde está el animal?',
    titleEn: 'Find the Animal!',
    emoji: '🐾',
    gradientColors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
    descriptionEs: '¡Encuentra el animal correcto!',
    descriptionEn: 'Find the right animal!',
  ),
  MiniGameData(
    id: 'feed_animal',
    titleEs: 'Alimenta al Animal',
    titleEn: 'Feed the Animal!',
    emoji: '🍎',
    gradientColors: [Color(0xFFF97316), Color(0xFFFFB300)],
    descriptionEs: '¡Dale la comida al animal!',
    descriptionEn: 'Give the food to the animal!',
  ),
  MiniGameData(
    id: 'touch_color',
    titleEs: 'Toca el Color',
    titleEn: 'Touch the Color!',
    emoji: '🎨',
    gradientColors: [Color(0xFFFDD835), Color(0xFFE53935)],
    descriptionEs: '¡Toca el color correcto!',
    descriptionEn: 'Tap the right color!',
  ),
  MiniGameData(
    id: 'follow_star',
    titleEs: 'Sigue la Estrella',
    titleEn: 'Follow the Star',
    emoji: '⭐',
    gradientColors: [Color(0xFF1E1050), Color(0xFF8A3A9E)],
    descriptionEs: '¡Sigue la estrella mágica!',
    descriptionEn: 'Follow the magic star!',
  ),
  MiniGameData(
    id: 'dress_up',
    titleEs: 'Viste a Coco',
    titleEn: 'Dress Up Coco',
    emoji: '🎀',
    gradientColors: [Color(0xFFFFB3C6), Color(0xFFB39DDB)],
    descriptionEs: '¡Pon accesorios a Coco!',
    descriptionEn: 'Decorate Coco with accessories!',
  ),
  MiniGameData(
    id: 'trace_path',
    titleEs: 'Sigue el Camino',
    titleEn: 'Follow the Path',
    emoji: '🐾',
    gradientColors: [Color(0xFF4FC3A1), Color(0xFF2E8B7F)],
    descriptionEs: '¡Sigue el camino con tu dedo!',
    descriptionEn: 'Trace the path with your finger!',
  ),
  MiniGameData(
    id: 'free_draw',
    titleEs: 'Dibuja Libre',
    titleEn: 'Free Draw',
    emoji: '🖍️',
    gradientColors: [Color(0xFFFFB300), Color(0xFFE91E63)],
    descriptionEs: '¡Dibuja lo que quieras!',
    descriptionEn: 'Draw whatever you like!',
  ),
];
