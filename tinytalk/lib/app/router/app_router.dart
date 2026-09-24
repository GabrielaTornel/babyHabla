import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/categories_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mini_games/presentation/animal_finder/animal_finder_screen.dart';
import '../../features/mini_games/presentation/drag_drop/drag_drop_screen.dart';
import '../../features/mini_games/presentation/feed_animal/feed_animal_screen.dart';
import '../../features/mini_games/presentation/mini_games_screen.dart';
import '../../features/mini_games/presentation/dress_up/dress_up_screen.dart';
import '../../features/mini_games/presentation/follow_star/follow_star_screen.dart';
import '../../features/mini_games/presentation/free_draw/free_draw_screen.dart';
import '../../features/mini_games/presentation/coloring_book/coloring_canvas_screen.dart';
import '../../features/mini_games/presentation/coloring_book/coloring_gallery_screen.dart';
import '../../features/mini_games/presentation/trace_path/trace_path_screen.dart';
import '../../features/mini_games/presentation/touch_color/touch_color_screen.dart';
import '../../features/mini_games/presentation/pop_bubbles/pop_bubbles_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/words/presentation/word_detail_screen.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.category,
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        return CategoriesScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: AppRoutes.word,
      builder: (context, state) {
        final wordId = state.pathParameters['wordId']!;
        return WordDetailScreen(wordId: wordId);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.miniGames,
      builder: (context, state) => const MiniGamesScreen(),
    ),
    GoRoute(
      path: AppRoutes.miniGame,
      builder: (context, state) {
        final gameId = state.pathParameters['gameId']!;
        return switch (gameId) {
          'pop_bubbles' => const PopBubblesScreen(),
          'drag_drop' => const DragDropScreen(),
          'animal_finder' => const AnimalFinderScreen(),
          'feed_animal' => const FeedAnimalScreen(),
          'touch_color' => const TouchColorScreen(),
          'follow_star' => const FollowStarScreen(),
          'dress_up' => const DressUpScreen(),
          'trace_path' => const TracePathScreen(),
          'free_draw' => const FreeDrawScreen(),
          'coloring_book' => const ColoringGalleryScreen(),
          _ => const MiniGamesScreen(),
        };
      },
    ),
    GoRoute(
      path: AppRoutes.coloringPage,
      builder: (context, state) {
        final pageId = state.pathParameters['pageId']!;
        return ColoringCanvasScreen(pageId: pageId);
      },
    ),
  ],
);
