// 主壳页：对齐 Android ScanMenuActivity 三 Tab 结构。
// Tab[0] = 首页（NewDrawBoardFragment 迁移），Tab[1] = 画板（NewDrawkFragment 迁移），
// Tab[2] = 工具（ScanToolsFragment 迁移，toolbox_c），Tab[3] = 涂鸦（AllToolsFragment 迁移）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../all_tools/pages/all_tools_page.dart';
import '../../new_draw_board/pages/new_draw_board_page.dart';
import '../../new_draw_board/pages/new_drawk_page.dart';
import '../../scan_tools/pages/scan_tools_fragment_page.dart';
import '../viewmodels/home_tab_view_model.dart';

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    const pages = [
      NewDrawBoardPage(),
      NewDrawkPage(),
      ScanToolsFragmentPage(),
      AllToolsPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(ref, currentIndex),
    );
  }

  Widget _buildBottomNav(WidgetRef ref, int currentIndex) {
    const items = <_NavItem>[
      // Tab[0] 首页 - NewDrawBoardPage 涂鸦首页
      _NavItem(
        normalIconData: Icons.home_rounded,
        selectedIconData: Icons.home_rounded,
        label: '首页',
      ),
      // Tab[1] 画板 - NewDrawkPage
      _NavItem(
        normalIconData: Icons.brush_rounded,
        selectedIconData: Icons.brush_rounded,
        label: '绘图',
      ),
      // Tab[2] 工具 - ScanToolsFragmentPage
      _NavItem(
        normalIconData: Icons.work_rounded,
        selectedIconData: Icons.work_rounded,
        label: '工具',
      ),
      // Tab[3] 涂鸦 - AllToolsPage
      _NavItem(
        normalIconData: Icons.person,
        selectedIconData: Icons.person,
        label: '我的',
      ),
    ];
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FDFF),
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, -1))
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
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
                      _buildIcon(items[i], currentIndex == i),
                      const SizedBox(height: 2),
                      Text(items[i].label,
                          style: TextStyle(
                              fontSize: 10,
                              color: currentIndex == i
                                  ? AppColors.homeDaohang
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

  Widget _buildIcon(_NavItem item, bool isSelected) {
    return Icon(
      isSelected ? item.selectedIconData : item.normalIconData,
      size: 25,
      color: isSelected ? AppColors.homeDaohang : const Color(0xFF999999),
    );
  }
}

/// Tab 项 - Material 图标 + 文字
class _NavItem {
  const _NavItem({
    required this.normalIconData,
    required this.selectedIconData,
    required this.label,
  });

  final IconData normalIconData;
  final IconData selectedIconData;
  final String label;
}
