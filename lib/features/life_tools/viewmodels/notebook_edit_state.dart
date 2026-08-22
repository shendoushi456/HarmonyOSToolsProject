// 记事本编辑状态 - 对齐 Android RecordActivity.java
import 'package:flutter/foundation.dart';

@immutable
class NotebookEditState {
  /// 编辑的记录 id(null 表示新增模式,对齐 RecordActivity.java:43-57)
  final int? id;

  /// 当前内容
  final String content;

  /// 原始时间(编辑模式显示,对齐 RecordActivity.java tv_time)
  final String time;

  /// 是否编辑模式(id != null 即编辑模式)
  final bool isEditMode;

  /// 是否正在保存
  final bool isSaving;

  /// 错误信息
  final String? error;

  const NotebookEditState({
    this.id,
    this.content = '',
    this.time = '',
    this.isEditMode = false,
    this.isSaving = false,
    this.error,
  });

  NotebookEditState copyWith({
    int? id,
    String? content,
    String? time,
    bool? isEditMode,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return NotebookEditState(
      id: id ?? this.id,
      content: content ?? this.content,
      time: time ?? this.time,
      isEditMode: isEditMode ?? this.isEditMode,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
