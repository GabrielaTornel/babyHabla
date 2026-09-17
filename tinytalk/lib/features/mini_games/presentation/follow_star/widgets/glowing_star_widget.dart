import 'package:flutter/material.dart';

/// A pulsing, glowing star with layered radial gradients.
/// Self-contained — owns its own AnimationController.
class GlowingStarWidget extends StatefulWidget {
  const GlowingStarWidget({super.key, this.size = 70.0});

  final double size;

  @override
  State<GlowingStarWidget> createState() => _GlowingStarWidgetState();
}

class _GlowingStarWidgetState extends State<GlowingStarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulse = Tween(begin: 0.82, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final scale = _pulse.value;
        final totalSize = s * 1.8;

        return SizedBox(
          width: totalSize,
          height: totalSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer aurora glow
              Container(
                width: s * scale * 1.6,
                height: s * scale * 1.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFB39DDB)
                          .withValues(alpha: 0.25 * scale),
                      const Color(0xFF7E57C2)
                          .withValues(alpha: 0.12 * scale),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Mid golden glow
              Container(
                width: s * scale * 1.1,
                height: s * scale * 1.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700)
                          .withValues(alpha: 0.55 * scale),
                      const Color(0xFFFF8F00)
                          .withValues(alpha: 0.25 * scale),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700)
                          .withValues(alpha: 0.60 * scale),
                      blurRadius: 22 * scale,
                      spreadRadius: 4 * scale,
                    ),
                  ],
                ),
              ),

              // Star emoji — scales with pulse
              Text(
                '⭐',
                style: TextStyle(fontSize: s * 0.68 * scale),
              ),
            ],
          ),
        );
      },
    );
  }
}
