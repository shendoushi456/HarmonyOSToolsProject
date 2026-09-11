// LifeFragment 收藏页 - 对齐 toolbox_c LifeFragment.kt (Compose 版)。
// 顶栏 0xFFC6EBFF + 2 列白色小卡片 + 右下角编辑/保存悬浮按钮。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../menu_fragment/models/tool_definition.dart';
import '../../menu_fragment/services/tool_navigation_service.dart';
import '../viewmodels/life_favorite_view_model.dart';

class LifeFavoritePage extends ConsumerWidget {
  const LifeFavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeFavoriteViewModelProvider);
    final vm = ref.read(lifeFavoriteViewModelProvider.notifier);
    final catalog = ref.watch(lifeFavoriteToolDefinitionsProvider);
    final displayTools = state.displayTools(catalog);
    return Scaffold(
      // 安卓为白色垂直渐变(白→白),即纯白背景
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // 顶栏 - 对齐 TopAppBar:背景 0xFFC6EBFF,高 50,标题居中,
              // 右侧设置图标跳转设置页(安卓 SettSet2Activity)
              _TopAppBar(isEditMode: state.isEditMode),
              Expanded(
                // 列表 - 对齐 HomeContent:水平 20/顶部 20 padding + 垂直滚动
                child: state.isLoading
                    ? const SizedBox.shrink()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          children: [
                            for (final row in _chunkTwo(displayTools))
                              _ToolRow(
                                row: row,
                                isEditMode: state.isEditMode,
                                selectedIds: state.selectedIds,
                                onToggle: vm.toggleSelect,
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          // 右下角悬浮按钮 - 对齐 bottom 160/end 10/56dp
          Positioned(
            right: 10,
            bottom: 160,
            child: _EditFab(
              isEditMode: state.isEditMode,
              onTap: state.isEditMode ? vm.saveAndExit : vm.enterEditMode,
            ),
          ),
        ],
      ),
    );
  }

  /// 对齐 toolsList.chunked(2):按 2 个一组分行,保持原顺序
  static List<List<ToolDefinition>> _chunkTwo(List<ToolDefinition> tools) {
    return [
      for (var i = 0; i < tools.length; i += 2)
        tools.sublist(i, i + 2 > tools.length ? tools.length : i + 2),
    ];
  }
}

/// 顶栏 - 对齐 LifeFragment.TopAppBar。
class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.isEditMode});

  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFC6EBFF),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                isEditMode ? '编辑收藏' : '收藏',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Positioned(
                right: 16,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: '设置',
                    icon: const Icon(Icons.settings,
                        color: Colors.black, size: 28),
                    onPressed: () => context.push(RoutePaths.setting),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 一行工具卡 - 对齐 HomeContent 的 Row(padding vertical 8 + spacedBy 15)。
class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.row,
    required this.isEditMode,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<ToolDefinition> row;
  final bool isEditMode;
  final Set<ToolId> selectedIds;
  final void Function(ToolId id) onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _EfficiencyToolCard(
              tool: row.first,
              isEditMode: isEditMode,
              isSelected: selectedIds.contains(row.first.id),
              onToggle: onToggle,
            ),
          ),
          const SizedBox(width: 15),
          // 安卓:单数行最后一个用 Spacer(weight 1f) 占位
          Expanded(
            child: row.length == 2
                ? _EfficiencyToolCard(
                    tool: row.last,
                    isEditMode: isEditMode,
                    isSelected: selectedIds.contains(row.last.id),
                    onToggle: onToggle,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

/// 工具卡片 - 对齐 EfficiencyToolCard:
/// 白底 + 圆角 5 + 阴影 3 + padding(8,12),
/// 左侧 22dp 图标 + 13sp 标题,编辑模式右侧 8dp 选择圆点。
class _EfficiencyToolCard extends StatelessWidget {
  const _EfficiencyToolCard({
    required this.tool,
    required this.isEditMode,
    required this.isSelected,
    required this.onToggle,
  });

  final ToolDefinition tool;
  final bool isEditMode;
  final bool isSelected;
  final void Function(ToolId id) onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        // 安卓 clickable(indication = null),无水波纹;
        // 编辑模式切换勾选,正常模式打开工具
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isEditMode) {
            onToggle(tool.id);
          } else {
            ToolNavigationService.open(context, tool);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Image.asset(
                      tool.iconAsset,
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tool.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              if (isEditMode) _SelectDot(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

/// 编辑模式选择圆点 - 对齐 8dp 圆:
/// 选中 0xFF4DA7D7 填充无边框;未选中白底 + 1dp 0xFFA5A5A5 边框。
class _SelectDot extends StatelessWidget {
  const _SelectDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF4DA7D7) : Colors.white,
        border: isSelected
            ? null
            : Border.all(color: const Color(0xFFA5A5A5), width: 1),
      ),
    );
  }
}

/// 编辑/保存悬浮按钮 - 对齐右下角 56dp 图片按钮:
/// 编辑模式显示 collection_one(保存),否则 collection_two(编辑)。
class _EditFab extends StatelessWidget {
  const _EditFab({required this.isEditMode, required this.onTap});

  final bool isEditMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isEditMode ? '保存' : '编辑',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Image.asset(
              isEditMode
                  ? AppAssets.lifeFavoriteSaveFab
                  : AppAssets.lifeFavoriteEditFab,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
