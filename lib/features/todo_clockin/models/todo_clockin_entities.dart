// 待办/打卡数据模型 - 对齐 Android com.p.a_b.data.entity
// TodoEntity.kt / HabitEntity.kt / ClockInRecordEntity.kt
// 持久化采用 SharedPreferences JSON(替代安卓 Room，字段与行为保持一致)

import 'dart:convert';

import 'package:flutter/foundation.dart';

/// 重复类型 - 对齐 DateTimePickerDialog.RepeatType
enum RepeatType {
  none('不重复', 0),
  everyDay('每天', 1),
  weekday('周一至周五', 2),
  weekend('周六至周日', 3);

  const RepeatType(this.displayText, this.code);

  final String displayText;
  final int code;

  static RepeatType fromCode(int code) {
    switch (code) {
      case 1:
        return RepeatType.everyDay;
      case 2:
        return RepeatType.weekday;
      case 3:
        return RepeatType.weekend;
      default:
        return RepeatType.none;
    }
  }
}

/// 待办事项 - 对齐 Android TodoEntity(tableName = "todos")
@immutable
class TodoEntity {
  static const String statusPending = '未过期';
  static const String statusExpired = '已过期';
  static const String statusCompleted = '已完成';

  const TodoEntity({
    required this.id,
    required this.content,
    required this.reminderTime,
    required this.repeatType,
    this.status = statusPending,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id; // 自增主键
  final String content; // 待办事项内容
  final String reminderTime; // 提醒时间，格式："2024-10-15 14:30"，空串表示无提醒
  final int repeatType; // 重复类型：0=不重复, 1=每天, 2=周一至周五, 3=周六至周日
  final String status; // 状态：未过期、已过期、已完成
  final bool isActive; // 是否有效(软删除标记)
  final int createdAt; // 毫秒时间戳
  final int updatedAt;

  TodoEntity copyWith({
    int? id,
    String? content,
    String? reminderTime,
    int? repeatType,
    String? status,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatType: repeatType ?? this.repeatType,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'reminderTime': reminderTime,
        'repeatType': repeatType,
        'status': status,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory TodoEntity.fromJson(Map<String, dynamic> json) => TodoEntity(
        id: (json['id'] as num).toInt(),
        content: json['content'] as String? ?? '',
        reminderTime: json['reminderTime'] as String? ?? '',
        repeatType: (json['repeatType'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? statusPending,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
        updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
      );

  static String encodeList(List<TodoEntity> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<TodoEntity> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TodoEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// 习惯 - 对齐 Android HabitEntity(tableName = "habits")
@immutable
class HabitEntity {
  const HabitEntity({
    required this.id,
    required this.name,
    this.scheduleType = '每天',
    this.clockInTimes,
    required this.startDate,
    this.endDate,
    this.lastClockInDate,
    this.lastClockInTime,
    this.selectedWeekDays,
    required this.createdAt,
  });

  final int id;
  final String name; // 习惯名称
  final String scheduleType; // 定时方式：每天/周一至周五/周六至周日 等
  final String? clockInTimes; // 打卡时间，多个用逗号分隔："07:00,12:00,19:00"
  final String startDate; // 开始日期："2026年10月08日"
  final String? endDate; // 结束日期，null/无期限
  final String? lastClockInDate;
  final String? lastClockInTime;
  final String? selectedWeekDays; // 选中的星期(如"一、三、五")
  final int createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scheduleType': scheduleType,
        'clockInTimes': clockInTimes,
        'startDate': startDate,
        'endDate': endDate,
        'lastClockInDate': lastClockInDate,
        'lastClockInTime': lastClockInTime,
        'selectedWeekDays': selectedWeekDays,
        'createdAt': createdAt,
      };

  factory HabitEntity.fromJson(Map<String, dynamic> json) => HabitEntity(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        scheduleType: json['scheduleType'] as String? ?? '每天',
        clockInTimes: json['clockInTimes'] as String?,
        startDate: json['startDate'] as String? ?? '',
        endDate: json['endDate'] as String?,
        lastClockInDate: json['lastClockInDate'] as String?,
        lastClockInTime: json['lastClockInTime'] as String?,
        selectedWeekDays: json['selectedWeekDays'] as String?,
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      );

  static String encodeList(List<HabitEntity> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<HabitEntity> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => HabitEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// 打卡记录 - 对齐 Android ClockInRecordEntity(tableName = "clock_in_records")
@immutable
class ClockInRecordEntity {
  const ClockInRecordEntity({
    required this.id,
    required this.habitId,
    required this.date,
    this.timePoint,
    this.clockInTime,
    required this.createdAt,
  });

  final int id;
  final int habitId; // 关联的习惯ID
  final String date; // 打卡日期："2026年10月08日"
  final String? timePoint; // 具体时间点："08:00"
  final String? clockInTime; // 实际打卡时间："HH:mm"
  final int createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'date': date,
        'timePoint': timePoint,
        'clockInTime': clockInTime,
        'createdAt': createdAt,
      };

  factory ClockInRecordEntity.fromJson(Map<String, dynamic> json) =>
      ClockInRecordEntity(
        id: (json['id'] as num).toInt(),
        habitId: (json['habitId'] as num).toInt(),
        date: json['date'] as String? ?? '',
        timePoint: json['timePoint'] as String?,
        clockInTime: json['clockInTime'] as String?,
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      );

  static String encodeList(List<ClockInRecordEntity> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ClockInRecordEntity> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ClockInRecordEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
