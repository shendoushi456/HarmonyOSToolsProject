// 指定 ScanMenu 的底部两栏容器：首页 / 文档。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../scan_menu/pages/document_gallery_page.dart';
import '../../scan_menu/pages/scan_home_page.dart';
import '../../portable_tools/pages/portable_tools_page.dart';
import '../viewmodels/home_tab_view_model.dart';

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    const pages = [ScanHomePage(), DocumentGalleryPage(), PortableToolsPage()];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
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
              isSelected: currentIndex == 0,
              useMaterialIcon: true,
              materialIcon: Icons.home_outlined,
              materialSelectedIcon: Icons.home,
            ),
            _buildNavItem(
              context,
              ref,
              index: 1,
              label: '文档',
              isSelected: currentIndex == 1,
              useMaterialIcon: true,
              materialIcon: Icons.folder_outlined,
              materialSelectedIcon: Icons.folder,
            ),
            _buildNavItem(
              context,
              ref,
              index: 2,
              label: '工具',
              isSelected: currentIndex == 2,
              useMaterialIcon: true,
              materialIcon: Icons.grid_view_outlined,
              materialSelectedIcon: Icons.grid_view,
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
    required bool isSelected,
    bool useMaterialIcon = false,
    IconData? materialIcon,
    IconData? materialSelectedIcon,
  }) {
    final color = isSelected ? AppColors.qmtqBlue : const Color(0xFF999999);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(homeTabIndexProvider.notifier).state = index,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useMaterialIcon)
              Icon(
                isSelected
                    ? materialSelectedIcon ?? materialIcon
                    : materialIcon,
                size: 25,
                color: color,
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
