import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notebook_entry.dart';

/// 轻量本地仓储。Android 使用 SQLite；Flutter/OHOS 先用共享偏好保存同等数据模型。
class NotebookRepository {
  static const _storageKey = 'toolbox_notebook_entries';

  Future<List<NotebookEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? const [];
    return raw.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return NotebookEntry(
        id: map['id'] as String,
        content: map['content'] as String,
        time: map['time'] as String,
      );
    }).toList();
  }

  Future<void> save(List<NotebookEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _storageKey,
        entries
            .map((entry) => jsonEncode({
                  'id': entry.id,
                  'content': entry.content,
                  'time': entry.time,
                }))
            .toList());
  }
}
