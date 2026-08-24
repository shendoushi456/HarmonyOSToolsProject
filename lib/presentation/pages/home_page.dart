import 'package:flutter/material.dart';

import '../../core/theme/recipe_theme.dart';
import '../../features/bootstrap/app_view_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/network_recipe_image.dart';
import '../widgets/recipe_grid.dart';
import 'category_recipes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.viewModel});
  final AppViewModel viewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final catalog = widget.viewModel.catalog;
    if (catalog == null) return const SizedBox.shrink();
    const titles = ['首页', '食谱', '最近浏览', '收藏'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) => IndexedStack(
          index: _currentIndex,
          children: [
            _CategoriesPage(viewModel: widget.viewModel),
            RecipeGrid(
              recipes: widget.viewModel.allRecipes,
              viewModel: widget.viewModel,
              emptyMessage: '暂无食谱',
              emptyIcon: Icons.menu_book_outlined,
            ),
            RecipeGrid(
              recipes: widget.viewModel.recentRecipes,
              viewModel: widget.viewModel,
              emptyMessage: '还没有最近浏览的食谱',
              emptyIcon: Icons.history,
            ),
            RecipeGrid(
              recipes: widget.viewModel.favoriteRecipes,
              viewModel: widget.viewModel,
              emptyMessage: '暂无收藏食谱',
              emptyIcon: Icons.favorite_border,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: RecipeColors.primary.withAlpha(36),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '首页'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: '食谱'),
          NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: '最近'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: '收藏'),
        ],
      ),
    );
  }
}

class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage({required this.viewModel});
  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final categories = viewModel.catalog?.categories ?? const [];
    if (categories.isEmpty) {
      return const EmptyState(message: '暂无数据', icon: Icons.restaurant_menu);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) =>
                  CategoryRecipesPage(category: category, viewModel: viewModel),
            )),
            child: SizedBox(
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkRecipeImage(url: category.imageUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        category.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
