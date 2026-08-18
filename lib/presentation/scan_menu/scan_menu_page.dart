import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/tab_providers.dart';
import '../car_home/car_home_page.dart';
import '../search_car_info/search_car_info_page.dart';
import '../telephone_car/telephone_car_page.dart';

/// ScanMenu 主页面：底部导航 + 3 Tab
///
/// 对应 Android: ScanMenuActivity.kt
/// - Tab1：CarHomePage（首页，完整实现）
/// - Tab2：SearchCarInfoPage（违章查询，完整实现）
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
          SearchCarInfoPage(),
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
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: '违章查询',
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
