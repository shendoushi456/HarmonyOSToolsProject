// 日历页状态 - 对齐 Android CalendarFragment.CalendarScreen 的 Composable 状态
import 'package:flutter/foundation.dart';
import '../models/calendar_tab.dart';
import '../models/expense_entry.dart';
import '../models/history_event.dart';

@immutable
class CalendarState {
  /// 日历选中日期
  final DateTime selectedDate;

  /// 显示月份(该月第一天,对齐 Android YearMonth)
  final DateTime displayMonth;

  /// 当前 Tab(历史/记账)
  final CalendarTab selectedTab;

  /// 历史上的今天事件列表
  final List<HistoryEvent> historyEvents;

  /// 是否正在加载历史数据
  final bool historyLoading;

  /// 记账列表
  final List<ExpenseEntry> expenses;

  const CalendarState({
    required this.selectedDate,
    required this.displayMonth,
    this.selectedTab = CalendarTab.history,
    this.historyEvents = const [],
    this.historyLoading = false,
    this.expenses = const [],
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? displayMonth,
    CalendarTab? selectedTab,
    List<HistoryEvent>? historyEvents,
    bool? historyLoading,
    List<ExpenseEntry>? expenses,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      displayMonth: displayMonth ?? this.displayMonth,
      selectedTab: selectedTab ?? this.selectedTab,
      historyEvents: historyEvents ?? this.historyEvents,
      historyLoading: historyLoading ?? this.historyLoading,
      expenses: expenses ?? this.expenses,
    );
  }
}
