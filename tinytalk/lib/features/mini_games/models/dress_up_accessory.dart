import 'package:flutter/material.dart';

enum AccessorySlot { hat, face, neck, body, back }

class DressUpAccessory {
  const DressUpAccessory({
    required this.id,
    required this.emoji,
    required this.labelEs,
    required this.labelEn,
    required this.slot,
    required this.cardColor,
  });

  final String id;
  final String emoji;
  final String labelEs;
  final String labelEn;
  final AccessorySlot slot;
  final Color cardColor;

  static const List<DressUpAccessory> all = [
    // ── Hats ─────────────────────────────────────────────────
    DressUpAccessory(
      id: 'hat_crown',
      emoji: '👑',
      labelEs: 'Corona',
      labelEn: 'Crown',
      slot: AccessorySlot.hat,
      cardColor: Color(0xFFFFD97A),
    ),
    DressUpAccessory(
      id: 'hat_top',
      emoji: '🎩',
      labelEs: 'Sombrero',
      labelEn: 'Top Hat',
      slot: AccessorySlot.hat,
      cardColor: Color(0xFFB39DDB),
    ),
    DressUpAccessory(
      id: 'hat_party',
      emoji: '🎓',
      labelEs: 'Birrete',
      labelEn: 'Grad Cap',
      slot: AccessorySlot.hat,
      cardColor: Color(0xFF80CBC4),
    ),
    DressUpAccessory(
      id: 'hat_rainbow',
      emoji: '🌈',
      labelEs: 'Arco Iris',
      labelEn: 'Rainbow',
      slot: AccessorySlot.hat,
      cardColor: Color(0xFFFFAB91),
    ),
    // ── Face ─────────────────────────────────────────────────
    DressUpAccessory(
      id: 'face_sunglasses',
      emoji: '🕶️',
      labelEs: 'Gafas',
      labelEn: 'Sunglasses',
      slot: AccessorySlot.face,
      cardColor: Color(0xFFA5D6A7),
    ),
    DressUpAccessory(
      id: 'face_clown',
      emoji: '🥸',
      labelEs: 'Disfraz',
      labelEn: 'Disguise',
      slot: AccessorySlot.face,
      cardColor: Color(0xFFFFCC80),
    ),
    // ── Neck ─────────────────────────────────────────────────
    DressUpAccessory(
      id: 'neck_bow',
      emoji: '🎀',
      labelEs: 'Moño',
      labelEn: 'Bow',
      slot: AccessorySlot.neck,
      cardColor: Color(0xFFF48FB1),
    ),
    DressUpAccessory(
      id: 'neck_scarf',
      emoji: '🧣',
      labelEs: 'Bufanda',
      labelEn: 'Scarf',
      slot: AccessorySlot.neck,
      cardColor: Color(0xFFB3E5FC),
    ),
    // ── Body ─────────────────────────────────────────────────
    DressUpAccessory(
      id: 'body_cape',
      emoji: '🦸',
      labelEs: 'Capa',
      labelEn: 'Cape',
      slot: AccessorySlot.body,
      cardColor: Color(0xFFEF9A9A),
    ),
    DressUpAccessory(
      id: 'body_heart',
      emoji: '❤️',
      labelEs: 'Corazón',
      labelEn: 'Heart',
      slot: AccessorySlot.body,
      cardColor: Color(0xFFFFCDD2),
    ),
    // ── Back ─────────────────────────────────────────────────
    DressUpAccessory(
      id: 'back_pack',
      emoji: '🎒',
      labelEs: 'Mochila',
      labelEn: 'Backpack',
      slot: AccessorySlot.back,
      cardColor: Color(0xFFCE93D8),
    ),
    DressUpAccessory(
      id: 'back_star',
      emoji: '⭐',
      labelEs: 'Estrella',
      labelEn: 'Star',
      slot: AccessorySlot.back,
      cardColor: Color(0xFFFFF59D),
    ),
  ];
}
