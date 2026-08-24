import 'package:flutter/material.dart';

import '../../data/models/recipe_models.dart';
import '../../features/bootstrap/app_view_model.dart';
import 'empty_state.dart';
import 'recipe_card.dart';

class RecipeGrid extends StatelessWidget {
  const RecipeGrid({
    super.key,
    required this.recipes,
    required this.viewModel,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  final List<Recipe> recipes;
  final AppViewModel viewModel;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return EmptyState(message: emptyMessage, icon: emptyIcon);
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: .67,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) =>
          RecipeCard(recipe: recipes[index], viewModel: viewModel),
    );
  }
}
