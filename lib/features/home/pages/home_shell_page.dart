// 主壳页：对齐 Android ScanMenuActivity 三 Tab 结构。
// Tab[0] = 首页（NewDrawBoardFragment 迁移），Tab[1] = 画板（NewDrawkFragment 迁移），Tab[2] = 涂鸦（AllToolsFragment 迁移）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../all_tools/pages/all_tools_page.dart';
import '../../new_draw_board/pages/new_draw_board_page.dart';
import '../../new_draw_board/pages/new_drawk_page.dart';
import '../viewmodels/home_tab_view_model.dart';

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    const pages = [NewDrawBoardPage(), NewDrawkPage(), AllToolsPage()];
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(ref, currentIndex),
    );
  }

  Widget _buildBottomNav(WidgetRef ref, int currentIndex) {
    const items = <_NavItem>[
      // Tab[0] 首页 - 用 toolbox_c colorTabHome 图片资源
      _NavItem(
        normalIcon: _IconKind.asset,
        normalAsset: AppAssets.colorTabHomeNormal,
        selectedIcon: _IconKind.asset,
        selectedAsset: AppAssets.colorTabHomeSelected,
        label: '首页',
      ),
      // Tab[1] 画板 - 用 colorTabMore 图片（与涂鸦互换后）
      _NavItem(
        normalIcon: _IconKind.asset,
        normalAsset: AppAssets.colorTabMoreNormal,
        selectedIcon: _IconKind.asset,
        selectedAsset: AppAssets.colorTabMoreSelected,
        label: '画板',
      ),
      // Tab[2] 涂鸦 - 用 colorTabBoard 图片（与画板互换后）
      _NavItem(
        normalIcon: _IconKind.asset,
        normalAsset: AppAssets.colorTabBoardNormal,
        selectedIcon: _IconKind.asset,
        selectedAsset: AppAssets.colorTabBoardSelected,
        label: '涂鸦',
      ),
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
                      _buildIcon(items[i], currentIndex == i),
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

  Widget _buildIcon(_NavItem item, bool isSelected) {
    if (item.normalIcon == _IconKind.asset) {
      return Image.asset(
        isSelected ? item.selectedAsset! : item.normalAsset!,
        width: 25,
        height: 25,
      );
    }
    return Icon(
      isSelected ? item.selectedIconData! : item.normalIconData!,
      size: 25,
      color: isSelected ? AppColors.qmtqBlue : const Color(0xFF999999),
    );
  }
}

/// Tab 项 - 支持图片资源（asset）或 Material Icons
class _NavItem {
  const _NavItem({
    required this.normalIcon,
    required this.selectedIcon,
    this.normalAsset,
    this.selectedAsset,
    this.normalIconData,
    this.selectedIconData,
    required this.label,
  });
  final _IconKind normalIcon;
  final _IconKind selectedIcon;
  final String? normalAsset;
  final String? selectedAsset;
  final IconData? normalIconData;
  final IconData? selectedIconData;
  final String label;
}

enum _IconKind { asset, icon }
