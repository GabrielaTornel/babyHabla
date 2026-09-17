import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';

class PrimaryBouncyButton extends StatelessWidget {
  const PrimaryBouncyButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.play_arrow_rounded, size: 30),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.yellowPastel,
          foregroundColor: const Color(0xFF7A4A00),
          side: const BorderSide(color: Colors.white, width: 3),
        ),
      ),
    );
  }
}
