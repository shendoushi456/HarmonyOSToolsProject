// 底部 4 Tab 容器：天气(QxHome)/日历(QxCalendar)/农业(Nongye)/空气质量(QxAir)，对齐 Android MainWeatherActivity。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agriculture/pages/nongye_page.dart';
import '../../calendar/pages/qx_calendar_page.dart';
import '../../weather/pages/qx_air_page.dart';
import '../../weather/pages/qx_home_page.dart';
import '../../../core/constants/app_assets.dart';

/// 当前选中的 Tab 索引
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    const pages = [
      QxHomePage(),
      QxCalendarPage(),
      NongyePage(),
      QxAirPage(),
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
      height: 82,
      decoration: const BoxDecoration(
        // 底栏背景色对齐 master_qingyichuxingqixiang_nongye 分支
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
              normalIcon: AppAssets.toolboxNavWeatherNormal,
              selectedIcon: AppAssets.toolboxNavWeatherSelected,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              ref,
              index: 1,
              label: '日历',
              normalIcon: AppAssets.toolboxNavCalendarNormal,
              selectedIcon: AppAssets.toolboxNavCalendarSelected,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              context,
              ref,
              index: 2,
              label: '农业',
              normalIcon: AppAssets.toolboxNavAgricultureNormal,
              selectedIcon: AppAssets.toolboxNavAgricultureSelected,
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              context,
              ref,
              index: 3,
              label: '空气质量',
              normalIcon: AppAssets.toolboxNavAirNormal,
              selectedIcon: AppAssets.toolboxNavAirSelected,
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
