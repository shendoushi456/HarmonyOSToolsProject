import 'package:flutter/foundation.dart';

/// 对齐 Android TodoEntity.repeatType：不重复、每天、工作日、周末。
enum TodoRepeatType {
  none,
  everyDay,
  weekday,
  weekend,
}

enum TodoStatus {
  pending,
  expired,
  completed,
}

@immutable
class TodoItem {
  final int id;
  final String content;
  final DateTime? reminderAt;
  final TodoRepeatType repeatType;
  final TodoStatus status;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  const TodoItem({
    required this.id,
    required this.content,
    this.reminderAt,
    this.repeatType = TodoRepeatType.none,
    this.status = TodoStatus.pending,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  TodoItem copyWith({
    String? content,
    DateTime? reminderAt,
    bool clearReminder = false,
    TodoRepeatType? repeatType,
    TodoStatus? status,
    bool? isActive,
    int? updatedAt,
  }) {
    return TodoItem(
      id: id,
      content: content ?? this.content,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      repeatType: repeatType ?? this.repeatType,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'reminderAt': reminderAt?.toIso8601String(),
        'repeatType': repeatType.name,
        'status': status.name,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      content: json['content']?.toString() ?? '',
      reminderAt: DateTime.tryParse(json['reminderAt']?.toString() ?? ''),
      repeatType: _repeatTypeFromName(json['repeatType']?.toString()),
      status: _todoStatusFromName(json['status']?.toString()),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 对齐 Android HabitEntity。日期统一使用本地 DateTime，序列化时存 ISO 日期。
@immutable
class HabitItem {
  final int id;
  final String name;
  final String scheduleType;
  final List<String> clockInTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final List<int> selectedWeekdays;
  final int createdAt;

  const HabitItem({
    required this.id,
    required this.name,
    required this.scheduleType,
    required this.clockInTimes,
    required this.startDate,
    this.endDate,
    this.selectedWeekdays = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scheduleType': scheduleType,
        'clockInTimes': clockInTimes,
        'startDate': _dateOnly(startDate),
        'endDate': endDate == null ? null : _dateOnly(endDate!),
        'selectedWeekdays': selectedWeekdays,
        'createdAt': createdAt,
      };

  factory HabitItem.fromJson(Map<String, dynamic> json) {
    final times = json['clockInTimes'] as List? ?? const [];
    final weekdays = json['selectedWeekdays'] as List? ?? const [];
    return HabitItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      scheduleType: json['scheduleType']?.toString() ?? '每天',
      clockInTimes: times.map((value) => value.toString()).toList(),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      selectedWeekdays:
          weekdays.map((value) => (value as num).toInt()).toList(),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
    );
  }
}

@immutable
class ClockInRecord {
  final int id;
  final int habitId;
  final DateTime date;
  final String timePoint;
  final DateTime clockedAt;

  const ClockInRecord({
    required this.id,
    required this.habitId,
    required this.date,
    required this.timePoint,
    required this.clockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'date': _dateOnly(date),
        'timePoint': timePoint,
        'clockedAt': clockedAt.toIso8601String(),
      };

  factory ClockInRecord.fromJson(Map<String, dynamic> json) => ClockInRecord(
        id: (json['id'] as num?)?.toInt() ?? 0,
        habitId: (json['habitId'] as num?)?.toInt() ?? 0,
        date:
            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        timePoint: json['timePoint']?.toString() ?? '',
        clockedAt: DateTime.tryParse(json['clockedAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

String dateKey(DateTime value) => _dateOnly(value);

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

TodoRepeatType _repeatTypeFromName(String? value) {
  return TodoRepeatType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => TodoRepeatType.none,
  );
}

TodoStatus _todoStatusFromName(String? value) {
  return TodoStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => TodoStatus.pending,
  );
}
