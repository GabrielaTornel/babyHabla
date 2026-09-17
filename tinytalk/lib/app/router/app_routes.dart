class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const category = '/category/:categoryId';
  static const word = '/word/:wordId';
  static const settings = '/settings';
  static const miniGames = '/mini-games';
  static const miniGame = '/mini-games/:gameId';

  static String categoryPath(String categoryId) => '/category/$categoryId';
  static String wordPath(String wordId) => '/word/$wordId';
  static String miniGamePath(String gameId) => '/mini-games/$gameId';
}
