// 底部 3 Tab 容器 - 对齐 Android MainWeatherActivity
// 3 Tab: 天气/日历/生活指南（对齐 Android navtools_menu.xml）
// 底部导航: 白色背景 + 黑色文字(统一,无选中/未选中区分) + ic_tab_1/2/3 图标原色(对齐 Android itemIconTint=null + itemTextColor=black)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calendar/pages/calendar_fragment.dart';
import '../../air_quality/pages/weather_sh_child_page.dart';
import '../../weather/pages/weather_new_page.dart';
import '../../../core/constants/app_assets.dart';

/// 当前选中的 Tab 索引
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    const pages = [
      WeatherNewPage(),
      CalendarFragment(),
      WeatherShChildPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(context, ref, currentIndex),
    );
  }

  /// 底部导航栏 - 对齐 Android MyBottomNavView（继承 BottomNavigationView）
  /// 白色背景 + elevation 3dp + itemIconTint=null(图标原色) + itemTextColor=black(统一黑色)
  Widget _buildBottomNav(BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      // 对齐 Android Material BottomNavigationView 默认高度 ~56dp
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white, // 对齐 Android background=white
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            _buildNavItem(
              context,
              ref,
              index: 0,
              label: '天气', // 对齐 Android navtools_menu "天气"
              normalIcon: AppAssets.tabWeatherFalse, // ic_tab_1_false
              selectedIcon: AppAssets.tabWeatherTrue, // ic_tab_1_true
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              ref,
              index: 1,
              label: '日历', // 对齐 Android navtools_menu "日历"
              normalIcon: AppAssets.tabCalendarFalse, // ic_tab_2_false
              selectedIcon: AppAssets.tabCalendarTrue, // ic_tab_2_true
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              context,
              ref,
              index: 2,
              label: '生活指南', // 对齐 Android navtools_menu "生活指南"
              normalIcon: AppAssets.tabLifeGuideFalse, // ic_tab_3_false
              selectedIcon: AppAssets.tabLifeGuideTrue, // ic_tab_3_true
              isSelected: currentIndex == 2,
            ),
          ],
        ),
      ),
    );
  }

  /// 单个底部导航项
  /// 对齐 Android: itemIconTint=null（图标用 selector 原色 PNG）+ itemTextColor=black（统一黑色,无选中/未选中区分）
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
            // 图标 - 对齐 Android selector(checked/unchecked 切换 true/false PNG)
            // itemIconTint=null 表示用原色,鸿蒙 Image.asset 默认原色不染色
            Image.asset(
              isSelected ? selectedIcon : normalIcon,
              width: 25,
              height: 25,
            ),
            const SizedBox(height: 2),
            // 文字 - 对齐 Android itemTextColor=black（统一黑色,无选中/未选中区分）
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
