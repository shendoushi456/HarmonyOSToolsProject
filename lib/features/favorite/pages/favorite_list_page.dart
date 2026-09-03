import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../menu_fragment/models/tool_definition.dart';
import '../../menu_fragment/services/tool_navigation_service.dart';
import '../../menu_fragment/viewmodels/menu_tools_view_model.dart';
import '../viewmodels/favorite_view_model.dart';
import 'favorite_edit_page.dart';

/// Android FavoriteListFragment, used as the third bottom-navigation page.
class FavoriteListPage extends ConsumerWidget {
  const FavoriteListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoriteViewModelProvider);
    final catalog = ref.watch(menuToolDefinitionsProvider);
    final favorites = catalog
        .where((tool) => state.ids.contains(tool.id))
        .toList(growable: false);
    return Scaffold(
      backgroundColor: const Color(0xFFF2EFFD),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 78,
                  child: Center(
                    child: Text(
                      '收藏',
                      style: TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: state.isLoading
                      ? const SizedBox.shrink()
                      : favorites.isEmpty
                          ? const _FavoriteEmptyState()
                          : _FavoriteGrid(tools: favorites),
                ),
              ],
            ),
            Positioned(
              right: 26,
              bottom: 80,
              child: _FloatingImageButton(
                asset: AppAssets.favoriteEdit,
                label: '编辑收藏',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoriteEditPage()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteEmptyState extends StatelessWidget {
  const _FavoriteEmptyState();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 145),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(AppAssets.favoriteEmpty, width: 165),
            const SizedBox(height: 2),
            const Text('暂无收藏',
                style: TextStyle(color: Color(0xFF444444), fontSize: 18)),
            const SizedBox(height: 12),
            const Text('点击按钮去添加/编辑工具快捷入口',
                style: TextStyle(color: Color(0xFF9F9F9F), fontSize: 16)),
          ]),
        ),
      );
}

class _FavoriteGrid extends StatelessWidget {
  const _FavoriteGrid({required this.tools});
  final List<ToolDefinition> tools;

  @override
  Widget build(BuildContext context) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 145),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 114,
          crossAxisSpacing: 6,
          mainAxisSpacing: 8,
        ),
        itemCount: tools.length,
        itemBuilder: (_, index) => _FavoriteTile(tool: tools[index]),
      );
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.tool});
  final ToolDefinition tool;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => ToolNavigationService.open(context, tool),
          child: Ink(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage(AppAssets.favoriteTileBackground),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(tool.favoriteIconAsset ?? tool.iconAsset,
                  width: 46, height: 46, fit: BoxFit.contain),
              const SizedBox(height: 6),
              Text(tool.title.replaceAll('\n', ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Color(0xFF434343), fontSize: 12)),
            ]),
          ),
        ),
      );
}

class _FloatingImageButton extends StatelessWidget {
  const _FloatingImageButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });
  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Image.asset(asset, width: 66, height: 66),
          ),
        ),
      );
}
