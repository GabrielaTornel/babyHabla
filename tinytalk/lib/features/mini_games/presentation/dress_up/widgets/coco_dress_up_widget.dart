import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/playful_background.dart';
import '../../../models/dress_up_accessory.dart';
import '../../../providers/dress_up_provider.dart';

/// The main interactive character area.
/// Acts as a DragTarget — any [DressUpAccessory] dropped here
/// is equipped to its predefined slot on Coco.
class CocoDressUpWidget extends ConsumerStatefulWidget {
  const CocoDressUpWidget({super.key});

  @override
  ConsumerState<CocoDressUpWidget> createState() => _CocoDressUpWidgetState();
}

class _CocoDressUpWidgetState extends ConsumerState<CocoDressUpWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounce;
  bool _isDragOver = false;

  // ── Character size ────────────────────────────────────────
  // All anchor points are calibrated for this value.
  static const double _cocoSize = 220.0;

  // ── Slot anchor points ────────────────────────────────────
  // Offset(left, top) = top-left corner of the emoji bounding box,
  // relative to the BabyBear widget's own (0,0) origin.
  // Derived from painter geometry at size=220:
  //   ears peak y≈20, head-top y≈33, eyes y=99, nose y=119,
  //   belly-center y≈128, body-center y≈136.
  static const Map<AccessorySlot, Offset> _anchors = {
    AccessorySlot.hat:  Offset(84, -26),  // above ear peaks (y=20)
    AccessorySlot.face: Offset(83, 72),   // eye level (y=99)
    AccessorySlot.neck: Offset(91, 124),  // chin / neck (y=140)
    AccessorySlot.body: Offset(83, 145),  // torso center (y=168)
    AccessorySlot.back: Offset(164, 140), // right shoulder
  };

  // Emoji font-size per slot
  static const Map<AccessorySlot, double> _emojiFontSize = {
    AccessorySlot.hat:  52.0,
    AccessorySlot.face: 50.0,
    AccessorySlot.neck: 38.0,
    AccessorySlot.body: 50.0,
    AccessorySlot.back: 44.0,
  };

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.09), weight: 28),
      TweenSequenceItem(tween: Tween(begin: 1.09, end: 0.94), weight: 28),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.03), weight: 22),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.00), weight: 22),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _onDrop(DressUpAccessory accessory) {
    ref.read(dressUpProvider.notifier).equipAccessory(accessory);
    _bounceCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dressUpProvider);

    return DragTarget<DressUpAccessory>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        _onDrop(details.data);
      },
      builder: (_, __, ___) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          // Top padding leaves room for the hat (top anchor = -26)
          padding: const EdgeInsets.fromLTRB(20, 46, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: _isDragOver
                    ? const Color(0xFFFFD97A).withValues(alpha: 0.65)
                    : const Color(0x28000000),
                blurRadius: _isDragOver ? 30 : 18,
                spreadRadius: _isDragOver ? 8 : 0,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: _isDragOver
                  ? const Color(0xFFFFD97A).withValues(alpha: 0.85)
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: AnimatedBuilder(
            animation: _bounce,
            builder: (_, child) =>
                Transform.scale(scale: _bounce.value, child: child),
            child: SizedBox(
              width: _cocoSize,
              height: _cocoSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Base character ──────────────────────────
                  const BabyBear(size: _cocoSize),

                  // ── Equipped accessories (layered) ──────────
                  ..._buildLayers(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildLayers(DressUpState state) {
    // Render order: hat last so it's always on top
    const renderOrder = [
      AccessorySlot.back,
      AccessorySlot.body,
      AccessorySlot.neck,
      AccessorySlot.face,
      AccessorySlot.hat,
    ];

    final layers = <Widget>[];
    for (final slot in renderOrder) {
      final id = state.equipped[slot];
      if (id == null) continue;
      final accessory = DressUpAccessory.all.where((a) => a.id == id).firstOrNull;
      if (accessory == null) continue;
      layers.add(
        Positioned(
          left: _anchors[slot]!.dx,
          top: _anchors[slot]!.dy,
          child: _PlacedAccessory(
            key: ValueKey('${slot.name}_$id'),
            emoji: accessory.emoji,
            fontSize: _emojiFontSize[slot] ?? 44.0,
            onTap: () => ref.read(dressUpProvider.notifier).removeSlot(slot),
          ),
        ),
      );
    }
    return layers;
  }
}

// ─────────────────────────────────────────────
// Placed accessory — entrance animation + tap to remove
// ─────────────────────────────────────────────

class _PlacedAccessory extends StatefulWidget {
  const _PlacedAccessory({
    required this.emoji,
    required this.fontSize,
    required this.onTap,
    super.key,
  });

  final String emoji;
  final double fontSize;
  final VoidCallback onTap;

  @override
  State<_PlacedAccessory> createState() => _PlacedAccessoryState();
}

class _PlacedAccessoryState extends State<_PlacedAccessory>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 38),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.88), weight: 32),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut),
    );
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: Text(
            widget.emoji,
            style: TextStyle(fontSize: widget.fontSize),
          ),
        ),
      ),
    );
  }
}
