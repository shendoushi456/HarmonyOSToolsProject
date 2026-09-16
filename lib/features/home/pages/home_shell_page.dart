// 底部 3 Tab 容器 - 对齐 toolbox_c(清逸出行气象) MainWeatherActivity + navtools_menu：
// 天气(WeatherFragment) / 日历(WeatherCalendarFragment) / 生活指南(AirQualityFragment)。
// 图标对齐 icon_tab_tools_1/2/3 selector，文字统一黑色(itemTextColor @color/black)。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calendar/pages/toolbox_weather_calendar_page.dart';
import '../../weather/pages/toolbox_air_quality_page.dart';
import '../../weather/pages/toolbox_weather_home_page.dart';
import '../../../core/constants/app_assets.dart';

/// 当前选中的 Tab 索引
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    const pages = [
      ToolboxWeatherHomePage(),
      ToolboxWeatherCalendarPage(),
      ToolboxAirQualityPage(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 三个一级页面均为白底，状态栏文字使用黑色。
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
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

  /// 底部导航栏 - 对齐 Android MyBottomNavView + navtools_menu(白底/黑字/原色图标)
  Widget _buildBottomNav(
      BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
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
              normalIcon: AppAssets.tbNavWeatherOff,
              selectedIcon: AppAssets.tbNavWeatherOn,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              ref,
              index: 1,
              label: '日历',
              normalIcon: AppAssets.tbNavCalendarOff,
              selectedIcon: AppAssets.tbNavCalendarOn,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              context,
              ref,
              index: 2,
              label: '生活指南',
              normalIcon: AppAssets.tbNavAirOff,
              selectedIcon: AppAssets.tbNavAirOn,
              isSelected: currentIndex == 2,
            ),
          ],
        ),
      ),
    );
  }

  /// 单个导航项 - 图标按 Android 原图尺寸(66x60@xxhdpi = 22x20dp)
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
              width: 22,
              height: 20,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
