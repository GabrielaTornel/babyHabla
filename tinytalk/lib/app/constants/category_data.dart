import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LearningCategoryData {
  const LearningCategoryData({
    required this.id,
    required this.title,
    required this.icon,
    required this.colors,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<Color> colors;
}

const learningCategories = <LearningCategoryData>[
  LearningCategoryData(
    id: 'animals',
    title: 'Animals',
    icon: Icons.pets_rounded,
    colors: [Color(0xFFFFC928), Color(0xFFFF7A1A)],
  ),
  LearningCategoryData(
    id: 'colors',
    title: 'Colors',
    icon: Icons.palette_rounded,
    colors: [Color(0xFF8F62FF), Color(0xFFCE7BFF)],
  ),
  LearningCategoryData(
    id: 'fruits',
    title: 'Fruits',
    icon: Icons.eco_rounded,
    colors: [Color(0xFFA8F044), Color(0xFF49C934)],
  ),
  LearningCategoryData(
    id: 'family',
    title: 'Family',
    icon: Icons.favorite_rounded,
    colors: [AppColors.roseSoft, AppColors.roseMauve],
  ),
  LearningCategoryData(
    id: 'toys',
    title: 'Toys',
    icon: Icons.toys_rounded,
    colors: [Color(0xFF5CD6FF), Color(0xFF229CEB)],
  ),
  LearningCategoryData(
    id: 'food',
    title: 'Food',
    icon: Icons.restaurant_rounded,
    colors: [Color(0xFFFFD96C), Color(0xFFFFA51F)],
  ),
  LearningCategoryData(
    id: 'actions',
    title: 'Actions',
    icon: Icons.directions_run_rounded,
    colors: [Color(0xFF52E0BE), Color(0xFF13B995)],
  ),
  LearningCategoryData(
    id: 'body',
    title: 'Body',
    icon: Icons.accessibility_new_rounded,
    colors: [Color(0xFFFF8A65), Color(0xFFE64A19)],
  ),
  LearningCategoryData(
    id: 'transport',
    title: 'Transport',
    icon: Icons.directions_car_rounded,
    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
  ),
];
