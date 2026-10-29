// 系统能力边界：页面和业务规则不依赖具体鸿蒙通知插件。
// 接入 ArkTS 本地通知后，仅替换该实现，不改动 Repository 或 UI。
// 移植自提交 04d34a5b（糖压管家宝 添加系统提醒），适配本分支实体模型。
import 'package:flutter/services.dart';

import '../models/todo_clockin_entities.dart';
import '../utils/clockin_date_utils.dart';

/// 领域提醒调度接口
abstract class ReminderScheduler {
  Future<void> scheduleTodo(TodoEntity todo);
  Future<void> cancelTodo(int todoId);
  Future<void> scheduleHabit(HabitEntity habit);
  Future<void> cancelHabit(int habitId);

  Future<void> restore({
    required List<TodoEntity> todos,
    required List<HabitEntity> habits,
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
  Future<void> scheduleTodo(TodoEntity todo) => _invoke('scheduleTodo', {
        'id': todo.id,
        'content': todo.content,
        'reminderAt': parseReminderTime(todo.reminderTime)?.millisecondsSinceEpoch,
        'repeatType': RepeatType.fromCode(todo.repeatType).name,
      });

  @override
  Future<void> cancelTodo(int todoId) => _invoke('cancelTodo', {'id': todoId});

  @override
  Future<void> scheduleHabit(HabitEntity habit) => _invoke('scheduleHabit', {
        'id': habit.id,
        'name': habit.name,
        'scheduleType': habit.scheduleType,
        'clockInTimes':
            (habit.clockInTimes ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'startDate': parseYMD(habit.startDate)?.millisecondsSinceEpoch,
        'endDate': parseYMD(habit.endDate ?? '')?.millisecondsSinceEpoch,
        'selectedWeekdays': <int>[],
      });

  @override
  Future<void> cancelHabit(int habitId) =>
      _invoke('cancelHabit', {'id': habitId});

  @override
  Future<void> restore({
    required List<TodoEntity> todos,
    required List<HabitEntity> habits,
  }) async {
    for (final todo in todos) {
      if (todo.status == TodoEntity.statusPending &&
          todo.reminderTime.isNotEmpty) {
        await scheduleTodo(todo);
      }
    }
    final today = DateTime.now();
    for (final habit in habits) {
      final endDate = parseYMD(habit.endDate ?? '');
      if (endDate == null || !endDate.isBefore(today)) {
        await scheduleHabit(habit);
      }
    }
  }

  Future<void> _invoke(String method, Map<String, Object?> arguments) =>
      _channel.invokeMethod<void>(method, arguments);
}

/// 与系统通知开关交互的最小边界。提醒业务仍由 [ReminderScheduler] 负责。
class ReminderNotificationSettings {
  ReminderNotificationSettings._();

  static const _channel = MethodChannel('com.p.a_b/toolbox_reminder');

  static Future<bool> isEnabled() async =>
      await _channel.invokeMethod<bool>('isNotificationEnabled') ?? false;

  /// 弹出鸿蒙系统的通知授权提示；用户拒绝时由调用方保留已保存的数据。
  static Future<void> requestEnable() =>
      _channel.invokeMethod<void>('requestEnableNotification');

  static Future<void> openSettings() =>
      _channel.invokeMethod<void>('openNotificationSettings');
}

class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<void> cancelHabit(int habitId) async {}

  @override
  Future<void> cancelTodo(int todoId) async {}

  @override
  Future<void> scheduleHabit(HabitEntity habit) async {}

  @override
  Future<void> scheduleTodo(TodoEntity todo) async {}

  @override
  Future<void> restore({
    required List<TodoEntity> todos,
    required List<HabitEntity> habits,
  }) async {}
}
