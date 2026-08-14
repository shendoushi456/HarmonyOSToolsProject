// 日历页面 - 对齐 Android CalendarFragment
// 完整还原:月历+农历 + 历史上的今天 + 记账三部分
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../models/expense_entry.dart';
import '../models/history_event.dart';
import '../viewmodels/calendar_view_model.dart';
import 'widgets/calendar_widgets.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarViewModelProvider);
    final viewModel = ref.read(calendarViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 顶部天空背景图 238dp - 对齐 Android CalendarScreen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              AppAssets.skyBackground,
              width: double.infinity,
              height: 238,
              fit: BoxFit.fill,
            ),
          ),
          // 滚动内容
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // 日历头部(含月份切换 + 日期网格 + 农历)
                  CalendarHeader(
                    displayMonth: state.displayMonth,
                    selectedDate: state.selectedDate,
                    onPrevious: viewModel.previousMonth,
                    onNext: viewModel.nextMonth,
                    onSelectDate: viewModel.selectDate,
                  ),
                  // 信息卡(历史上的今天 / 花费记账)
                  CalendarInformationCard(
                    selectedTab: state.selectedTab,
                    selectedDate: state.selectedDate,
                    historyEvents: state.historyEvents,
                    historyLoading: state.historyLoading,
                    entries: state.expenses,
                    onTabSelected: viewModel.selectTab,
                    // 直接在点击时显示弹窗,不通过 ViewModel 状态触发
                    onAdd: () => _showExpenseDialog(context, null),
                    onEdit: (entry) => _showExpenseDialog(context, entry),
                    onHistoryClick: (event) => _showHistoryDialog(context, event),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示记账弹窗 - 对齐 Android ExpenseDialog(条件渲染)
  /// 直接在点击回调里显示,避免状态时序问题
  void _showExpenseDialog(BuildContext context, ExpenseEntry? editingEntry) {
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ExpenseDialog(
        selectedDate: DateTime.now(),
        editingEntry: editingEntry,
        onDismiss: () {
          Navigator.of(dialogContext).pop();
        },
        onAdd: (entry) {
          viewModel.addExpense(entry);
          Navigator.of(dialogContext).pop();
        },
        onModify: (entry) {
          viewModel.modifyExpense(entry);
          Navigator.of(dialogContext).pop();
        },
        onDelete: (entry) {
          viewModel.deleteExpense(entry);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  /// 显示历史详情弹窗 - 对齐 Android HistoryDetailDialog(条件渲染)
  void _showHistoryDialog(BuildContext context, HistoryEvent event) {
    showDialog(
      context: context,
      builder: (dialogContext) => HistoryDetailDialog(
        event: event,
        onDismiss: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}
