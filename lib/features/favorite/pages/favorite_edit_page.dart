import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../menu_fragment/models/tool_definition.dart';
import '../../menu_fragment/viewmodels/menu_tools_view_model.dart';
import '../viewmodels/favorite_view_model.dart';

/// Android FeatureListActivity's three-column, checkbox-based editor.
class FavoriteEditPage extends ConsumerWidget {
  const FavoriteEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(menuToolDefinitionsProvider);
    final state = ref.watch(favoriteViewModelProvider);
    final vm = ref.read(favoriteViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFF2EFFD),
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          Column(children: [
            SizedBox(
              height: 78,
              child: Stack(alignment: Alignment.center, children: [
                Positioned(
                  left: 8,
                  child: IconButton(
                    tooltip: '返回',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF444444), size: 21),
                  ),
                ),
                const Text('编辑收藏',
                    style: TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 145),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 132,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 2,
                ),
                itemCount: catalog.length,
                itemBuilder: (_, index) => _SelectableFavoriteTile(
                  tool: catalog[index],
                  selected: state.contains(catalog[index]),
                  onTap: () => vm.toggle(catalog[index]),
                ),
              ),
            ),
          ]),
          Positioned(
            right: 26,
            bottom: 80,
            child: _DoneButton(onTap: () => Navigator.pop(context)),
          ),
        ]),
      ),
    );
  }
}

class _SelectableFavoriteTile extends StatelessWidget {
  const _SelectableFavoriteTile({
    required this.tool,
    required this.selected,
    required this.onTap,
  });
  final ToolDefinition tool;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Stack(children: [
            Center(
              child: Container(
                width: 106,
                height: 104,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(AppAssets.favoriteTileBackground),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(tool.favoriteIconAsset ?? tool.iconAsset,
                          width: 46, height: 46, fit: BoxFit.contain),
                      const SizedBox(height: 8),
                      Text(tool.title.replaceAll('\n', ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF434343), fontSize: 12)),
                    ]),
              ),
            ),
            Positioned(
              top: 5,
              right: 3,
              child: IgnorePointer(
                child: Checkbox(
                  value: selected,
                  onChanged: null,
                  activeColor: const Color(0xFF7357F6),
                  side: const BorderSide(color: Color(0xFF9D9D9D)),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ]),
        ),
      );
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '完成编辑',
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Image.asset(AppAssets.favoriteDone, width: 66, height: 66),
          ),
        ),
      );
}
