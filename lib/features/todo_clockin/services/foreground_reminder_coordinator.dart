import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo_models.dart';
import '../viewmodels/todo_clockin_state.dart';

/// 前台提醒的领域状态。后台及锁屏场景仍由鸿蒙 ReminderAgent 负责状态栏通知。
enum ForegroundReminderKind { todo, habit }

class ForegroundReminderPrompt {
  final ForegroundReminderKind kind;
  final int itemId;
  final String title;
  final String? timePoint;
  final DateTime dueAt;

  const ForegroundReminderPrompt({
    required this.kind,
    required this.itemId,
    required this.title,
    required this.timePoint,
    required this.dueAt,
  });

  String get occurrenceKey =>
      '${kind.name}:$itemId:${dueAt.year}-${dueAt.month}-${dueAt.day}-${dueAt.hour}-${dueAt.minute}';
}

class ForegroundReminderState {
  final ForegroundReminderPrompt? current;
  final List<ForegroundReminderPrompt> pending;

  const ForegroundReminderState({required this.current, required this.pending});
  const ForegroundReminderState.initial()
      : current = null,
        pending = const [];
}

final foregroundReminderCoordinatorProvider =
    NotifierProvider<ForegroundReminderCoordinator, ForegroundReminderState>(
        ForegroundReminderCoordinator.new);

/// 将到点的待办/打卡项目排队交给 UI 弹框。
///
/// 提醒窗口保留 90 秒，覆盖前台定时器的正常调度误差；每个项目每分钟只展示一次。
class ForegroundReminderCoordinator extends Notifier<ForegroundReminderState> {
  final Set<String> _delivered = <String>{};

  @override
  ForegroundReminderState build() => const ForegroundReminderState.initial();

  void evaluate(TodoClockInState source, DateTime now) {
    if (source.loading) {
      return;
    }
    final candidates = <ForegroundReminderPrompt>[
      ..._dueTodos(source.todos, now),
      ..._dueHabits(source.habits, now),
    ]..sort((left, right) => left.dueAt.compareTo(right.dueAt));
    if (candidates.isEmpty) {
      return;
    }

    final additions = candidates
        .where((prompt) => _delivered.add(prompt.occurrenceKey))
        .toList();
    if (additions.isEmpty) {
      return;
    }
    if (state.current == null) {
      state = ForegroundReminderState(
          current: additions.first, pending: additions.skip(1).toList());
      return;
    }
    state = ForegroundReminderState(
        current: state.current, pending: [...state.pending, ...additions]);
  }

  void dismissCurrent() {
    if (state.pending.isEmpty) {
      state = const ForegroundReminderState.initial();
      return;
    }
    state = ForegroundReminderState(
        current: state.pending.first, pending: state.pending.skip(1).toList());
  }

  List<ForegroundReminderPrompt> _dueTodos(List<TodoItem> todos, DateTime now) {
    return todos
        .where((item) => item.isActive && item.status == TodoStatus.pending)
        .map((item) {
          final reminderAt = item.reminderAt;
          if (reminderAt == null) {
            return null;
          }
          final dueAt = _todoDueAt(item, now);
          if (dueAt == null || !_isJustDue(dueAt, now)) {
            return null;
          }
          return ForegroundReminderPrompt(
              kind: ForegroundReminderKind.todo,
              itemId: item.id,
              title: item.content,
              timePoint: _timeLabel(dueAt),
              dueAt: dueAt);
        })
        .whereType<ForegroundReminderPrompt>()
        .toList();
  }

  List<ForegroundReminderPrompt> _dueHabits(
      List<HabitItem> habits, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return habits.expand((habit) {
      if (!_isHabitActiveOn(habit, today)) {
        return const <ForegroundReminderPrompt>[];
      }
      return habit.clockInTimes.map((time) {
        final dueAt = _dateAtTime(today, time);
        if (dueAt == null || !_isJustDue(dueAt, now)) {
          return null;
        }
        return ForegroundReminderPrompt(
            kind: ForegroundReminderKind.habit,
            itemId: habit.id,
            title: habit.name,
            timePoint: time,
            dueAt: dueAt);
      }).whereType<ForegroundReminderPrompt>();
    }).toList();
  }

  DateTime? _todoDueAt(TodoItem todo, DateTime now) {
    final reminderAt = todo.reminderAt!;
    if (todo.repeatType == TodoRepeatType.none) {
      return reminderAt;
    }
    final today = DateTime(now.year, now.month, now.day);
    if (today.isBefore(
        DateTime(reminderAt.year, reminderAt.month, reminderAt.day))) {
      return null;
    }
    final weekday = today.weekday;
    if (todo.repeatType == TodoRepeatType.weekday &&
        weekday > DateTime.friday) {
      return null;
    }
    if (todo.repeatType == TodoRepeatType.weekend &&
        weekday < DateTime.saturday) {
      return null;
    }
    return DateTime(
        today.year, today.month, today.day, reminderAt.hour, reminderAt.minute);
  }

  bool _isHabitActiveOn(HabitItem habit, DateTime day) {
    if (day.isBefore(_dateOnly(habit.startDate)) ||
        (habit.endDate != null && day.isAfter(_dateOnly(habit.endDate!)))) {
      return false;
    }
    switch (habit.scheduleType) {
      case '周一至周五':
        return day.weekday <= DateTime.friday;
      case '周六至周日':
        return day.weekday >= DateTime.saturday;
      case '指定星期':
        return habit.selectedWeekdays.contains(day.weekday);
      default:
        return true;
    }
  }

  bool _isJustDue(DateTime dueAt, DateTime now) {
    final elapsed = now.difference(dueAt);
    return !elapsed.isNegative && elapsed <= const Duration(seconds: 90);
  }

  DateTime? _dateAtTime(DateTime day, String time) {
    final parts = time.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _timeLabel(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
