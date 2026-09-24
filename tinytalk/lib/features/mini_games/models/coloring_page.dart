/// A black-and-white line-art drawing the child can color over.
class ColoringPage {
  const ColoringPage({
    required this.id,
    required this.titleEs,
    required this.titleEn,
    required this.assetPath,
  });

  final String id;
  final String titleEs;
  final String titleEn;
  final String assetPath;
}

const coloringPages = <ColoringPage>[
  ColoringPage(
    id: 'olaf',
    titleEs: 'Olaf',
    titleEn: 'Olaf',
    assetPath: 'assets/images/coloring/olaf.png',
  ),
  ColoringPage(
    id: 'frozen_elsa',
    titleEs: 'Elsa',
    titleEn: 'Elsa',
    assetPath: 'assets/images/coloring/frozen.webp',
  ),
];
