import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/tab_providers.dart';
import '../car_home/car_home_page.dart';
import '../indicator_light/indicator_light_page.dart';
import '../telephone_car/telephone_car_page.dart';

/// ScanMenu 主页面：底部导航 + 3 Tab
///
/// 对应 Android: ScanMenuActivity.kt
/// - Tab1：CarHomePage（首页，完整实现）
/// - Tab2：IndicatorLightPage（汽车指示灯，上下滑动列表）
/// - Tab3：TelephoneCarPage（应急电话，完整实现）
///
/// 用 IndexedStack 保持 3 Tab 状态（对应 Android Fragment show/hide）。
class ScanMenuPage extends ConsumerWidget {
  const ScanMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(selectedTabProvider);
    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: const [
          CarHomePage(),
          IndicatorLightPage(),
          TelephoneCarPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (i) =>
            ref.read(selectedTabProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: '汽车指示灯',
          ),
          NavigationDestination(
            icon: Icon(Icons.phone_outlined),
            selectedIcon: Icon(Icons.phone),
            label: '应急电话',
          ),
        ],
      ),
    );
  }
}
