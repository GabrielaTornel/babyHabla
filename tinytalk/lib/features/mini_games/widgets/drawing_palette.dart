import 'package:flutter/material.dart';

import '../models/free_draw.dart';

/// Color, brush and size picker shared by the free-draw and coloring-book
/// canvases. Lays out as a horizontal bottom bar in portrait, or a narrow
/// scrollable side panel in landscape (pass [isVertical]: true).
class DrawingPalette extends StatelessWidget {
  const DrawingPalette({
    required this.isVertical,
    required this.selectedColor,
    required this.onColorPicked,
    required this.selectedBrush,
    required this.onBrushPicked,
    required this.selectedSize,
    required this.onSizePicked,
    required this.hint,
    required this.onTogglePanel,
    super.key,
  });

  final bool isVertical;
  final Color selectedColor;
  final ValueChanged<Color> onColorPicked;
  final BrushType selectedBrush;
  final ValueChanged<BrushType> onBrushPicked;
  final BrushSize selectedSize;
  final ValueChanged<BrushSize> onSizePicked;
  final String hint;
  final VoidCallback onTogglePanel;

  static const _brushIcons = {
    BrushType.pencil: Icons.edit_outlined,
    BrushType.brush: Icons.brush_rounded,
    BrushType.watercolor: Icons.water_drop_rounded,
    BrushType.marker: Icons.border_color_rounded,
  };

  static const _sizeDiameters = {
    BrushSize.small: 10.0,
    BrushSize.medium: 16.0,
    BrushSize.large: 24.0,
  };

  @override
  Widget build(BuildContext context) {
    final colorDots = FreeDrawPalette.colors
        .map((color) => _ColorDot(
              color: color,
              isSelected: color == selectedColor,
              onTap: () => onColorPicked(color),
            ))
        .toList();
    final brushButtons = BrushType.values
        .map((brush) => _BrushIconButton(
              icon: _brushIcons[brush]!,
              isSelected: brush == selectedBrush,
              onTap: () => onBrushPicked(brush),
            ))
        .toList();
    final sizeDots = BrushSize.values
        .map((size) => _SizeDot(
              diameter: _sizeDiameters[size]!,
              isSelected: size == selectedSize,
              onTap: () => onSizePicked(size),
            ))
        .toList();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: colorDots,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: brushButtons,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: sizeDots,
        ),
      ],
    );

    final panel = Container(
      constraints: isVertical ? const BoxConstraints(maxWidth: 120) : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0FA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x333642C7), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7A7A9D),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              GestureDetector(
                onTap: onTogglePanel,
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF7A7A9D),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );

    if (!isVertical) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: panel,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 64, 12, 12),
      child: SingleChildScrollView(child: panel),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 40 : 32,
        height: isSelected ? 40 : 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF3642C7) : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrushIconButton extends StatelessWidget {
  const _BrushIconButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3642C7) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0x333642C7),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isSelected ? Colors.white : const Color(0xFF3642C7),
        ),
      ),
    );
  }
}

class _SizeDot extends StatelessWidget {
  const _SizeDot({
    required this.diameter,
    required this.isSelected,
    required this.onTap,
  });

  final double diameter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x223642C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: const BoxDecoration(
            color: Color(0xFF3642C7),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Small round button that reopens a collapsed [DrawingPalette], previewing
/// the currently selected color.
class PanelReopenButton extends StatelessWidget {
  const PanelReopenButton(
      {required this.color, required this.onTap, super.key});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.palette_rounded, color: Colors.white),
      ),
    );
  }
}

/// Frosted-glass icon button used in the top bar of drawing-style screens.
class GlassButton extends StatelessWidget {
  const GlassButton({required this.onTap, required this.child, super.key});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x333642C7), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(width: 24, height: 24, child: child),
      ),
    );
  }
}
