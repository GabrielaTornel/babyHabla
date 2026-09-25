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
  ColoringPage(
    id: 'frozen_elsa_2',
    titleEs: 'Elsa 2',
    titleEn: 'Elsa 2',
    assetPath: 'assets/images/coloring/frozen2.jpg',
  ),
  ColoringPage(
    id: 'toy_story_alien',
    titleEs: 'Marciano',
    titleEn: 'Alien',
    assetPath: 'assets/images/coloring/toy_story_alien.webp',
  ),
  ColoringPage(
    id: 'bo_peep',
    titleEs: 'Bo Peep',
    titleEn: 'Bo Peep',
    assetPath: 'assets/images/coloring/bo_peep.webp',
  ),
  ColoringPage(
    id: 'rex',
    titleEs: 'Rex',
    titleEn: 'Rex',
    assetPath: 'assets/images/coloring/rex.webp',
  ),
  ColoringPage(
    id: 'forky',
    titleEs: 'Forky',
    titleEn: 'Forky',
    assetPath: 'assets/images/coloring/forky.jpg',
  ),
  ColoringPage(
    id: 'buzz_pointing',
    titleEs: 'Buzz Lightyear',
    titleEn: 'Buzz Lightyear',
    assetPath: 'assets/images/coloring/buzz_pointing.jpg',
  ),
  ColoringPage(
    id: 'buzz_running',
    titleEs: 'Buzz Corriendo',
    titleEn: 'Buzz Running',
    assetPath: 'assets/images/coloring/buzz_running.webp',
  ),
  ColoringPage(
    id: 'potato_heads',
    titleEs: 'Sr. y Sra. Cara de Papa',
    titleEn: 'Mr. & Mrs. Potato Head',
    assetPath: 'assets/images/coloring/potato_heads.jpg',
  ),
  ColoringPage(
    id: 'moana_baby',
    titleEs: 'Moana Bebé',
    titleEn: 'Baby Moana',
    assetPath: 'assets/images/coloring/moana_baby.jpg',
  ),
  ColoringPage(
    id: 'moana_portrait',
    titleEs: 'Moana',
    titleEn: 'Moana',
    assetPath: 'assets/images/coloring/moana_portrait.png',
  ),
  ColoringPage(
    id: 'moana_beach',
    titleEs: 'Moana en la Playa',
    titleEn: 'Moana at the Beach',
    assetPath: 'assets/images/coloring/moana_beach.webp',
  ),
  ColoringPage(
    id: 'moana_with_pua',
    titleEs: 'Moana y Pua',
    titleEn: 'Moana and Pua',
    assetPath: 'assets/images/coloring/moana_with_pua.webp',
  ),
  ColoringPage(
    id: 'maui',
    titleEs: 'Maui',
    titleEn: 'Maui',
    assetPath: 'assets/images/coloring/maui.webp',
  ),
];
