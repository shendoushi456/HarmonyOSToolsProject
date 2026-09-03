// 底部 4 Tab 容器：首位为 toolbox_c 迁入的天气页，保留既有首页/日历/空气质量。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agriculture/pages/agriculture_page.dart';
import '../../calendar/pages/calendar_new_page.dart';
import '../../weather/pages/life_index_page.dart';
import '../../weather/pages/toolbox_weather_page.dart';
import '../../../core/constants/app_assets.dart';

/// 当前选中的 Tab 索引
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    const pages = [
      ToolboxWeatherPage(),
      LifeIndexPage(),
      CalendarNewPage(),
      AgriculturePage(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 四个一级页面均为深色底，状态栏文字固定使用白色。
      value: SystemUiOverlayStyle.dark.copyWith(
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
        color: Color(0xFFFFFFFF),
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
              label: '天气',
              normalIcon: AppAssets.zyytTabWeatherNormal,
              selectedIcon: AppAssets.zyytTabWeatherSelected,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              ref,
              index: 1,
              label: '生活指数',
              normalIcon: AppAssets.zyytTabLifeNormal,
              selectedIcon: AppAssets.zyytTabLifeSelected,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              context,
              ref,
              index: 2,
              label: '日历',
              normalIcon: AppAssets.zyytTabCalendarNormal,
              selectedIcon: AppAssets.zyytTabCalendarSelected,
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              context,
              ref,
              index: 3,
              label: '农业',
              normalIcon: AppAssets.zyytTabAgricultureNormal,
              selectedIcon: AppAssets.zyytTabAgricultureSelected,
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
