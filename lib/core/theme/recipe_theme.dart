import 'package:flutter/material.dart';

abstract class RecipeColors {
  static const primary = Color(0xFFE36864);
  static const accent = Color(0xFF5FE3DF);
  static const text = Color(0xFF263238);
  static const mutedText = Color(0xFF90A4AE);
  static const stars = Color(0xFFFF9A00);
}

ThemeData buildRecipeTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: RecipeColors.primary,
    primary: RecipeColors.primary,
    secondary: RecipeColors.accent,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Didact',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: RecipeColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
