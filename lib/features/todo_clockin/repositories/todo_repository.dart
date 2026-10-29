// 待办仓储 - 对齐 Android com.p.a_b.data.repository.TodoRepository + TodoDao
// Room → SharedPreferences JSON；提醒通知(TodoReminderService)不在迁移范围
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_clockin_entities.dart';
import '../services/reminder_scheduler.dart';
import '../utils/clockin_date_utils.dart';

class TodoRepository {
  TodoRepository();

  /// 系统提醒调度(保存后同步 ReminderAgent，失败向上抛 PlatformException)
  static const OhosReminderScheduler _scheduler = OhosReminderScheduler();

  static const String _keyTodos = 'todo_clockin_todos';
  static const String _keyNextTodoId = 'todo_clockin_next_todo_id';

  bool _initialized = false;

  /// 首次使用时初始化 3 条默认待办(对齐 initializeDefaultTodos)
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyTodos)) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final defaults = <TodoEntity>[
        const TodoEntity(
          id: 0,
          content: '待办可以设置时间提醒',
          reminderTime: '',
          repeatType: 0,
          status: TodoEntity.statusPending,
          isActive: true,
          createdAt: 0,
          updatedAt: 0,
        ),
        const TodoEntity(
          id: 0,
          content: '点击文字可编辑已有待办',
          reminderTime: '',
          repeatType: 0,
          status: TodoEntity.statusPending,
          isActive: true,
          createdAt: 0,
          updatedAt: 0,
        ),
        const TodoEntity(
          id: 0,
          content: '欢迎使用「待办」',
          reminderTime: '',
          repeatType: 0,
          status: TodoEntity.statusPending,
          isActive: true,
          createdAt: 0,
          updatedAt: 0,
        ),
      ].map((e) => e.copyWith(createdAt: now, updatedAt: now)).toList();
      await prefs.setString(_keyTodos, TodoEntity.encodeList(defaults));
    }
  }

  /// 读取全部有效待办，按 createdAt 降序(对齐 TodoDao.getAllTodos)
  Future<List<TodoEntity>> getAllTodos() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyTodos)) return [];
    final list = TodoEntity.decodeList(prefs.getString(_keyTodos)!);
    final active = list.where((e) => e.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active;
  }

  /// 保存待办(带提醒时间) - 对齐 saveTodo，返回新 id，失败返回 -1
  Future<int> saveTodo({
    required String content,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required RepeatType repeatType,
  }) async {
    int todoId;
    try {
      final reminderTime =
          formatReminderTime(year, month, day, hour, minute);
      final expired = isDateTimeExpired(DateTime(year, month, day, hour, minute));
      final status = expired ? TodoEntity.statusExpired : TodoEntity.statusPending;
      final now = DateTime.now().millisecondsSinceEpoch;
      final todo = TodoEntity(
        id: 0,
        content: content.trim(),
        reminderTime: reminderTime,
        repeatType: repeatType.code,
        status: status,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      todoId = await _insertTodo(todo);
      if (status == TodoEntity.statusPending) {
        // scheduleTodo 会在原生侧清理同组旧提醒，再发布新提醒。
        await _scheduler.scheduleTodo(todo.copyWith(id: todoId));
      }
      return todoId;
    } on PlatformException {
      // 数据已保存，原生提醒失败向上抛给 UI 提示。
      rethrow;
    } catch (_) {
      return -1;
    }
  }

  /// 保存无提醒时间待办 - 对齐 saveTodoWithoutTime
  Future<int> saveTodoWithoutTime(String content) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final todo = TodoEntity(
      id: 0,
      content: content.trim(),
      reminderTime: '',
      repeatType: 0,
      status: TodoEntity.statusPending,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    return _insertTodo(todo);
  }

  /// 更新待办(带提醒时间) - 对齐 updateTodo
  Future<bool> updateTodo({
    required int id,
    required String content,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required RepeatType repeatType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _load(prefs);
      final index = list.indexWhere((e) => e.id == id);
      if (index < 0) return false;
      final hadReminder = list[index].reminderTime.isNotEmpty;
      final reminderTime =
          formatReminderTime(year, month, day, hour, minute);
      final expired = isDateTimeExpired(DateTime(year, month, day, hour, minute));
      final status = expired ? TodoEntity.statusExpired : TodoEntity.statusPending;
      final updated = list[index].copyWith(
        content: content.trim(),
        reminderTime: reminderTime,
        repeatType: repeatType.code,
        status: status,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      list[index] = updated;
      await _save(prefs, list);
      if (status == TodoEntity.statusPending) {
        // scheduleTodo 会在原生侧清理同组旧提醒，再发布新提醒。
        await _scheduler.scheduleTodo(updated);
      } else if (hadReminder) {
        // 只有删除已有提醒时才需要单独清理。
        await _scheduler.cancelTodo(id);
      }
      return true;
    } on PlatformException {
      // 数据已保存，原生提醒失败向上抛给 UI 提示。
      rethrow;
    } catch (_) {
      return false;
    }
  }

  /// 清除提醒时间并更新内容 - 对齐 updateTodoWithoutTime
  Future<bool> updateTodoWithoutTime(int id, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _load(prefs);
      final index = list.indexWhere((e) => e.id == id);
      if (index < 0) return false;
      final hadReminder = list[index].reminderTime.isNotEmpty;
      list[index] = list[index].copyWith(
        content: content.trim(),
        reminderTime: '',
        repeatType: 0,
        status: TodoEntity.statusPending,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _save(prefs, list);
      if (hadReminder) {
        // 提醒时间被移除，清理旧系统提醒。
        await _scheduler.cancelTodo(id);
      }
      return true;
    } on PlatformException {
      // 数据已保存，原生提醒失败向上抛给 UI 提示。
      rethrow;
    } catch (_) {
      return false;
    }
  }

  /// 更新待办状态 - 对齐 updateTodoStatus
  Future<bool> updateTodoStatus(int id, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _load(prefs);
      final index = list.indexWhere((e) => e.id == id);
      if (index < 0) return false;
      list[index] = list[index].copyWith(
        status: status,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _save(prefs, list);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<int> _insertTodo(TodoEntity todo) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _load(prefs);
    final nextId = prefs.getInt(_keyNextTodoId) ?? 1;
    final inserted = todo.copyWith(id: nextId);
    list.add(inserted);
    await prefs.setInt(_keyNextTodoId, nextId + 1);
    await _save(prefs, list);
    return nextId;
  }

  List<TodoEntity> _load(SharedPreferences prefs) {
    if (!prefs.containsKey(_keyTodos)) return [];
    return TodoEntity.decodeList(prefs.getString(_keyTodos)!);
  }

  Future<void> _save(SharedPreferences prefs, List<TodoEntity> list) async {
    await prefs.setString(_keyTodos, TodoEntity.encodeList(list));
  }
}
