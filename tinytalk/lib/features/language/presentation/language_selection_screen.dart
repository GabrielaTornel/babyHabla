import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/localization/app_language.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/playful_background.dart';
import '../../../shared/providers/app_language_providers.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = ref.watch(appCopyProvider);

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 36),
                Text(
                  copy.chooseLanguage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.darkPurple,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 36),
                _LanguageButton(
                  label: 'Español',
                  flagAsset: 'assets/images/layouts/SPANISH.png',
                  colors: const [Color(0xFFFFE066), Color(0xFFFFB020)],
                  onTap: () => ref
                      .read(appLanguageControllerProvider.notifier)
                      .selectLanguage(AppLanguage.spanish),
                ),
                const SizedBox(height: 20),
                _LanguageButton(
                  label: 'English',
                  flagAsset: 'assets/images/layouts/ENGLISH.png',
                  colors: const [Color(0xFFB9F1FF), Color(0xFF6DC8F5)],
                  onTap: () => ref
                      .read(appLanguageControllerProvider.notifier)
                      .selectLanguage(AppLanguage.english),
                ),
                const Spacer(),
                _BearWithBubble(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.flagAsset,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final String flagAsset;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppConstants.toddlerTouchTarget + 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 0,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: ClipOval(
                  child: Image.asset(
                    flagAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkPurple,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFFFFB000),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BearWithBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset(
          'assets/images/layouts/oso-sinfondo.png',
          height: 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(bottom: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD6E7), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            '¡Hola!\nHello!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF3642C7),
              fontWeight: FontWeight.w900,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
