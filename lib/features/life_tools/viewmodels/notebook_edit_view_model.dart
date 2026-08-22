// 记事本编辑 ViewModel - 对齐 Android RecordActivity.java
// 数据流: init(初始化模式) → save(新增/更新) / delete(编辑模式删除)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notebook_repository.dart';
import '../utils/time_util.dart';
import 'notebook_edit_state.dart';

class NotebookEditViewModel extends Notifier<NotebookEditState> {
  final NotebookRepository _repository = NotebookRepository();

  @override
  NotebookEditState build() {
    return const NotebookEditState();
  }

  /// 初始化 - 对齐 RecordActivity.java:43-57 initData
  /// id==null 为新增模式,否则为编辑模式(预填 content/time)
  void init({int? id, String? content, String? time}) {
    if (id != null) {
      state = NotebookEditState(
        id: id,
        content: content ?? '',
        time: time ?? '',
        isEditMode: true,
      );
    } else {
      state = const NotebookEditState(isEditMode: false);
    }
  }

  /// 更新输入内容
  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  /// 保存 - 对齐 RecordActivity.java:65-100 onClick save
  /// 新增模式 insertNote, 编辑模式 updateNote
  /// 返回 true 表示保存成功(调用方 pop)
  Future<bool> save() async {
    final content = state.content.trim();
    if (content.isEmpty) {
      state = state.copyWith(error: '请输入要添加的内容');
      return false;
    }
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final now = TimeUtil.getNowTime();
      if (state.isEditMode && state.id != null) {
        await _repository.updateNote(state.id!, content, now);
      } else {
        await _repository.insertNote(content, now);
      }
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: '保存失败: $e');
      return false;
    }
  }

  /// 删除 - 对齐 RecordActivity.java note_delete onClick
  /// 仅编辑模式可用
  Future<bool> delete() async {
    if (!state.isEditMode || state.id == null) return false;
    try {
      await _repository.deleteNote(state.id!);
      return true;
    } catch (e) {
      state = state.copyWith(error: '删除失败: $e');
      return false;
    }
  }
}

/// 记事本编辑 ViewModel Provider
final notebookEditViewModelProvider =
    NotifierProvider<NotebookEditViewModel, NotebookEditState>(
        NotebookEditViewModel.new);
