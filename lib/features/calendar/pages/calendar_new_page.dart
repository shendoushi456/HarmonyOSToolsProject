// 日历页 - 顶层容器 - 对齐 Android NearbyFragment
// 管理状态:displayMonth/selectedDate/almanac + 黄历 API 加载
// 城市切换在 tab0 天气页进行,日历页独立(不复用 weatherViewModelProvider)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chinese_calendar_bean.dart';
import '../services/calendar_almanac_service.dart';
import 'calendar_new_child_page.dart';

class CalendarNewPage extends ConsumerStatefulWidget {
  const CalendarNewPage({super.key});

  @override
  ConsumerState<CalendarNewPage> createState() => _CalendarNewPageState();
}

class _CalendarNewPageState extends ConsumerState<CalendarNewPage> {
  final CalendarAlmanacService _almanacService = CalendarAlmanacService();

  /// 显示的月份（该月第一天）- 对齐 Android calendarYear/calendarMonth
  late DateTime _displayMonth;

  /// 当前选中日期 - 对齐 Android calendarYear/calendarMonth/calendarDay
  late DateTime _selectedDate;

  /// 黄历数据 - 对齐 Android calendarInfo (ChineseCalendarBean?)
  ChineseCalendarBean? _almanac;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    // 初始加载今日黄历 - 对齐 Android CalendarScreenWithDirectInflation 初始化时 loadCalendarInfo
    _loadAlmanac(_selectedDate);
  }

  /// 加载黄历 - 对齐 Android loadCalendarInfo(dateStr) { calendarInfo = info }
  Future<void> _loadAlmanac(DateTime date) async {
    final almanac = await _almanacService.fetchAlmanac(date);
    if (!mounted) return;
    setState(() {
      _almanac = almanac;
    });
  }

  /// 选中日期 - 对齐 Android onCalendarSelect { calendarYear/Month/Day = ...; loadCalendarInfo }
  void _onSelectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      // 如果选中日期不在当前显示月份,切换月份
      if (date.year != _displayMonth.year || date.month != _displayMonth.month) {
        _displayMonth = DateTime(date.year, date.month, 1);
      }
    });
    _loadAlmanac(date);
  }

  /// 上一月 - 对齐 Android rilileft.setOnClickListener { scrollToPre }
  void _previousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  /// 下一月 - 对齐 Android riliright.setOnClickListener { scrollToNext }
  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalendarNewChildPage(
      displayMonth: _displayMonth,
      selectedDate: _selectedDate,
      almanac: _almanac,
      onPreviousMonth: _previousMonth,
      onNextMonth: _nextMonth,
      onSelectDate: _onSelectDate,
    );
  }
}
