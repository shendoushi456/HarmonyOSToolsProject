// QxCalendar 日历页 UI 状态与待办模型
// 对齐 Android QxUiModels.kt（CalendarDayUi/HistoryEventUi/QxCalendarUiState）
// 与 QxTodoModels.kt（QxTodoItem/QxTodoUiState）、QxHistoryTodayViewModel.QxHistoryTodayUiState
import 'dart:convert';

/// 日历格子日（对齐 Android CalendarDayUi）
class QxCalendarDayUi {
  final String weekLabel;
  final String day;
  final String lunarDay;
  final bool marked;
  final bool selected;
  final bool isToday;
  final bool hasRain;
  final bool inCurrentMonth;
  final String isoDate;

  const QxCalendarDayUi({
    this.weekLabel = '',
    this.day = '',
    this.lunarDay = '',
    this.marked = false,
    this.selected = false,
    this.isToday = false,
    this.hasRain = false,
    this.inCurrentMonth = true,
    this.isoDate = '',
  });

  factory QxCalendarDayUi.blank() =>
      const QxCalendarDayUi(weekLabel: '', day: '', inCurrentMonth: false);
}

/// 历史上的今天事件（对齐 Android HistoryEventUi）
class QxHistoryEventUi {
  final String title;
  final String year;
  final String description;
  final String imageUrl;

  const QxHistoryEventUi({
    required this.title,
    required this.year,
    this.description = '',
    this.imageUrl = '',
  });
}

/// 日历页整体状态（对齐 Android QxCalendarUiState）
class QxCalendarUiState {
  final String title;
  final String monthText;
  final String lunarText;
  final String selectedDateText;
  final String selectedDate;
  final bool expanded;
  final List<QxCalendarDayUi> days;
  final List<QxCalendarDayUi> monthDays;
  final List<QxHistoryEventUi> historyEvents;

  const QxCalendarUiState({
    this.title = '日历',
    this.monthText = '2026.05',
    this.lunarText = '癸卯年腊月初五',
    this.selectedDateText = '2026-05-12',
    this.selectedDate = '2026-05-12',
    this.expanded = false,
    this.days = const [],
    this.monthDays = const [],
    this.historyEvents = const [],
  });
}

/// 待办条目（对齐 Android QxTodoItem）
class QxTodoItem {
  final String id;
  final String text;
  final bool done;
  final int createdAt;

  const QxTodoItem({
    required this.id,
    required this.text,
    this.done = false,
    required this.createdAt,
  });

  QxTodoItem copyWith({bool? done}) {
    return QxTodoItem(
      id: id,
      text: text,
      done: done ?? this.done,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'done': done,
        'createdAt': createdAt,
      };

  factory QxTodoItem.fromJson(Map<String, dynamic> json) {
    return QxTodoItem(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      done: json['done'] as bool? ?? false,
      createdAt:
          (json['createdAt'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 待办页状态（对齐 Android QxTodoUiState）
class QxTodoUiState {
  final List<QxTodoItem> items;

  const QxTodoUiState({this.items = const []});
}

/// 历史上的今天页状态（对齐 Android QxHistoryTodayUiState）
class QxHistoryTodayUiState {
  final bool loading;
  final List<QxHistoryEventUi> events;

  const QxHistoryTodayUiState({
    this.loading = true,
    this.events = const [],
  });

  QxHistoryTodayUiState copyWith({bool? loading, List<QxHistoryEventUi>? events}) {
    return QxHistoryTodayUiState(
      loading: loading ?? this.loading,
      events: events ?? this.events,
    );
  }
}

/// 待办列表 JSON 序列化辅助（对齐 Android Gson TypeToken<List<QxTodoItem>>）
String qxTodoListToJson(List<QxTodoItem> items) {
  return jsonEncode(items.map((e) => e.toJson()).toList());
}

List<QxTodoItem> qxTodoListFromJson(String jsonString) {
  try {
    final list = jsonDecode(jsonString) as List;
    return list
        .map((e) => QxTodoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}
