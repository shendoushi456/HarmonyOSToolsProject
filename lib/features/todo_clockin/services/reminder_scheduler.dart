import 'package:flutter/services.dart';

import '../models/todo_models.dart';

/// 系统能力边界：页面和业务规则不依赖具体鸿蒙通知插件。
/// 接入 ArkTS 本地通知后，仅替换该实现，不改动 ViewModel 或 UI。
abstract class ReminderScheduler {
  Future<void> scheduleTodo(TodoItem todo);
  Future<void> cancelTodo(int todoId);
  Future<void> scheduleHabit(HabitItem habit);
  Future<void> cancelHabit(int habitId);

  Future<void> restore({
    required List<TodoItem> todos,
    required List<HabitItem> habits,
  });
}

/// 通过 ArkTS 调用鸿蒙 ReminderAgent。
///
/// ReminderAgent 是系统级定时提醒，应用退到后台或进程被回收后仍可触发。
/// 领域层只传递待办和习惯模型，不依赖任何具体的鸿蒙 API。
class OhosReminderScheduler implements ReminderScheduler {
  const OhosReminderScheduler();

  static const _channel = MethodChannel('com.p.a_b/toolbox_reminder');

  @override
  Future<void> scheduleTodo(TodoItem todo) => _invoke('scheduleTodo', {
        'id': todo.id,
        'content': todo.content,
        'reminderAt': todo.reminderAt?.millisecondsSinceEpoch,
        'repeatType': todo.repeatType.name,
      });

  @override
  Future<void> cancelTodo(int todoId) => _invoke('cancelTodo', {'id': todoId});

  @override
  Future<void> scheduleHabit(HabitItem habit) => _invoke('scheduleHabit', {
        'id': habit.id,
        'name': habit.name,
        'scheduleType': habit.scheduleType,
        'clockInTimes': habit.clockInTimes,
        'startDate': habit.startDate.millisecondsSinceEpoch,
        'endDate': habit.endDate?.millisecondsSinceEpoch,
        'selectedWeekdays': habit.selectedWeekdays,
      });

  @override
  Future<void> cancelHabit(int habitId) =>
      _invoke('cancelHabit', {'id': habitId});

  @override
  Future<void> restore({
    required List<TodoItem> todos,
    required List<HabitItem> habits,
  }) async {
    for (final todo in todos) {
      if (todo.status == TodoStatus.pending && todo.reminderAt != null) {
        await scheduleTodo(todo);
      }
    }
    final today = DateTime.now();
    for (final habit in habits) {
      if (habit.endDate == null || !habit.endDate!.isBefore(today)) {
        await scheduleHabit(habit);
      }
    }
  }

  Future<void> _invoke(String method, Map<String, Object?> arguments) =>
      _channel.invokeMethod<void>(method, arguments);
}

class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<void> cancelHabit(int habitId) async {}

  @override
  Future<void> cancelTodo(int todoId) async {}

  @override
  Future<void> scheduleHabit(HabitItem habit) async {}

  @override
  Future<void> scheduleTodo(TodoItem todo) async {}

  @override
  Future<void> restore({
    required List<TodoItem> todos,
    required List<HabitItem> habits,
  }) async {}
}
