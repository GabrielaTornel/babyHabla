import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/widgets/playful_background.dart';
import '../../../core/widgets/primary_bouncy_button.dart';
import '../../../shared/providers/onboarding_providers.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: PlayfulBackground(
        backgroundAsset: 'assets/images/layouts/backgroundAnimals.png',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  'assets/images/layouts/logo-sinfondo.png',
                  width: 300,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text(
                  'Aprende, juega y habla',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF3642C7),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                PrimaryBouncyButton(
                  label: 'Comenzar',
                  onPressed: () {
                    ref
                        .read(welcomeControllerProvider.notifier)
                        .completeWelcome();
                  },
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
