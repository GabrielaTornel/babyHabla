import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/category_data.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/playful_background.dart';
import '../../../shared/providers/app_language_providers.dart';
import '../widgets/category_card.dart';
import '../widgets/mini_games_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = ref.watch(appCopyProvider);

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(child: BrandLogo(width: 180)),
                      IconButton.filled(
                        tooltip: copy.parentSettings,
                        onPressed: () => context.push(AppRoutes.settings),
                        icon: const Icon(Icons.settings_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    copy.categoriesPrompt,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF2F275A),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
              // ── Mini Juegos banner ──────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                sliver: SliverToBoxAdapter(
                  child: MiniGamesBanner(
                    onTap: () => context.push(AppRoutes.miniGames),
                  ),
                ),
              ),

              // ── Categories grid ─────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverGrid.builder(
                  itemCount: learningCategories.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final category = learningCategories[index];

                    return CategoryCard(
                      category: category,
                      title: copy.categoryTitle(category.id),
                      onTap: () => context.push(
                        AppRoutes.categoryPath(category.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
