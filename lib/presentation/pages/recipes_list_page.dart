import 'package:flutter/material.dart';

import '../../data/models/recipe_models.dart';
import '../../features/bootstrap/app_view_model.dart';
import '../widgets/network_recipe_image.dart';
import 'recipe_detail_page.dart';

/// 对应 Android RecipesListActivity + activity_list.xml + RecipesAdapter：
/// 读取 Database.json 按 recipe.c == 分类 id 过滤，横向单行列表展示。
/// item（home_recipes_list_tem.xml）：114x118 卡片、图片铺满、
/// 底部半透明灰条（#503C3C3C 底圆角 10dp）+ 白色单行标题。
class RecipesListPage extends StatelessWidget {
  static const _homeHeaderGreen = Color(0xFF9FDE6E);

  const RecipesListPage({
    super.key,
    required this.categoryId,
    required this.title,
    required this.viewModel,
  });

  /// 分类 id（原版 Intent extra "p"）。
  final String categoryId;

  /// 分类标题（原版 Intent extra "title"）。
  final String title;

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final recipes =
        viewModel.recipesForCategory(int.tryParse(categoryId) ?? -1);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: _homeHeaderGreen,
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) => SizedBox(
          // 横向 ListView 会占满父级高度；保留原有 5dp 顶部间距后，
          // 为 item 留出精确的 253dp 高度。
          height: 258,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.only(top: 5), // activity_list 内 marginTop 5dp
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _RecipeListItem(
                recipe: recipe,
                viewModel: viewModel,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecipeListItem extends StatelessWidget {
  const _RecipeListItem({required this.recipe, required this.viewModel});

  final Recipe recipe;
  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 114,
        height: 253,
        margin:
            const EdgeInsets.symmetric(horizontal: 4), // 原 item 左右 margin 4dp
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5), // cardCornerRadius 5dp
          boxShadow: [
            // cardElevation 4dp
            BoxShadow(
              color: Colors.black.withAlpha(64),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkRecipeImage(
                url: recipe.imageUrls.isEmpty ? '' : recipe.imageUrls.first),
            // 底部半透明灰条 + 白色标题（shape_001010_gray：#503C3C3C，底圆角 10dp）
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0x503C3C3C),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(BuildContext context) async {
    // 原版：RecipeDetailsActivity（详情）——鸿蒙侧复用现有 RecipeDetailPage。
    await viewModel.recordRecipeOpened(recipe.id);
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) =>
          RecipeDetailPage(recipeId: recipe.id, viewModel: viewModel),
    ));
  }
}
