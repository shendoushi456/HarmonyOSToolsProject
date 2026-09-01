// 底部 Tab 容器。
// 前两个入口严格对齐 Android MainWeatherActivity：本地海拔、指南针；
// 后续页面保留现有鸿蒙工程的信息架构。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../location/pages/altitude_page.dart';
import '../../location/pages/compass_page.dart';
import '../../weather/pages/weather_page.dart';
import '../../tools/pages/tools_box_page.dart';
import '../../../core/constants/app_assets.dart';

/// 当前选中的 Tab 索引
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    const pages = [
      AltitudePage(),
      WeatherPage(),
      ToolsBoxPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          pages[0],
          const CompassPage(),
          pages[1],
          pages[2],
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, ref, currentIndex),
    );
  }

  /// 底部导航栏 - 对齐 Android MyBottomNavView
  Widget _buildBottomNav(
      BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFF010812),
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
              label: '本地海拔',
              normalIcon: AppAssets.bottomTabAltitudeNormal,
              selectedIcon: AppAssets.bottomTabAltitudeSelected,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              ref,
              index: 1,
              label: '指南针',
              normalIcon: AppAssets.bottomTabCompassNormal,
              selectedIcon: AppAssets.bottomTabCompassSelected,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              context,
              ref,
              index: 2,
              label: '天气',
              normalIcon: AppAssets.bottomTabWeatherNormal,
              selectedIcon: AppAssets.bottomTabWeatherSelected,
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              context,
              ref,
              index: 3,
              label: '工具',
              normalIcon: AppAssets.bottomTabToolsNormal,
              selectedIcon: AppAssets.bottomTabToolsSelected,
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
              width: 25,
              height: 25,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
