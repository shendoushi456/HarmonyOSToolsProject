// 日历页 ViewModel - 对齐 Android CalendarFragment
// 管理日历选中日期、月份切换、历史数据加载、记账 CRUD
// 弹窗显示由 CalendarPage 直接处理,不通过状态触发(避免时序问题)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_tab.dart';
import '../models/expense_entry.dart';
import '../repositories/expense_repository.dart';
import '../services/history_service.dart';
import 'calendar_state.dart';

class CalendarViewModel extends Notifier<CalendarState> {
  final HistoryService _historyService = HistoryService();
  final ExpenseRepository _expenseRepo = ExpenseRepository();

  @override
  CalendarState build() {
    final now = DateTime.now();
    // 初始状态:今天,本月,history tab,历史数据 loading
    final initState = CalendarState(
      selectedDate: now,
      displayMonth: DateTime(now.year, now.month, 1),
      historyLoading: true,
    );
    // 异步加载记账数据和历史数据
    Future.microtask(() async {
      await _loadExpenses();
      await _loadHistory(now);
    });
    return initState;
  }

  /// 加载记账数据 - 对齐 Android CalendarFragment loadExpenses
  Future<void> _loadExpenses() async {
    final expenses = await _expenseRepo.load();
    state = state.copyWith(expenses: expenses);
  }

  /// 加载"历史上的今天" - 对齐 Android loadRealHistory(today)
  /// 注意:历史数据基于今天,不跟随日历选中日期(对齐原版行 109-114)
  Future<void> _loadHistory(DateTime date) async {
    state = state.copyWith(historyLoading: true);
    final events = await _historyService.fetchHistory(date);
    state = state.copyWith(historyEvents: events, historyLoading: false);
  }

  /// 选择日期 - 对齐 Android onSelectDate
  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      displayMonth: DateTime(date.year, date.month, 1),
    );
  }

  /// 上一月 - 对齐 Android onPrevious
  /// 切换月份时 selectedDate 设为新月第一天
  void previousMonth() {
    final newMonth =
        DateTime(state.displayMonth.year, state.displayMonth.month - 1, 1);
    state = state.copyWith(displayMonth: newMonth, selectedDate: newMonth);
  }

  /// 下一月 - 对齐 Android onNext
  void nextMonth() {
    final newMonth =
        DateTime(state.displayMonth.year, state.displayMonth.month + 1, 1);
    state = state.copyWith(displayMonth: newMonth, selectedDate: newMonth);
  }

  /// 切换 Tab - 对齐 Android onTabSelected
  void selectTab(CalendarTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  /// 添加记账 - 对齐 Android onAdd 回调
  Future<void> addExpense(ExpenseEntry entry) async {
    final expenses = [...state.expenses, entry];
    await _expenseRepo.save(expenses);
    state = state.copyWith(expenses: expenses);
  }

  /// 修改记账 - 对齐 Android onModify 回调
  Future<void> modifyExpense(ExpenseEntry entry) async {
    final expenses =
        state.expenses.map((e) => e.id == entry.id ? entry : e).toList();
    await _expenseRepo.save(expenses);
    state = state.copyWith(expenses: expenses);
  }

  /// 删除记账 - 对齐 Android onDelete 回调
  Future<void> deleteExpense(ExpenseEntry entry) async {
    final expenses = state.expenses.where((e) => e.id != entry.id).toList();
    await _expenseRepo.save(expenses);
    state = state.copyWith(expenses: expenses);
  }
}

/// 日历 ViewModel Provider
final calendarViewModelProvider =
    NotifierProvider<CalendarViewModel, CalendarState>(CalendarViewModel.new);
