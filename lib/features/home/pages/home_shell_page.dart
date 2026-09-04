// 主壳页：对齐 ScanMenuActivity.kt 的三 Tab 结构。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../image_gallery/pages/image_gallery_page.dart';
import '../../menu_fragment/pages/menu_fragment_page.dart';
import '../../scan_tools_toolbox_c/pages/scan_tools_toolbox_c_page.dart';
import '../viewmodels/home_tab_view_model.dart';

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    const pages = [
      MenuFragmentPage(),
      ImageGalleryPage(),
      ScanToolsToolboxCPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(ref, currentIndex),
    );
  }

  /// 底部导航 - 对齐 nav_tools_menu.xml：首页 / 文档 / 工具。
  ///
  /// 图标采用 toolbox_c 提供的 selected/unselected 预染色 PNG（替代 Android
  /// selector drawable 的 state_checked 切换）；文本颜色取与图标蓝色相近的
  /// Material 主蓝，与源工程 `itemTextColor=null` 时 BottomNavigationView
  /// 默认主题色调一致。
  Widget _buildBottomNav(WidgetRef ref, int currentIndex) {
    const items = <_NavItem>[
      _NavItem(AppAssets.bnTab1False, AppAssets.bnTab1True, '首页'),
      _NavItem(AppAssets.bnTab2False, AppAssets.bnTab2True, '文档'),
      _NavItem(AppAssets.bnTab3False, AppAssets.bnTab3True, '工具'),
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
        top: false,
        bottom: false,
        child: SizedBox(
          height: 56,
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
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: currentIndex == i
                                ? const Color(0xFF2C7AC8)
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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
