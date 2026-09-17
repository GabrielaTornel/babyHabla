import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/intro/presentation/koko_intro_screen.dart';
import '../features/language/presentation/language_selection_screen.dart';
import '../features/welcome/presentation/welcome_screen.dart';
import '../shared/providers/app_language_providers.dart';
import '../shared/providers/onboarding_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class TinyTalkApp extends ConsumerWidget {
  const TinyTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(appLanguageControllerProvider);
    final welcomeState = ref.watch(welcomeControllerProvider);
    final kokoIntroState = ref.watch(kokoIntroControllerProvider);

    if (languageState.isLoading ||
        welcomeState.isLoading ||
        kokoIntroState.isLoading) {
      return MaterialApp(
        title: 'BabyHabla',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Step 1: Welcome
    if (welcomeState.valueOrNull != true) {
      return MaterialApp(
        title: 'BabyHabla',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const WelcomeScreen(),
      );
    }

    // Step 2: Language selection
    if (languageState.valueOrNull == null) {
      return MaterialApp(
        title: 'BabyHabla',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const LanguageSelectionScreen(),
      );
    }

    // Step 3: Koko intro (shown once after first language selection)
    if (kokoIntroState.valueOrNull != true) {
      return MaterialApp(
        title: 'BabyHabla',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const KokoIntroScreen(),
      );
    }

    // Step 4: Main app
    return MaterialApp.router(
      title: 'BabyHabla',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
