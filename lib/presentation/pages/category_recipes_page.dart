import 'package:flutter/material.dart';

import '../../data/models/recipe_models.dart';
import '../../features/bootstrap/app_view_model.dart';
import '../widgets/recipe_grid.dart';

class CategoryRecipesPage extends StatelessWidget {
  const CategoryRecipesPage(
      {super.key, required this.category, required this.viewModel});
  final RecipeCategory category;
  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(category.title)),
        body: AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) => RecipeGrid(
            recipes: viewModel.recipesForCategory(category.id),
            viewModel: viewModel,
            emptyMessage: '暂无数据',
            emptyIcon: Icons.restaurant_menu,
          ),
        ),
      );
}
