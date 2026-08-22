// 旅行清单页 - 对齐 Android TravelChecklistScreen.kt:33-107 + TravelChecklistActivity.kt
// Scaffold + ToolTopBar("旅行清单") + 滚动列表(分组 header + items)
// 第一个 section 顶部带总计数 + "只看未完成" Switch
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/checklist_item.dart';
import '../../viewmodels/checklist_view_model.dart';
import '../widgets/tool_top_bar.dart';
import 'widgets/checklist_item_row.dart';
import 'widgets/checklist_section_header.dart';

class ChecklistPage extends ConsumerWidget {
  const ChecklistPage({super.key});

  /// 跳转便捷方法
  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChecklistPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checklistViewModelProvider);
    final vm = ref.read(checklistViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ToolTopBar(title: '旅行清单'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _buildChildren(
          state.sections,
          state.showOnlyIncomplete,
          state.completedItemCount,
          state.totalItemCount,
          vm,
        ),
      ),
    );
  }

  List<Widget> _buildChildren(
    List<ChecklistSection> sections,
    bool showOnlyIncomplete,
    int totalCompleted,
    int totalItems,
    ChecklistViewModel vm,
  ) {
    final result = <Widget>[];
    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      final allItems = section.items;
      final visibleItems = showOnlyIncomplete
          ? allItems.where((it) => !it.isChecked).toList()
          : allItems;
      final completed = allItems.where((it) => it.isChecked).length;

      if (i == 0) {
        // 第一组顶部:总计数 + "只看未完成" Switch - 对齐 ListHeader
        result.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: ChecklistListHeader(
              completed: totalCompleted,
              total: totalItems,
              showOnlyIncomplete: showOnlyIncomplete,
              onToggle: vm.setShowOnlyIncomplete,
            ),
          ),
        );
      }
      // 分组标题 - 对齐 SectionHeader
      result.add(ChecklistSectionHeader(
        title: section.title,
        completedCount: completed,
        totalCount: allItems.length,
      ));
      // 清单项
      for (final item in visibleItems) {
        result.add(ChecklistItemRow(
          item: item,
          onToggle: () => vm.toggleItemChecked(item.id),
        ));
      }
    }
    return result;
  }
}
