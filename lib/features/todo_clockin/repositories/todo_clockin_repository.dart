import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_models.dart';

/// 数据访问层。存储格式独立于 UI，后续可无感替换为鸿蒙数据库实现。
class TodoClockInRepository {
  static const _storageKey = 'toolbox_todo_clockin_v1';

  Future<TodoClockInData> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return TodoClockInData.initial();
      return TodoClockInData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return TodoClockInData.initial();
    }
  }

  Future<void> save(TodoClockInData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data.toJson()));
  }
}

class TodoClockInData {
  final List<TodoItem> todos;
  final List<HabitItem> habits;
  final List<ClockInRecord> records;

  const TodoClockInData({
    required this.todos,
    required this.habits,
    required this.records,
  });

  factory TodoClockInData.initial() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return TodoClockInData(
      todos: [
        TodoItem(
            id: now + 1, content: '待办可以设置时间提醒', createdAt: now, updatedAt: now),
        TodoItem(
            id: now + 2,
            content: '点击文字可编辑已有待办',
            createdAt: now - 1,
            updatedAt: now - 1),
        TodoItem(
            id: now + 3,
            content: '欢迎使用「待办」',
            createdAt: now - 2,
            updatedAt: now - 2),
      ],
      habits: const [],
      records: const [],
    );
  }

  TodoClockInData copyWith({
    List<TodoItem>? todos,
    List<HabitItem>? habits,
    List<ClockInRecord>? records,
  }) =>
      TodoClockInData(
        todos: todos ?? this.todos,
        habits: habits ?? this.habits,
        records: records ?? this.records,
      );

  Map<String, dynamic> toJson() => {
        'todos': todos.map((item) => item.toJson()).toList(),
        'habits': habits.map((item) => item.toJson()).toList(),
        'records': records.map((item) => item.toJson()).toList(),
      };

  factory TodoClockInData.fromJson(Map<String, dynamic> json) {
    List<T> mapList<T>(String key, T Function(Map<String, dynamic>) factory) {
      final values = json[key] as List? ?? const [];
      return values
          .map((value) => factory(value as Map<String, dynamic>))
          .toList();
    }

    return TodoClockInData(
      todos: mapList('todos', TodoItem.fromJson),
      habits: mapList('habits', HabitItem.fromJson),
      records: mapList('records', ClockInRecord.fromJson),
    );
  }
}
