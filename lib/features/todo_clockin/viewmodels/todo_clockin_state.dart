import 'package:flutter/foundation.dart';

import '../models/todo_models.dart';

enum TodoClockInTab { todo, clockIn }

@immutable
class TodoClockInState {
  final bool loading;
  final TodoClockInTab tab;
  final DateTime selectedDate;
  final List<TodoItem> todos;
  final List<HabitItem> habits;
  final List<ClockInRecord> records;
  final bool completedExpanded;

  const TodoClockInState({
    required this.loading,
    required this.tab,
    required this.selectedDate,
    required this.todos,
    required this.habits,
    required this.records,
    required this.completedExpanded,
  });

  factory TodoClockInState.initial() => TodoClockInState(
        loading: true,
        tab: TodoClockInTab.todo,
        selectedDate: DateTime.now(),
        todos: const [],
        habits: const [],
        records: const [],
        completedExpanded: true,
      );

  TodoClockInState copyWith({
    bool? loading,
    TodoClockInTab? tab,
    DateTime? selectedDate,
    List<TodoItem>? todos,
    List<HabitItem>? habits,
    List<ClockInRecord>? records,
    bool? completedExpanded,
  }) =>
      TodoClockInState(
        loading: loading ?? this.loading,
        tab: tab ?? this.tab,
        selectedDate: selectedDate ?? this.selectedDate,
        todos: todos ?? this.todos,
        habits: habits ?? this.habits,
        records: records ?? this.records,
        completedExpanded: completedExpanded ?? this.completedExpanded,
      );
}
