import 'package:flutter/material.dart';

import '../../core/theme/recipe_theme.dart';
import '../../core/utils/html_text.dart';
import '../../data/models/recipe_models.dart';
import '../../features/bootstrap/app_view_model.dart';
import '../widgets/network_recipe_image.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage(
      {super.key, required this.recipeId, required this.viewModel});
  final int recipeId;
  final AppViewModel viewModel;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final _imageController = PageController();
  int _imageIndex = 0;

  Recipe? get recipe => widget.viewModel.catalog?.recipeById(widget.recipeId);

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = recipe;
    if (item == null) return const Scaffold(body: Center(child: Text('食谱不存在')));
    final images = item.imageUrls.isEmpty ? const [''] : item.imageUrls;
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyLarge!
        .copyWith(height: 1.65, color: RecipeColors.text);
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          AnimatedBuilder(
            animation: widget.viewModel,
            builder: (context, _) {
              final isFavorite = widget.viewModel.isFavorite(item.id);
              return IconButton(
                tooltip: isFavorite ? '取消收藏' : '收藏',
                onPressed: () async {
                  final added = !widget.viewModel.isFavorite(item.id);
                  await widget.viewModel.toggleFavorite(item.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(added ? '添加到收藏夹' : '已从收藏夹中删除')),
                  );
                },
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _imageController,
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => _imageIndex = index),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _openImages(context, images, _imageIndex),
                      child: NetworkRecipeImage(url: images[index]),
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: index == _imageIndex
                                  ? RecipeColors.primary
                                  : Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  _Stars(rating: item.rating),
                  const SizedBox(width: 8),
                  Text(
                      item.ratingCount == 0 ? '暂无评分' : '(${item.ratingCount})'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Card(
                color: const Color(0xFFEDFBFB),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: RecipeColors.primary,
                        indicatorColor: RecipeColors.primary,
                        tabs: [Tab(text: '成分'), Tab(text: '说明')],
                      ),
                      SizedBox(
                        height: _contentHeight(item),
                        child: TabBarView(
                          children: [
                            _RichRecipeText(
                                html: item.ingredientsHtml, style: bodyStyle),
                            _RichRecipeText(
                                html: item.directionsHtml, style: bodyStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _contentHeight(Recipe item) {
    final longest = item.ingredientsHtml.length > item.directionsHtml.length
        ? item.ingredientsHtml.length
        : item.directionsHtml.length;
    return (longest / 2.5).clamp(260, 700).toDouble();
  }

  void _openImages(
      BuildContext context, List<String> images, int initialIndex) {
    showDialog<void>(
      context: context,
      builder: (_) => _ImageViewer(images: images, initialIndex: initialIndex),
    );
  }
}

class _RichRecipeText extends StatelessWidget {
  const _RichRecipeText({required this.html, required this.style});
  final String html;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child:
            RichText(text: TextSpan(children: recipeHtmlToSpans(html, style))),
      );
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});
  final double? rating;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (index) => Icon(
            rating != null && index < rating!.round()
                ? Icons.star
                : Icons.star_border,
            color: RecipeColors.stars,
            size: 22,
          ),
        ),
      );
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.images, required this.initialIndex});
  final List<String> images;
  final int initialIndex;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) => InteractiveViewer(
                child: NetworkRecipeImage(
                    url: widget.images[index], fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
                icon: const Icon(Icons.close),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Text('${_index + 1} / ${widget.images.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
}
