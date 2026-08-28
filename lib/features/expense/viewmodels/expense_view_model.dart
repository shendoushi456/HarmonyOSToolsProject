import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_models.dart';
import '../repositories/expense_repository.dart';
import 'expense_state.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepository(),
);

final expenseViewModelProvider =
    NotifierProvider<ExpenseViewModel, ExpenseState>(
  ExpenseViewModel.new,
);

/// 花费记账业务层 - 对齐 Android ExpenseViewModel。
/// 持有全量记录（含软删除项），切换周期时在内存中过滤、分组、统计。
class ExpenseViewModel extends Notifier<ExpenseState> {
  late final ExpenseRepository _repository;
  List<ExpenseRecord> _allRecords = [];

  @override
  ExpenseState build() {
    _repository = ref.read(expenseRepositoryProvider);
    Future.microtask(_load);
    return const ExpenseState();
  }

  Future<void> _load() async {
    final records = await _repository.load();
    final limit = await _repository.loadMonthlyLimit();
    _allRecords = records;
    _rebuild(state.selectedPeriod, monthlyLimitCents: limit);
  }

  /// 切换日、周、月或年 - 对齐 selectPeriod。
  void selectPeriod(ExpensePeriod period) {
    if (period == state.selectedPeriod) return;
    _rebuild(period);
  }

  /// 重新加载当前周期 - 对齐 retry。
  Future<void> retry() async {
    await _load();
  }

  /// 新增账单 - 对齐 ExpenseRepository.addRecord 的输入校验。
  /// 返回 null 表示成功，否则返回错误文案。
  Future<String?> addRecord({
    required int typeCode,
    required String categoryCode,
    required int amountCents,
    required String note,
    required DateTime occurredAt,
  }) async {
    if (typeCode != ExpenseRecord.typeExpense &&
        typeCode != ExpenseRecord.typeIncome) {
      return '账单类型不正确';
    }
    if (categoryCode.trim().isEmpty) return '账单分类不能为空';
    if (amountCents <= 0) return '账单金额必须大于 0';
    final now = DateTime.now().millisecondsSinceEpoch;
    final record = ExpenseRecord(
      id: now,
      typeCode: typeCode,
      categoryCode: categoryCode.trim(),
      amountCents: amountCents,
      note: note.trim(),
      occurredAt: occurredAt,
      createdAt: now,
      updatedAt: now,
    );
    _allRecords = [..._allRecords, record];
    await _repository.save(_allRecords);
    _rebuild(state.selectedPeriod);
    return null;
  }

  /// 软删除一条账单 - 对齐 deleteRecord（isActive=0 落盘保留）。
  Future<void> deleteRecord(int id) async {
    _allRecords = _allRecords
        .map((record) => record.id == id
            ? record.copyWith(
                isActive: false, updatedAt: DateTime.now().millisecondsSinceEpoch)
            : record)
        .toList();
    await _repository.save(_allRecords);
    _rebuild(state.selectedPeriod);
  }

  /// 保存/清除本月支出上限 - 对齐 saveMonthlyLimit。
  Future<void> saveMonthlyLimit(int cents) async {
    await _repository.saveMonthlyLimit(cents);
    _rebuild(state.selectedPeriod, monthlyLimitCents: cents);
  }

  /// 根据当前全量记录重建 UI 状态。
  void _rebuild(ExpensePeriod period, {int? monthlyLimitCents}) {
    final range = _calculateTimeRange(period);
    final records = _allRecords
        .where((record) =>
            record.isActive &&
            !record.occurredAt.isBefore(range.start) &&
            record.occurredAt.isBefore(range.end))
        .toList()
      ..sort((a, b) {
        final compare = b.occurredAt.compareTo(a.occurredAt);
        return compare != 0 ? compare : b.id.compareTo(a.id);
      });

    final monthRange = _calculateTimeRange(ExpensePeriod.month);
    final monthlyRecords = _allRecords.where((record) =>
        record.isActive &&
        !record.occurredAt.isBefore(monthRange.start) &&
        record.occurredAt.isBefore(monthRange.end));

    state = state.copyWith(
      selectedPeriod: period,
      dayGroups: _buildDayGroups(records),
      totalExpenseCents: records
          .where((record) => record.typeCode == ExpenseRecord.typeExpense)
          .fold<int>(0, (sum, record) => sum + record.amountCents),
      totalIncomeCents: records
          .where((record) => record.typeCode == ExpenseRecord.typeIncome)
          .fold<int>(0, (sum, record) => sum + record.amountCents),
      monthlyExpenseCents: monthlyRecords
          .where((record) => record.typeCode == ExpenseRecord.typeExpense)
          .fold<int>(0, (sum, record) => sum + record.amountCents),
      monthlyLimitCents: monthlyLimitCents,
      isLoading: false,
      clearError: true,
    );
  }

  /// 按自然日分组并计算每日收支 - 对齐 buildDayGroups。
  List<ExpenseDayGroup> _buildDayGroups(List<ExpenseRecord> records) {
    final grouped = <String, List<ExpenseRecord>>{};
    for (final record in records) {
      final day = _dateOnly(record.occurredAt);
      grouped.putIfAbsent(
          '${day.year}-${day.month}-${day.day}', () => []).add(record);
    }
    return grouped.values.map((dayRecords) {
      final day = _dateOnly(dayRecords.first.occurredAt);
      return ExpenseDayGroup(
        day: day,
        records: dayRecords,
        expenseCents: dayRecords
            .where((record) => record.typeCode == ExpenseRecord.typeExpense)
            .fold(0, (sum, record) => sum + record.amountCents),
        incomeCents: dayRecords
            .where((record) => record.typeCode == ExpenseRecord.typeIncome)
            .fold(0, (sum, record) => sum + record.amountCents),
      );
    }).toList()
      ..sort((a, b) => b.day.compareTo(a.day));
  }

  /// 周期 → [start, end) 时间范围 - 对齐 calculateTimeRange。
  /// 周：本周一 00:00 起；月：本月 1 日 00:00 起；年：本年 1 月 1 日 00:00 起。
  _ExpenseTimeRange _calculateTimeRange(ExpensePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ExpensePeriod.day:
        final start = DateTime(now.year, now.month, now.day);
        return _ExpenseTimeRange(start, start.add(const Duration(days: 1)));
      case ExpensePeriod.week:
        final start =
            DateTime(now.year, now.month, now.day)
                .subtract(Duration(days: now.weekday - 1));
        return _ExpenseTimeRange(start, start.add(const Duration(days: 7)));
      case ExpensePeriod.month:
        final start = DateTime(now.year, now.month, 1);
        final end = now.month == 12
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
        return _ExpenseTimeRange(start, end);
      case ExpensePeriod.year:
        final start = DateTime(now.year, 1, 1);
        return _ExpenseTimeRange(start, DateTime(now.year + 1, 1, 1));
    }
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _ExpenseTimeRange {
  final DateTime start;
  final DateTime end;
  const _ExpenseTimeRange(this.start, this.end);
}
