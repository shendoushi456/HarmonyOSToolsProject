// 主壳页：对齐 MainWeatherActivity.kt 的三 Tab 结构。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../image_gallery/pages/image_gallery_page.dart';
import '../../menu_fragment/pages/sao_menu_page.dart';
import '../../scan_tools/pages/sao_tools_page.dart';
import '../viewmodels/home_tab_view_model.dart';

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    const pages = [
      SaoMenuPage(),
      ImageGalleryPage(),
      SaoToolsPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(ref, currentIndex),
    );
  }

  /// 底部导航 - 对齐 toolbox_c activity_sacnmenu_layout.xml + nav_tools_menu.xml：
  /// 白底 + 顶部 #FFCECECE 分隔线(MyBottomNavView stroke)，图标原色无 tint，
  /// 文字 12sp(选中 #1B2630=colorPrimary blue，未选中默认灰)
  Widget _buildBottomNav(WidgetRef ref, int currentIndex) {
    const items = <_NavItem>[
      _NavItem(AppAssets.saoNavHomeNormal, AppAssets.saoNavHomeSelected, '首页',
          22, 23, 22, 23),
      _NavItem(AppAssets.saoNavDocNormal, AppAssets.saoNavDocSelected, '文档',
          22, 24, 22, 24),
      _NavItem(AppAssets.saoNavToolsNormal, AppAssets.saoNavToolsSelected, '工具',
          24, 24, 22, 22),
    ];
    return Container(
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
        // 白色背景(Container)延伸到屏幕底部,导航内容行避开底部安全区
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // MyBottomNavView 顶部 5px #FFCECECE stroke 分隔线
            Container(height: 1, color: const Color(0xFFFCECEC)),
            // 对齐 BottomNavigationView wrap_content = 56dp(不含系统导航安全区)
            SizedBox(
              height: 55,
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
                              width: currentIndex == i
                                  ? items[i].selectedWidth
                                  : items[i].normalWidth,
                              height: currentIndex == i
                                  ? items[i].selectedHeight
                                  : items[i].normalHeight,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 1),
                            Text(items[i].label,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: currentIndex == i
                                        ? const Color(0xFF1B2630)
                                        : const Color(0xFF666666))),
                          ],
                        ),
                      ),
                    ),
                ],
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
  final double normalWidth;
  final double normalHeight;
  final double selectedWidth;
  final double selectedHeight;
  const _NavItem(
    this.normalAsset,
    this.selectedAsset,
    this.label,
    this.normalWidth,
    this.normalHeight,
    this.selectedWidth,
    this.selectedHeight,
  );
}
