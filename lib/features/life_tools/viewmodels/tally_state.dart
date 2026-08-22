// 记账状态 - 对齐 Android ManageActivity.java
import 'package:flutter/foundation.dart';
import '../models/tally_bean.dart';

@immutable
class TallyState {
  /// 记账列表(按 date desc 排序)
  final List<Tally> tallyList;

  /// 编辑弹层是否显示(对齐 dialog_add visibility)
  final bool isDialogVisible;

  /// 是否编辑模式(id!=null 为编辑, 否则新增)
  final bool isEditMode;

  /// 编辑中的记录 id
  final int? editingId;

  /// 表单:日期
  final String date;

  /// 表单:类型(收入/支出)
  final String type;

  /// 表单:金额
  final String money;

  /// 表单:说明
  final String state;

  final bool isLoading;
  final String? error;

  const TallyState({
    this.tallyList = const [],
    this.isDialogVisible = false,
    this.isEditMode = false,
    this.editingId,
    this.date = '',
    this.type = '支出',
    this.money = '',
    this.state = '',
    this.isLoading = false,
    this.error,
  });

  TallyState copyWith({
    List<Tally>? tallyList,
    bool? isDialogVisible,
    bool? isEditMode,
    int? editingId,
    String? date,
    String? type,
    String? money,
    String? state,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TallyState(
      tallyList: tallyList ?? this.tallyList,
      isDialogVisible: isDialogVisible ?? this.isDialogVisible,
      isEditMode: isEditMode ?? this.isEditMode,
      editingId: editingId ?? this.editingId,
      date: date ?? this.date,
      type: type ?? this.type,
      money: money ?? this.money,
      state: state ?? this.state,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
