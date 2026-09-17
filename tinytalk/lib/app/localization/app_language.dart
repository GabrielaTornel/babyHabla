import '../constants/mini_game_data.dart';

enum AppLanguage {
  spanish('es', 'Espa\u00f1ol', 'es-US'),
  english('en', 'English', 'en-US');

  const AppLanguage(this.code, this.label, this.ttsCode);

  final String code;
  final String label;
  final String ttsCode;

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.spanish,
    );
  }
}

class AppCopy {
  const AppCopy(this.language);

  final AppLanguage language;

  bool get isSpanish => language == AppLanguage.spanish;

  String get appName => 'BabyHabla';
  String get chooseLanguage =>
      isSpanish ? 'Elige tu idioma' : 'Choose language';
  String get languageSubtitle =>
      isSpanish ? 'Escoge como vamos a jugar.' : 'Pick how we will play.';
  String get startLearning => isSpanish ? 'Comenzar' : 'Start';
  String get firstWords => isSpanish ? 'Primeras palabras' : 'First words';
  String get categoriesPrompt =>
      isSpanish ? '¿Qué quieres aprender?' : 'What do you want to learn?';
  String get homeSubtitle => isSpanish
      ? 'Toca una tarjeta grande y aprendan juntos.'
      : 'Tap a big card and learn together.';
  String get parentSettings =>
      isSpanish ? 'Ajustes para padres' : 'Parent settings';
  String get parentArea => isSpanish ? 'Zona de padres' : 'Parent area';
  String get parentSubtitle => isSpanish
      ? 'Controles simples para adultos.'
      : 'Simple controls for grown-ups.';
  String get completedWords =>
      isSpanish ? 'Palabras completadas' : 'Words completed';
  String learnedCount(int count) =>
      isSpanish ? '$count aprendidas' : '$count learned';
  String get resetProgress =>
      isSpanish ? 'Reiniciar progreso' : 'Reset progress';
  String get continueLabel => isSpanish ? 'Continuar' : 'Continue';
  String get miniGames => isSpanish ? 'Mini Juegos' : 'Mini Games';
  String get miniGamesSubtitle => isSpanish ? '¡Juega y aprende!' : 'Play and learn!';
  String get popBubbles => isSpanish ? 'Revienta Burbujas' : 'Pop Bubbles';
  String get tapBubbles => isSpanish ? '¡Toca las burbujas!' : 'Tap the bubbles!';
  String get congratulations => isSpanish ? '¡Felicidades!' : 'Well done!';
  String get timeUp => isSpanish ? '¡Se acabó el tiempo!' : "Time's up!";
  String get playAgain => isSpanish ? 'Jugar de nuevo' : 'Play again';
  String bubblesPopped(int n) =>
      isSpanish ? 'Reventaste $n burbujas 🎉' : 'You popped $n bubbles 🎉';
  String get goBack => isSpanish ? '← Regresar' : '← Go back';
  String get whereDoesItBelong =>
      isSpanish ? '¿Dónde pertenece?' : 'Where does it belong?';
  String get greatJob => isSpanish ? '¡Muy bien! 🎉' : 'Great job! 🎉';
  String whereIsThe(String animalName) =>
      isSpanish ? '¿Dónde está el $animalName?' : 'Where is the $animalName?';
  String get tapTheAnimal =>
      isSpanish ? '¡Toca el animal correcto!' : 'Tap the right animal!';
  String feedPrompt(String food, String animal) =>
      isSpanish ? 'Dale $food al $animal' : 'Give $food to the $animal';
  String get dragFoodInstruction =>
      isSpanish ? 'Arrastra la comida al animal' : 'Drag the food to the animal';
  String get dragInstruction =>
      isSpanish ? 'Arrastra al lugar correcto' : 'Drag to the right place';
  String touchColorPrompt(String colorName) =>
      isSpanish ? '¡Toca el color $colorName!' : 'Touch the color $colorName!';
  String get tapTheColor =>
      isSpanish ? '¡Toca el color correcto!' : 'Tap the right color!';
  String get followTheStar =>
      isSpanish ? '¡Sigue la estrella! ✨' : 'Follow the star! ✨';
  String get dressUpPrompt =>
      isSpanish ? '¡Arrastra accesorios a Coco!' : 'Drag accessories onto Coco!';
  String get dressUpCelebration =>
      isSpanish ? '¡Qué bonito quedó Coco! 🎉' : 'Coco looks amazing! 🎉';
  String challengeOf(int current, int total) =>
      isSpanish ? '$current / $total' : '$current / $total';
  String correctOf(int correct, int total) =>
      isSpanish ? 'Acertaste $correct de $total 🎉' : 'You got $correct of $total 🎉';
  String miniGameTitle(MiniGameData game) =>
      isSpanish ? game.titleEs : game.titleEn;
  String get play => isSpanish ? 'Escuchar' : 'Play';
  String get record => isSpanish ? 'Grabar' : 'Record';
  String get playback => isSpanish ? 'Reproducir' : 'Playback';
  String get wordNotFound =>
      isSpanish ? 'Palabra no encontrada' : 'Word not found';
  String couldNotLoadWords(Object error) => isSpanish
      ? 'No se pudieron cargar las palabras: $error'
      : 'Could not load words: $error';
  String couldNotLoadWord(Object error) => isSpanish
      ? 'No se pudo cargar la palabra: $error'
      : 'Could not load word: $error';

  String categoryTitle(String categoryId) {
    return switch (categoryId) {
      'animals' => isSpanish ? 'Animales' : 'Animals',
      'colors' => isSpanish ? 'Colores' : 'Colors',
      'fruits' => isSpanish ? 'Frutas' : 'Fruits',
      'family' => isSpanish ? 'Familia' : 'Family',
      'toys' => isSpanish ? 'Juguetes' : 'Toys',
      'food' => isSpanish ? 'Comidas' : 'Food',
      'actions' => isSpanish ? 'Acciones' : 'Actions',
      'body' => isSpanish ? 'Cuerpo' : 'Body',
      'transport' => isSpanish ? 'Transporte' : 'Transport',
      _ => categoryId,
    };
  }
}
