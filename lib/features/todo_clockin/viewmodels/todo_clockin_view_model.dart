import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo_models.dart';
import '../repositories/todo_clockin_repository.dart';
import '../services/reminder_scheduler.dart';
import 'todo_clockin_state.dart';

final todoClockInRepositoryProvider = Provider<TodoClockInRepository>(
  (ref) => TodoClockInRepository(),
);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => const OhosReminderScheduler(),
);

final todoClockInViewModelProvider =
    NotifierProvider<TodoClockInViewModel, TodoClockInState>(
  TodoClockInViewModel.new,
);

/// 待办/打卡业务层，刻意不包含 Widget、Dialog 与 OpenHarmony API。
class TodoClockInViewModel extends Notifier<TodoClockInState> {
  late final TodoClockInRepository _repository;
  late final ReminderScheduler _scheduler;

  @override
  TodoClockInState build() {
    _repository = ref.read(todoClockInRepositoryProvider);
    _scheduler = ref.read(reminderSchedulerProvider);
    Future.microtask(_load);
    return TodoClockInState.initial();
  }

  Future<void> _load() async {
    final data = await _repository.load();
    final todos = _refreshTodoStatuses(data.todos);
    state = state.copyWith(
      loading: false,
      todos: todos,
      habits: data.habits,
      records: data.records,
    );
    await _scheduler.restore(todos: todos, habits: data.habits);
  }

  void selectTab(TodoClockInTab tab) {
    state = state.copyWith(
      tab: tab,
      selectedDate:
          tab == TodoClockInTab.clockIn ? DateTime.now() : state.selectedDate,
    );
  }

  void selectDate(DateTime value) =>
      state = state.copyWith(selectedDate: _dateOnly(value));

  void toggleCompletedExpanded() {
    state = state.copyWith(completedExpanded: !state.completedExpanded);
  }

  Future<void> saveTodo({
    required String content,
    required DateTime? reminderAt,
    required TodoRepeatType repeatType,
    TodoItem? original,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final effectiveRepeatType =
        reminderAt == null ? TodoRepeatType.none : repeatType;
    final dueStatus = _todoStatusFor(
      reminderAt,
      TodoStatus.pending,
      effectiveRepeatType,
    );
    final todo = original == null
        ? TodoItem(
            id: now,
            content: trimmed,
            reminderAt: reminderAt,
            repeatType: effectiveRepeatType,
            status: dueStatus,
            createdAt: now,
            updatedAt: now,
          )
        : original.copyWith(
            content: trimmed,
            reminderAt: reminderAt,
            clearReminder: reminderAt == null,
            repeatType: effectiveRepeatType,
            status: dueStatus,
            updatedAt: now,
          );
    final todos = original == null
        ? [todo, ...state.todos]
        : state.todos.map((item) => item.id == todo.id ? todo : item).toList();
    state = state.copyWith(todos: _refreshTodoStatuses(todos));
    await _persist();
    await _scheduler.cancelTodo(todo.id);
    if (todo.status == TodoStatus.pending && todo.reminderAt != null) {
      await _scheduler.scheduleTodo(todo);
    }
  }

  Future<void> completeTodo(TodoItem todo) async {
    if (todo.status == TodoStatus.completed) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final todos = state.todos
        .map((item) => item.id == todo.id
            ? item.copyWith(status: TodoStatus.completed, updatedAt: now)
            : item)
        .toList();
    state = state.copyWith(todos: todos);
    await _persist();
    await _scheduler.cancelTodo(todo.id);
  }

  Future<void> deleteTodo(TodoItem todo) async {
    state = state.copyWith(
        todos: state.todos.where((item) => item.id != todo.id).toList());
    await _persist();
    await _scheduler.cancelTodo(todo.id);
  }

  Future<void> addHabit({
    required String name,
    required String scheduleType,
    required List<String> clockInTimes,
    required DateTime startDate,
    DateTime? endDate,
    List<int> selectedWeekdays = const [],
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final habit = HabitItem(
      id: now,
      name: trimmed,
      scheduleType: scheduleType,
      clockInTimes: [...clockInTimes]..sort(),
      startDate: _dateOnly(startDate),
      endDate: endDate == null ? null : _dateOnly(endDate),
      selectedWeekdays: selectedWeekdays,
      createdAt: now,
    );
    state = state.copyWith(habits: [habit, ...state.habits]);
    await _persist();
    await _scheduler.scheduleHabit(habit);
  }

  Future<void> clockIn(HabitItem habit, String timePoint) async {
    await clockInForDate(habit, timePoint, state.selectedDate);
  }

  /// 前台提醒弹框按触发日期写入打卡记录，避免用户正在浏览其他日期时写错记录。
  Future<void> clockInForDate(
      HabitItem habit, String timePoint, DateTime selectedDate) async {
    final day = _dateOnly(selectedDate);
    final alreadyClocked = state.records.any(
      (record) =>
          record.habitId == habit.id &&
          dateKey(record.date) == dateKey(day) &&
          record.timePoint == timePoint,
    );
    if (alreadyClocked || !isHabitActiveOn(habit, day)) return;
    final record = ClockInRecord(
      id: DateTime.now().microsecondsSinceEpoch,
      habitId: habit.id,
      date: day,
      timePoint: timePoint,
      clockedAt: DateTime.now(),
    );
    state = state.copyWith(records: [...state.records, record]);
    await _persist();
  }

  Future<void> deleteHabit(HabitItem habit) async {
    state = state.copyWith(
      habits: state.habits.where((item) => item.id != habit.id).toList(),
      records:
          state.records.where((record) => record.habitId != habit.id).toList(),
    );
    await _persist();
    await _scheduler.cancelHabit(habit.id);
  }

  bool isHabitActiveOn(HabitItem habit, DateTime date) {
    final current = _dateOnly(date);
    if (current.isBefore(habit.startDate) ||
        (habit.endDate != null && current.isAfter(habit.endDate!))) {
      return false;
    }
    switch (habit.scheduleType) {
      case '周一至周五':
        return current.weekday <= DateTime.friday;
      case '周六至周日':
        return current.weekday >= DateTime.saturday;
      case '指定星期':
        return habit.selectedWeekdays.contains(current.weekday);
      default:
        return true;
    }
  }

  bool isClocked(HabitItem habit, String timePoint) => state.records.any(
        (record) =>
            record.habitId == habit.id &&
            dateKey(record.date) == dateKey(state.selectedDate) &&
            record.timePoint == timePoint,
      );

  Future<void> _persist() => _repository.save(
        TodoClockInData(
            todos: state.todos, habits: state.habits, records: state.records),
      );

  List<TodoItem> _refreshTodoStatuses(List<TodoItem> todos) => todos
      .map((todo) => todo.status == TodoStatus.completed
          ? todo
          : todo.copyWith(
              status:
                  _todoStatusFor(todo.reminderAt, todo.status, todo.repeatType),
            ))
      .toList();

  TodoStatus _todoStatusFor(
    DateTime? reminderAt,
    TodoStatus current, [
    TodoRepeatType repeatType = TodoRepeatType.none,
  ]) {
    if (current == TodoStatus.completed || reminderAt == null) {
      return current == TodoStatus.expired ? TodoStatus.pending : current;
    }
    if (repeatType != TodoRepeatType.none) return TodoStatus.pending;
    return reminderAt.isBefore(DateTime.now())
        ? TodoStatus.expired
        : TodoStatus.pending;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
