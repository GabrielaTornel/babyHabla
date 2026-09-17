import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_language.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/providers/app_language_providers.dart';
import '../../../shared/providers/progress_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider);
    final copy = ref.watch(appCopyProvider);
    final language = ref.watch(appLanguageControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(copy.parentSettings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            SectionHeader(
              title: copy.parentArea,
              subtitle: copy.parentSubtitle,
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: const EdgeInsets.all(18),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              ),
              leading: const Icon(Icons.verified_rounded),
              title: Text(copy.completedWords),
              subtitle:
                  Text(copy.learnedCount(progress.valueOrNull?.length ?? 0)),
            ),
            const SizedBox(height: 16),
            SegmentedButton<AppLanguage>(
              segments: const [
                ButtonSegment(
                  value: AppLanguage.spanish,
                  label: Text('Español'),
                ),
                ButtonSegment(
                  value: AppLanguage.english,
                  label: Text('English'),
                ),
              ],
              selected: {language ?? AppLanguage.spanish},
              onSelectionChanged: (selection) {
                ref
                    .read(appLanguageControllerProvider.notifier)
                    .selectLanguage(selection.first);
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(progressControllerProvider.notifier).reset();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(copy.resetProgress),
            ),
          ],
        ),
      ),
    );
  }
}
