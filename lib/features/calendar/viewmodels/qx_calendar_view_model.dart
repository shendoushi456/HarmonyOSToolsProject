// QxCalendar 日历 ViewModel - 对齐 Android QxCalendarViewModel.kt
// 周条/月格切换、日期选择、雨日标记、历史上的今天加载
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/lunar_util.dart';
import '../models/qx_calendar_models.dart';
import '../repositories/qx_calendar_repository.dart';

class QxCalendarViewModel extends Notifier<QxCalendarUiState> {
  final QxCalendarRepository _repository = QxCalendarRepository();

  DateTime _selectedDate = DateTime.now();
  DateTime _displayedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  bool _expanded = false;
  Set<DateTime> _rainDates = {};
  List<QxHistoryEventUi> _historyEvents = [];

  @override
  QxCalendarUiState build() {
    _selectedDate = _dateOnly(DateTime.now());
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _expanded = false;
    _rainDates = {};
    _historyEvents = [];
    // 对齐 Android init { refresh() }
    Future.microtask(refresh);
    return _buildState();
  }

  /// 对齐 Android refresh：先发布当前状态，再异步刷新雨日与历史事件
  Future<void> refresh() async {
    _publish();
    _refreshRainDates();
    _refreshHistory();
  }

  /// 对齐 Android toggleExpanded
  void toggleExpanded() {
    _expanded = !_expanded;
    _publish();
  }

  /// 对齐 Android selectDate
  void selectDate(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return;
    _selectedDate = _dateOnly(parsed);
    _displayedMonth = DateTime(parsed.year, parsed.month);
    _publish();
    _refreshHistory();
  }

  /// 对齐 Android previousMonth
  void previousMonth() {
    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    _publish();
  }

  /// 对齐 Android nextMonth
  void nextMonth() {
    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    _publish();
  }

  Future<void> _refreshRainDates() async {
    _rainDates = await _repository.loadRainDates();
    _publish();
  }

  Future<void> _refreshHistory() async {
    _historyEvents =
        await _repository.loadHistoryToday(_selectedDate, limit: 20);
    _publish();
  }

  void _publish() {
    state = _buildState();
  }

  /// 对齐 Android buildState
  QxCalendarUiState _buildState() {
    final today = _dateOnly(DateTime.now());
    final sameMonth = _selectedDate.year == _displayedMonth.year &&
        _selectedDate.month == _displayedMonth.month;
    final weekAnchor =
        sameMonth ? _selectedDate : DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    // Android dayOfWeek.value: 周一=1..周日=7
    final weekStart = weekAnchor.subtract(Duration(days: weekAnchor.weekday - 1));
    final days =
        List.generate(7, (offset) => _calendarDay(weekStart.add(Duration(days: offset)), today));

    return QxCalendarUiState(
      monthText:
          '${_displayedMonth.year}.${_displayedMonth.month.toString().padLeft(2, '0')}',
      lunarText: _lunarText(_selectedDate),
      selectedDateText: _formatIso(_selectedDate),
      selectedDate: _formatIso(_selectedDate),
      expanded: _expanded,
      days: days,
      monthDays: _monthGrid(_displayedMonth, today),
      historyEvents: _historyEvents,
    );
  }

  /// 对齐 Android monthGrid：前置空格 + 当月日期 + 补齐 35/42 格
  List<QxCalendarDayUi> _monthGrid(DateTime month, DateTime today) {
    final firstDay = DateTime(month.year, month.month, 1);
    final cells = <QxCalendarDayUi>[
      for (var i = 0; i < firstDay.weekday - 1; i++) QxCalendarDayUi.blank(),
    ];
    final lengthOfMonth = DateTime(month.year, month.month + 1, 0).day;
    for (var day = 1; day <= lengthOfMonth; day++) {
      cells.add(_calendarDay(DateTime(month.year, month.month, day), today));
    }
    final targetSize = cells.length <= 35 ? 35 : 42;
    while (cells.length < targetSize) {
      cells.add(QxCalendarDayUi.blank());
    }
    return cells;
  }

  /// 对齐 Android calendarDay
  QxCalendarDayUi _calendarDay(DateTime date, DateTime today) {
    final dateOnly = _dateOnly(date);
    final hasRain = _rainDates.contains(dateOnly);
    return QxCalendarDayUi(
      weekLabel: _weekShort(dateOnly),
      day: dateOnly.day.toString(),
      lunarDay: _lunarDayText(dateOnly),
      marked: hasRain,
      selected: dateOnly == _selectedDate,
      isToday: dateOnly == today,
      hasRain: hasRain,
      inCurrentMonth: true,
      isoDate: _formatIso(dateOnly),
    );
  }

  /// 对齐 Android weekShort
  String _weekShort(DateTime date) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[date.weekday - 1];
  }

  /// 对齐 Android lunarText："干支年+农历月日"，如"癸卯年二月初一"
  String _lunarText(DateTime date) {
    final lunar = Lunar.fromDateTime(date);
    return '${lunar.cyclical()}年$lunar';
  }

  /// 对齐 Android lunarDayText：初一返回月名（含"月"），其余返回日名
  String _lunarDayText(DateTime date) {
    final lunar = Lunar.fromDateTime(date).toString();
    final monthIndex = lunar.lastIndexOf('月');
    if (monthIndex < 0) return lunar;
    final monthText = lunar.substring(0, monthIndex + 1);
    final dayText = lunar.substring(monthIndex + 1);
    return dayText == '初一' ? monthText : dayText;
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _formatIso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// QxCalendar 页面 Provider
final qxCalendarViewModelProvider =
    NotifierProvider<QxCalendarViewModel, QxCalendarUiState>(
        QxCalendarViewModel.new);
