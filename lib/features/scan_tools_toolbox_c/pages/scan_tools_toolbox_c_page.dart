import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../features/menu_fragment/services/tool_navigation_service.dart';
import '../../../router/route_names.dart';
import '../models/scan_tool_category.dart';
import '../viewmodels/scan_tools_view_model.dart';

/// 对齐 Android ScanToolsFragment.ToolsScreen：
///   顶栏(标题"工具"+ 设置图标) + 分类卡片堆叠，每张卡片最多 2×2 工具项。
///
/// UI/功能/数据分层：view 层只读取 [scanToolsCategoriesProvider]，跳转统一走
/// [ToolNavigationService.openDestination]，便于后续整体换马甲包时只换数据 + 资源。
class ScanToolsToolboxCPage extends ConsumerWidget {
  const ScanToolsToolboxCPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(scanToolsCategoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFE5C3),
      body: Stack(
        children: [
          // 全屏背景纹理 - 对应 ToolsScreen 顶层 Box 的 paint(shap_topbar_bg, Crop)
          Positioned.fill(
            child: Image.asset(
              AppAssets.tbcShapTopbarBg,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                _ToolsTopBar(
                  onSettingsTap: () => context.push(RoutePaths.setting),
                ),
                for (var i = 0; i < categories.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _CategorySection(category: categories[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶栏 56dp - 对应 ScanToolsFragment.TopHeader。
class _ToolsTopBar extends StatelessWidget {
  const _ToolsTopBar({required this.onSettingsTap});
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              '工具',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF444444),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSettingsTap,
                child: const Icon(
                  Icons.settings,
                  size: 26,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个分类区块 - 对应 ToolCategorySection。
///   标题 + 180dp 高白色卡片容器(bg_tool_category_container)，内部 2 列工具行。
class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category});
  final ScanToolCategory category;

  @override
  Widget build(BuildContext context) {
    final rows = <List<ScanToolItem>>[];
    for (var i = 0; i < category.tools.length; i += 2) {
      final pair = <ScanToolItem>[category.tools[i]];
      if (i + 1 < category.tools.length) {
        pair.add(category.tools[i + 1]);
      }
      rows.add(pair);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.title,
          style: const TextStyle(
            color: Color(0xFF353535),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage(AppAssets.stBgToolCategoryContainer),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                Expanded(child: _ToolRow(items: rows[i])),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 一行最多两个工具项 - 对应 ToolRow(item1, item2?)。item2 为 null 时 item1 占满整行。
class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.items});
  final List<ScanToolItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _ToolItemView(item: items[i])),
            ],
          ],
        ),
      ),
    );
  }
}

/// 单个工具项：44dp 圆角图标块 + 文本 - 对应 ToolItem。
class _ToolItemView extends StatelessWidget {
  const _ToolItemView({required this.item});
  final ScanToolItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => ToolNavigationService.openDestination(context, item.destination),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              item.iconAsset,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF353535),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 17 / 12, // 对应 Android lineHeight = 17sp / 12sp
              ),
            ),
          ),
        ],
      ),
    );
  }
}