// QxTodo 待办 ViewModel - 对齐 Android QxTodoViewModel.kt
// 新增置顶、勾选切换、删除，改动即持久化
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/qx_calendar_models.dart';
import '../repositories/qx_todo_repository.dart';

class QxTodoViewModel extends Notifier<QxTodoUiState> {
  final QxTodoRepository _repository = QxTodoRepository();

  @override
  QxTodoUiState build() {
    // 对齐 Android 初始状态 QxTodoUiState(repository.load())
    return const QxTodoUiState();
  }

  /// 异步加载已存待办（Android 在构造时同步 load，Dart 侧首帧后加载）
  Future<void> load() async {
    state = QxTodoUiState(items: await _repository.load());
  }

  /// 对齐 Android addTodo：trim 为空忽略，新待办插入列表头部
  void addTodo(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _updateItems([
      QxTodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: trimmed,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
      ...state.items,
    ]);
  }

  /// 对齐 Android toggleTodo
  void toggleTodo(String id) {
    _updateItems([
      for (final item in state.items)
        if (item.id == id) item.copyWith(done: !item.done) else item
    ]);
  }

  /// 对齐 Android deleteTodo
  void deleteTodo(String id) {
    _updateItems([for (final item in state.items) if (item.id != id) item]);
  }

  void _updateItems(List<QxTodoItem> items) {
    _repository.save(items);
    state = QxTodoUiState(items: items);
  }
}

/// QxTodo 页面 Provider
final qxTodoViewModelProvider =
    NotifierProvider<QxTodoViewModel, QxTodoUiState>(QxTodoViewModel.new);
