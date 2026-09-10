// QxTodo 待办数据仓库 - 对齐 Android QxTodoRepository.kt
// SharedPreferences("qx_todo_store")/items 的 JSON 列表存取，
// Flutter 侧以 PrefsStorage 的独立 key 承接（ohos shared_preferences 为单文件）
import '../../../core/storage/prefs_storage.dart';
import '../models/qx_calendar_models.dart';

class QxTodoRepository {
  /// 对齐 Android KEY_ITEMS = "items"（prefs 文件名 qx_todo_store）
  static const String _keyItems = 'qx_todo_store_items';

  /// 读取待办列表（对齐 Android load：解析失败返回空）
  Future<List<QxTodoItem>> load() async {
    final json = PrefsStorage.getString(_keyItems);
    if (json == null) return const [];
    return qxTodoListFromJson(json);
  }

  /// 保存待办列表（对齐 Android save）
  Future<void> save(List<QxTodoItem> items) async {
    await PrefsStorage.setString(_keyItems, qxTodoListToJson(items));
  }
}
