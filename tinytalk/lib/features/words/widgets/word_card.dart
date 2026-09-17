import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/localization/app_language.dart';
import '../../../core/widgets/app_image.dart';
import '../../../shared/models/learning_word.dart';
import '../../../shared/models/learning_word_extensions.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    required this.word,
    required this.language,
    required this.isCompleted,
    required this.onTap,
    super.key,
  });

  final LearningWord word;
  final AppLanguage? language;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final imageSize = math
                        .min(constraints.maxWidth, constraints.maxHeight)
                        .clamp(96.0, 156.0);

                    return Center(
                      child: AppImage(
                        path: word.image,
                        size: imageSize,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      word.localizedTitle(language ?? AppLanguage.spanish),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF1E6F3C),
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_rounded),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
