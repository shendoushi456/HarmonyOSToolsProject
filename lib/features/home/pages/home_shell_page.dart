// 底部 4 Tab 容器：天气 / 旅行 / 农业 / 设置(对齐 toolbox_c WeatherShFragment，无撤销协议入口)。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agriculture/pages/nongye_page.dart';
import '../../setting/pages/weather_setting_page.dart';
import '../../travel/pages/viewpoint_fragment_page.dart';
import '../../weather/pages/weather_home_page.dart';
import '../../../core/constants/app_assets.dart';

/// 当前选中的 Tab 索引
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    const pages = [
      WeatherHomePage(),
      ViewpointFragmentPage(),
      NongyePage(),
      WeatherSettingPage(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 首页天气 Tab 顶部为蓝色渐变 Hero，状态栏文字使用白色。
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF0A0D0E),
      ),
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: _buildBottomNav(context, ref, currentIndex),
      ),
    );
  }

  /// 底部导航栏 - 对齐 Android MyBottomNavView
  Widget _buildBottomNav(
      BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF2772C8),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Row(
          children: [
            _buildNavItem(
              context,
              ref,
              index: 0,
              label: '天气',
              // 对齐安卓 navtools_menu tab_1 原版图标 icon_tab_tools_1(ic_tab_1)
              normalIcon: AppAssets.toolboxNavWeatherNormal,
              selectedIcon: AppAssets.toolboxNavWeatherSelected,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              ref,
              index: 1,
              label: '旅行',
              normalIcon: AppAssets.toolboxNavCalendarNormal,
              selectedIcon: AppAssets.toolboxNavCalendarSelected,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              context,
              ref,
              index: 2,
              label: '农业',
              // 对齐安卓 navtools_menu tab_2 原版图标 icon_tab_tools_3(ic_tab_3)
              normalIcon: AppAssets.toolboxNavAgricultureNormal,
              selectedIcon: AppAssets.toolboxNavAgricultureSelected,
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              context,
              ref,
              index: 3,
              label: '设置',
              normalIcon: AppAssets.toolboxNavLifeGuideNormal,
              selectedIcon: AppAssets.toolboxNavLifeGuideSelected,
              isSelected: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  /// 单个底部导航项
  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref, {
    required int index,
    required String label,
    required String normalIcon,
    required String selectedIcon,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(homeTabIndexProvider.notifier).state = index,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isSelected ? selectedIcon : normalIcon,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
