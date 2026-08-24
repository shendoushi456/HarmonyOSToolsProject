class RecipeCategory {
  const RecipeCategory(
      {required this.id, required this.title, required this.imageUrl});

  final int id;
  final String title;
  final String imageUrl;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.imageUrls,
    required this.ingredientsHtml,
    required this.directionsHtml,
    required this.ratingTotal,
    required this.ratingCount,
  });

  final int id;
  final int categoryId;
  final String title;
  final List<String> imageUrls;
  final String ingredientsHtml;
  final String directionsHtml;
  final int ratingTotal;
  final int ratingCount;

  double? get rating => ratingCount == 0 ? null : ratingTotal / ratingCount;
}

class RecipeCatalog {
  const RecipeCatalog({required this.categories, required this.recipes});

  final List<RecipeCategory> categories;
  final List<Recipe> recipes;

  Recipe? recipeById(int id) {
    for (final recipe in recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }
}
