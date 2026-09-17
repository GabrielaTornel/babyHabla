import 'package:flutter/material.dart';

import '../../../../../app/constants/category_data.dart';

class DropTargetWidget extends StatelessWidget {
  const DropTargetWidget({
    required this.category,
    required this.label,
    required this.onAccepted,
    super.key,
  });

  final LearningCategoryData category;
  final String label;
  final VoidCallback onAccepted;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data == category.id,
      onAcceptWithDetails: (details) {
        if (details.data == category.id) onAccepted();
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final isRejecting = rejectedData.isNotEmpty;

        return AnimatedScale(
          scale: isHovering ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: category.colors,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isHovering
                    ? Colors.white
                    : isRejecting
                        ? Colors.red.shade300
                        : Colors.white.withValues(alpha: 0.5),
                width: isHovering ? 4 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: category.colors.first.withValues(
                    alpha: isHovering ? 0.7 : 0.4,
                  ),
                  blurRadius: isHovering ? 30 : 14,
                  spreadRadius: isHovering ? 6 : 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(category.icon, color: Colors.white, size: 42),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
