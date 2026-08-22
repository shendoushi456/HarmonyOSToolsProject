// 记事本列表状态 - 对齐 Android NotebookActivity 的 ListView 数据状态
import 'package:flutter/foundation.dart';
import '../models/notebook_bean.dart';

@immutable
class NotebookListState {
  /// 记事列表(按 _id desc 排序,对齐 NoteTB.java:70-71)
  final List<NotebookBean> notes;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  const NotebookListState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  NotebookListState copyWith({
    List<NotebookBean>? notes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NotebookListState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
