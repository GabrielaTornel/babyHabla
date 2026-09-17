import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/localization/app_language.dart';
import '../../../../../shared/providers/app_language_providers.dart';
import '../../../models/dress_up_accessory.dart';

/// A draggable card for one accessory.
/// Shows a glow + gold border when [isEquipped].
class AccessoryCardWidget extends ConsumerStatefulWidget {
  const AccessoryCardWidget({
    super.key,
    required this.accessory,
    required this.isEquipped,
  });

  final DressUpAccessory accessory;
  final bool isEquipped;

  @override
  ConsumerState<AccessoryCardWidget> createState() =>
      _AccessoryCardWidgetState();
}

class _AccessoryCardWidgetState extends ConsumerState<AccessoryCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _equipCtrl;

  @override
  void initState() {
    super.initState();
    _equipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.isEquipped ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(AccessoryCardWidget old) {
    super.didUpdateWidget(old);
    if (widget.isEquipped != old.isEquipped) {
      widget.isEquipped ? _equipCtrl.forward() : _equipCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _equipCtrl.dispose();
    super.dispose();
  }

  Widget _buildVisual({double scale = 1.0}) {
    final language =
        ref.read(appLanguageControllerProvider).valueOrNull ??
            AppLanguage.spanish;
    final label = language == AppLanguage.spanish
        ? widget.accessory.labelEs
        : widget.accessory.labelEn;

    return AnimatedBuilder(
      animation: _equipCtrl,
      builder: (_, __) {
        final t = _equipCtrl.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 74,
            height: 82,
            decoration: BoxDecoration(
              color: widget.accessory.cardColor.withValues(alpha: 0.85 + 0.15 * t),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Color.lerp(
                  Colors.transparent,
                  const Color(0xFFFFD700),
                  t,
                )!,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accessory.cardColor
                      .withValues(alpha: 0.35 + 0.40 * t),
                  blurRadius: 8 + 14 * t,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.accessory.emoji,
                  style: const TextStyle(fontSize: 34),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A3E66),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (t > 0.5)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Opacity(
                      opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
                      child: const Text('✓',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4A3E66),
                          )),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<DressUpAccessory>(
      data: widget.accessory,
      feedback: Material(
        color: Colors.transparent,
        child: _buildVisual(scale: 1.14),
      ),
      childWhenDragging: Opacity(
        opacity: 0.30,
        child: _buildVisual(),
      ),
      child: _buildVisual(),
    );
  }
}
