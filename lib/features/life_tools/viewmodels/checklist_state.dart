// 旅行清单状态 - 对齐 Android TravelChecklistViewModel.kt:26-31 TravelChecklistUiState
import 'package:flutter/foundation.dart';
import '../models/checklist_item.dart';

@immutable
class ChecklistState {
  /// 清单分组
  final List<ChecklistSection> sections;

  /// 是否只看未完成
  final bool showOnlyIncomplete;

  /// 总项数
  final int totalItemCount;

  /// 已完成项数
  final int completedItemCount;

  /// 错误信息(预留)
  final String? error;

  const ChecklistState({
    this.sections = const [],
    this.showOnlyIncomplete = false,
    this.totalItemCount = 0,
    this.completedItemCount = 0,
    this.error,
  });

  ChecklistState copyWith({
    List<ChecklistSection>? sections,
    bool? showOnlyIncomplete,
    int? totalItemCount,
    int? completedItemCount,
    String? error,
    bool clearError = false,
  }) {
    return ChecklistState(
      sections: sections ?? this.sections,
      showOnlyIncomplete: showOnlyIncomplete ?? this.showOnlyIncomplete,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      completedItemCount: completedItemCount ?? this.completedItemCount,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
