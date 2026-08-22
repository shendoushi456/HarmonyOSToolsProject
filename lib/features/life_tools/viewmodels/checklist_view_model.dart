// 旅行清单 ViewModel - 对齐 Android TravelChecklistViewModel.kt:33-118
// 数据流: getInitialData 16 项分 2 组 → toggleItemChecked → 持久化到 PrefsStorage
// 改进: 用 PrefsStorage 持久化勾选状态(原版无持久化,每次进入重置)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/prefs_storage.dart';
import '../models/checklist_item.dart';
import 'checklist_state.dart';

class ChecklistViewModel extends Notifier<ChecklistState> {
  @override
  ChecklistState build() {
    // 直接返回初始数据(对齐 TravelChecklistViewModel.kt:36 getInitialData)
    final saved = PrefsStorage.loadChecklistChecked();
    final sections = _buildInitialSections(saved);
    final allItems = sections.expand((s) => s.items).toList();
    return ChecklistState(
      sections: sections,
      totalItemCount: allItems.length,
      completedItemCount: allItems.where((i) => i.isChecked).length,
    );
  }

  List<ChecklistSection> _buildInitialSections(Map<int, bool> saved) {
    // 默认勾选状态 - 对齐 getInitialData(仅 id=1 购买机票默认 true)
    bool isChecked(int id) => saved[id] ?? (id == 1);

    return [
      ChecklistSection(
        title: '行前事项',
        items: [
          ChecklistItem(id: 1, text: '购买机票', isChecked: isChecked(1)),
          ChecklistItem(id: 2, text: '预定酒店', isChecked: isChecked(2)),
          ChecklistItem(id: 3, text: '购买旅行保险', isChecked: isChecked(3)),
          ChecklistItem(id: 4, text: '办理签证', isChecked: isChecked(4)),
          ChecklistItem(id: 5, text: '换现金', isChecked: isChecked(5)),
          ChecklistItem(id: 6, text: '分享行程给家人/朋友', isChecked: isChecked(6)),
          ChecklistItem(id: 7, text: '锁好贵重物品', isChecked: isChecked(7)),
          ChecklistItem(id: 8, text: '颈枕', isChecked: isChecked(8)),
          ChecklistItem(id: 9, text: '雨伞/雨衣', isChecked: isChecked(9)),
          ChecklistItem(id: 10, text: '水杯', isChecked: isChecked(10)),
          ChecklistItem(id: 11, text: '干/湿纸巾', isChecked: isChecked(11)),
          ChecklistItem(id: 12, text: '耳塞/眼罩', isChecked: isChecked(12)),
        ],
      ),
      ChecklistSection(
        title: '证件',
        items: [
          ChecklistItem(id: 13, text: '身份证', isChecked: isChecked(13)),
          ChecklistItem(id: 14, text: '护照签证', isChecked: isChecked(14)),
          ChecklistItem(id: 15, text: '酒店预订单', isChecked: isChecked(15)),
          ChecklistItem(id: 16, text: '紧急联系方式', isChecked: isChecked(16)),
        ],
      ),
    ];
  }

  /// 切换勾选状态 - 对齐 TravelChecklistViewModel.kt:64-76 toggleItemChecked
  /// 额外持久化到 PrefsStorage
  void toggleItemChecked(int itemId) {
    final sections = state.sections.map((section) {
      return section.copyWith(
        items: section.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(isChecked: !item.isChecked);
          }
          return item;
        }).toList(),
      );
    }).toList();

    final allItems = sections.expand((s) => s.items).toList();
    state = state.copyWith(
      sections: sections,
      totalItemCount: allItems.length,
      completedItemCount: allItems.where((i) => i.isChecked).length,
    );

    // 持久化勾选状态
    final checkedMap = <int, bool>{
      for (final item in allItems) item.id: item.isChecked,
    };
    PrefsStorage.saveChecklistChecked(checkedMap);
  }

  /// 设置只看未完成 - 对齐 TravelChecklistViewModel.kt:82-84 setShowOnlyIncomplete
  void setShowOnlyIncomplete(bool show) {
    state = state.copyWith(showOnlyIncomplete: show);
  }
}

/// 旅行清单 ViewModel Provider
final checklistViewModelProvider =
    NotifierProvider<ChecklistViewModel, ChecklistState>(ChecklistViewModel.new);
