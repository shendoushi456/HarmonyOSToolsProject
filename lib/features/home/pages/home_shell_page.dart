// 主壳页：对齐 MainWeatherActivity.kt 的三 Tab 结构。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../menu_fragment/pages/menu_fragment_page.dart';
import '../../menu_home/pages/menu_home_page.dart';
import '../../other_scan_tools/pages/other_scan_tools_page.dart';
import '../../favorite/pages/favorite_list_page.dart';
import '../viewmodels/home_tab_view_model.dart';

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    const pages = [
      MenuHomePage(),
      // MenuFragmentPage(),
      OtherScanToolsPage(),
      FavoriteListPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(ref, currentIndex),
    );
  }

  Widget _buildBottomNav(WidgetRef ref, int currentIndex) {
    const items = <_NavItem>[
      _NavItem(AppAssets.bottomHomeNormal, AppAssets.bottomHomeSelected, '首页'),
      _NavItem(
          AppAssets.bottomToolsNormal, AppAssets.bottomToolsSelected, '工具'),
      _NavItem(
        AppAssets.bottomFavoriteNormal,
        AppAssets.bottomFavoriteSelected,
        '收藏',
      ),
    ];
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 3,
            offset: Offset(0, -1),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      ref.read(homeTabIndexProvider.notifier).state = i,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        currentIndex == i
                            ? items[i].selectedAsset
                            : items[i].normalAsset,
                        width: i == 1 ? 30 : 26,
                        height: i == 1 ? 30 : 26,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 1),
                      Text(items[i].label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: currentIndex == i
                                  ? const Color(0xFF7357F6)
                                  : const Color(0xFF8E8E8E))),
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

class _NavItem {
  final String normalAsset;
  final String selectedAsset;
  final String label;
  const _NavItem(this.normalAsset, this.selectedAsset, this.label);
}
