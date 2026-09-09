// toolbox_c DoodleCategoryFragment 的 Flutter UI 迁移。
// 分类涂鸦/离线涂鸦页面复用现有数据与功能链路，当前页只负责 Android 同款布局。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../life_tools/pages/color_more/category_items_page.dart';
import '../../life_tools/pages/color_more/offline_category_page.dart';
import '../viewmodels/doodle_category_view_model.dart';

class ToolsFragmentPage extends StatelessWidget {
  const ToolsFragmentPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF1A1B23),
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            _TopBar(onSettings: () => context.push(RoutePaths.setting)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('分类涂鸦'),
                      _CategoryGrid(
                          items: DoodleCategoryViewModel.categoryItems),
                      const SizedBox(height: 32),
                      const _SectionTitle('离线涂鸦'),
                      _CategoryGrid(
                          items: DoodleCategoryViewModel.offlineItems),
                    ]),
              ),
            ),
          ]),
        ),
      );

  static void _open(BuildContext context, DoodleCategoryItem item) {
    if (item.offline) {
      OfflineCategoryPage.push(context, classify: item.title);
    } else {
      CategoryItemsPage.push(context, code: item.code);
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: Stack(children: [
          const Center(
            child: Text('涂鸦分类',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkResponse(
                onTap: onSettings,
                child: Image.asset(AppAssets.doodleCategorySettings,
                    width: 24, height: 24),
              ),
            ),
          ),
        ]),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      );
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.items});
  final List<DoodleCategoryItem> items;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 100 / 132,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return InkResponse(
              onTap: () => ToolsFragmentPage._open(context, item),
              child: Column(children: [
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2B35),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(item.asset, width: 60, height: 60),
                ),
                const SizedBox(height: 8),
                Text(item.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ]),
            );
          },
        ),
      );
}
