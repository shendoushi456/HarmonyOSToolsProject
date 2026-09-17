// 主壳页 - 对齐 MainWeatherActivity.kt 三 Tab + MyBottomNavView(navtools_menu.xml)
// Tab0/1/2 已换为 toolbox_c 迁移版(ToolsWifiHomePage/WifiToolsPage/SettingToolPage);
// 底部导航图标换 toolbox_c 原版(tools_icon_tab_*,itemIconTint=@null 原图原色),
// 文字固定黑色(对齐 itemTextColor=@color/black),白底 elevation 3
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../setting/pages/setting_tool_page.dart';
import '../../wifi/pages/tools_wifi_home_page.dart';
import '../../wifi_tools/pages/wifi_tools_page.dart';
import '../viewmodels/home_tab_view_model.dart';

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    // Tab0=toolbox_c ToolsWifiHomeFragment / Tab1=WifiToolsFragment /
    // Tab2=SettingToolFragment(原 qmtq WifiPage/ScanToolsPage/日历 WeatherPage 保留未删)
    const pages = [ToolsWifiHomePage(), WifiToolsPage(), SettingToolPage()];
    return Scaffold(
      // 悬浮网速浮层已上移至 MaterialApp.builder(全局路由之上,整个 APP 可见)
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(ref, currentIndex),
    );
  }

  Widget _buildBottomNav(WidgetRef ref, int currentIndex) {
    const items = <_NavItem>[
      _NavItem(
          iconNormal: AppAssets.mainTabHomeNormal,
          iconSelected: AppAssets.mainTabHomeSelected,
          label: '首页'),
      _NavItem(
          iconNormal: AppAssets.mainTabToolsNormal,
          iconSelected: AppAssets.mainTabToolsSelected,
          label: '工具箱'),
      _NavItem(
          iconNormal: AppAssets.mainTabMineNormal,
          iconSelected: AppAssets.mainTabMineSelected,
          label: '我的'),
    ];
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x26000000), blurRadius: 3, offset: Offset(0, -1))
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
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
                      // 对齐 itemIconTint=@null: 原图原色,选中/未选中用两套图标
                      Image.asset(
                        currentIndex == i
                            ? items[i].iconSelected
                            : items[i].iconNormal,
                        width: 25,
                        height: 25,
                      ),
                      const SizedBox(height: 2),
                      // 对齐 itemTextColor=@color/black: 文字固定黑色
                      Text(items[i].label,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black)),
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
  final String iconNormal;
  final String iconSelected;
  final String label;
  const _NavItem({
    required this.iconNormal,
    required this.iconSelected,
    required this.label,
  });
}
