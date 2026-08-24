import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/recipe_models.dart';

abstract class RecipeCatalogRepository {
  Future<RecipeCatalog> loadCatalog();
}

class AssetRecipeCatalogRepository implements RecipeCatalogRepository {
  const AssetRecipeCatalogRepository();

  static const _assetPath = 'assets/recipes/database.json';

  @override
  Future<RecipeCatalog> loadCatalog() async {
    final source = await rootBundle.loadString(_assetPath);
    final root = jsonDecode(source) as Map<String, dynamic>;
    final categories =
        (root['Categories'] as List<dynamic>).asMap().entries.map((entry) {
      final item = entry.value as Map<String, dynamic>;
      return RecipeCategory(
        id: entry.key + 1,
        title: item['t'] as String? ?? '',
        imageUrl: item['i'] as String? ?? '',
      );
    }).toList(growable: false);
    final recipes = (root['Recipes'] as List<dynamic>).map((dynamic value) {
      final item = value as Map<String, dynamic>;
      final images = (item['i'] as String? ?? '')
          .split(',')
          .where((url) => url.isNotEmpty)
          .toList(growable: false);
      return Recipe(
        id: item['id'] as int,
        categoryId: item['c'] as int,
        title: item['t'] as String? ?? '',
        imageUrls: images,
        ingredientsHtml: item['ing'] as String? ?? '',
        directionsHtml: item['dir'] as String? ?? '',
        ratingTotal: item['r'] as int? ?? 0,
        ratingCount: item['nr'] as int? ?? 0,
      );
    }).toList(growable: false);
    return RecipeCatalog(categories: categories, recipes: recipes);
  }
}
