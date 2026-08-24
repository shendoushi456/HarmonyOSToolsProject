import 'package:flutter/material.dart';

import '../../core/theme/recipe_theme.dart';
import '../../data/models/recipe_models.dart';
import '../pages/recipe_detail_page.dart';
import '../../features/bootstrap/app_view_model.dart';
import 'network_recipe_image.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.viewModel,
  });

  final Recipe recipe;
  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final isFavorite = viewModel.isFavorite(recipe.id);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkRecipeImage(
                      url: recipe.imageUrls.isEmpty
                          ? ''
                          : recipe.imageUrls.first),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: IconButton.filledTonal(
                      tooltip: isFavorite ? '取消收藏' : '收藏',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(235),
                        foregroundColor: RecipeColors.primary,
                      ),
                      onPressed: () async {
                        final added = !isFavorite;
                        await viewModel.toggleFavorite(recipe.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(added ? '添加到收藏夹' : '已从收藏夹中删除')),
                        );
                      },
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 6, 5, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Rating(value: recipe.rating),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: RecipeColors.text, fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(BuildContext context) async {
    await viewModel.recordRecipeOpened(recipe.id);
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) =>
          RecipeDetailPage(recipeId: recipe.id, viewModel: viewModel),
    ));
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.value});
  final double? value;

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox(height: 18);
    final fullStars = value!.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < fullStars ? Icons.star : Icons.star_border,
          color: RecipeColors.stars,
          size: 17,
        ),
      ),
    );
  }
}
