// 底部 3 Tab 容器 - 对齐 Android MainWeatherActivity
// 首页(天气)迁移,日历/空气质量预留入口
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calendar/pages/calendar_page.dart';
import '../../air_quality/pages/air_quality_page.dart';
import '../../weather/pages/weather_page.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';

/// 当前选中的 Tab 索引
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    const pages = [
      WeatherPage(),
      CalendarPage(),
      AirQualityPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(context, ref, currentIndex),
    );
  }

  /// 底部导航栏 - 对齐 Android MyBottomNavView
  Widget _buildBottomNav(BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FDFF),
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
              label: '首页',
              normalIcon: AppAssets.tabHomeNormal,
              selectedIcon: AppAssets.tabHomeSelected,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              ref,
              index: 1,
              label: '日历',
              normalIcon: AppAssets.tabCalendarNormal,
              selectedIcon: AppAssets.tabCalendarSelected,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              context,
              ref,
              index: 2,
              label: '空气质量',
              normalIcon: AppAssets.tabAirNormal,
              selectedIcon: AppAssets.tabAirSelected,
              isSelected: currentIndex == 2,
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
              width: 25,
              height: 25,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.qmtqBlue : const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
