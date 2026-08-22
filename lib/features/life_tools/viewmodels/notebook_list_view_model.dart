// 记事本列表 ViewModel - 对齐 Android NotebookActivity.java
// 数据流: 进入页面 loadNotes → state.notes; 长按删除 deleteNote → 刷新列表
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notebook_repository.dart';
import 'notebook_list_state.dart';

class NotebookListViewModel extends Notifier<NotebookListState> {
  final NotebookRepository _repository = NotebookRepository();

  @override
  NotebookListState build() {
    // 进入页面立即加载 - 对齐 NotebookActivity.java:55-101 initData
    Future.microtask(loadNotes);
    return const NotebookListState(isLoading: true);
  }

  /// 加载全部记事 - 对齐 NotebookActivity.java:103-111 showQueryData
  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.queryNotes();
      state = state.copyWith(notes: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 删除记事 - 对齐 NotebookActivity.java 长按删除
  Future<void> deleteNote(int id) async {
    await _repository.deleteNote(id);
    await loadNotes();
  }
}

/// 记事本列表 ViewModel Provider
final notebookListViewModelProvider =
    NotifierProvider<NotebookListViewModel, NotebookListState>(
        NotebookListViewModel.new);
