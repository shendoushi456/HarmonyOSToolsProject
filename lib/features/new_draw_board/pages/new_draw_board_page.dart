// ScanMenuActivity / NewDrawBoardFragment 首页迁移。
// 页面仅负责布局和导航；分类数据由 ToolboxMenuViewModel 提供，便于整体换肤复用。
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../life_tools/pages/color_more/category_items_page.dart';
import '../../life_tools/pages/color_more/offline_category_page.dart';
import '../../life_tools/pages/draw/draw_page.dart';
import '../../toolbox_migration/viewmodels/toolbox_menu_view_model.dart';

class NewDrawBoardPage extends StatelessWidget {
  const NewDrawBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ToolboxMenuViewModel.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2F2F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
              child: Center(
                child: Text('首页',
                    style: TextStyle(fontSize: 22, color: Colors.black)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BoardHero(onTap: () => DrawPage.push(context)),
                    _SectionTitle('分类涂鸦'),
                    _CategoryGrid(
                      items: viewModel.onlineCategories,
                      onTap: (item) => OfflineCategoryPage.push(
                        context,
                        classify: item.title,
                      ),
                    ),
                    _SectionTitle('离线涂鸦', verticalMargin: 20),
                    _CategoryGrid(
                      items: viewModel.offlineCategories,
                      onTap: (item) => CategoryItemsPage.push(
                        context,
                        code: item.categoryCode!,
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
}

class _BoardHero extends StatelessWidget {
  const _BoardHero({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFAC93FB), Color(0xFFFF8B65F8)],
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(children: [
          Row(children: [
            Image.asset(AppAssets.toolboxBoardHero, width: 130, height: 95),
            const SizedBox(width: 12),
            const Expanded(
              child: SizedBox(
                height: 95,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('掌上免费画',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    SizedBox(height: 6),
                    Text('提笔即画 创意无界！',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ]),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(35, 20, 35, 0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF37FCD0), Color(0xFF53BBFC)]),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('开始创作',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ]),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.verticalMargin = 30});
  final String title;
  final double verticalMargin;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(20, verticalMargin, 20, 13),
        child: Text(title,
            style: const TextStyle(fontSize: 16, color: Color(0xFF333333))),
      );
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.items, required this.onTap});
  final List<ToolboxCategoryItem> items;
  final ValueChanged<ToolboxCategoryItem> onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 2) ...[
              Row(children: [
                Expanded(
                    child: _CategoryCard(item: items[index], onTap: onTap)),
                const SizedBox(width: 16),
                Expanded(
                  child: _CategoryCard(
                    item: items[index + 1],
                    onTap: onTap,
                  ),
                ),
              ]),
              if (index + 2 < items.length) const SizedBox(height: 16),
            ],
          ],
        ),
      );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item, required this.onTap});
  final ToolboxCategoryItem item;
  final ValueChanged<ToolboxCategoryItem> onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onTap(item),
          child: SizedBox(
            height: 94,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(children: [
                Image.asset(item.asset,
                    width: 60, height: 60, fit: BoxFit.fill),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(item.title,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ]),
            ),
          ),
        ),
      );
}
