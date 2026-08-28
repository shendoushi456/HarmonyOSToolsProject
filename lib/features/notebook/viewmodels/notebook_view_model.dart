import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notebook_entry.dart';
import '../repositories/notebook_repository.dart';

final notebookRepositoryProvider = Provider((ref) => NotebookRepository());
final notebookViewModelProvider =
    NotifierProvider<NotebookViewModel, List<NotebookEntry>>(
        NotebookViewModel.new);

/// 记事本 MVVM 状态层：列表、保存、修改、删除均与页面解耦。
class NotebookViewModel extends Notifier<List<NotebookEntry>> {
  late final NotebookRepository _repository;

  @override
  List<NotebookEntry> build() {
    _repository = ref.read(notebookRepositoryProvider);
    Future.microtask(_load);
    return const [];
  }

  Future<void> _load() async => state = await _repository.load();

  Future<void> upsert({String? id, required String content}) async {
    final now = _formatNow();
    final next = [...state];
    final index = id == null ? -1 : next.indexWhere((entry) => entry.id == id);
    final entry = NotebookEntry(
        id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        content: content,
        time: now);
    if (index >= 0) {
      next[index] = entry;
    } else {
      next.insert(0, entry);
    }
    state = next;
    await _repository.save(next);
  }

  Future<void> remove(String id) async {
    state = state.where((entry) => entry.id != id).toList();
    await _repository.save(state);
  }

  String _formatNow() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}';
  }
}
