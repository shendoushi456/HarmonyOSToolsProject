// 主壳页：对齐 MainWeatherActivity.kt 的三 Tab 结构。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../wifi/pages/wifi_page.dart';
import '../../tools_home/pages/tools_home_page.dart';
import '../../weather_calendar/pages/weather_calendar_page.dart';
import '../viewmodels/home_tab_view_model.dart';

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    const pages = [
      WifiPage(),
      ToolsHomePage(),
      WeatherCalendarPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(ref, currentIndex),
    );
  }

  Widget _buildBottomNav(WidgetRef ref, int currentIndex) {
    const items = <_NavItem>[
      _NavItem(Icons.home_outlined, Icons.home, '首页'),
      _NavItem(Icons.work_outline, Icons.work, '常用工具'),
      _NavItem(Icons.calendar_month_outlined, Icons.calendar_month, '日历'),
    ];
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FDFF),
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, -1))
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
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
                      // i == 2
                      //     ? Image.asset(
                      //         // 对齐安卓 navtools_menu.xml tab_3"日历" icon_tab_tools_2
                      //         currentIndex == i
                      //             ? AppAssets.weatherCalendarTabSelected
                      //             : AppAssets.weatherCalendarTabNormal,
                      //         width: 25,
                      //         height: 25,
                      //       )
                      //     :
                      Icon(
                              currentIndex == i
                                  ? items[i].selected
                                  : items[i].normal,
                              size: 25,
                              color: currentIndex == i
                                  ? AppColors.qmtqBlue
                                  : const Color(0xFF999999),
                            ),
                      const SizedBox(height: 2),
                      Text(items[i].label,
                          style: TextStyle(
                              fontSize: 10,
                              color: currentIndex == i
                                  ? AppColors.qmtqBlue
                                  : const Color(0xFF999999))),
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
  final IconData normal;
  final IconData selected;
  final String label;
  const _NavItem(this.normal, this.selected, this.label);
}
