import 'package:flutter/foundation.dart';

import '../models/expense_models.dart';

/// 花费记账页面状态 - 对齐 Android ExpenseUiState。
@immutable
class ExpenseState {
  /// 筛选周期，默认月
  final ExpensePeriod selectedPeriod;

  /// 按日期分组后的账单
  final List<ExpenseDayGroup> dayGroups;

  final int totalExpenseCents;
  final int totalIncomeCents;
  final int monthlyExpenseCents;

  /// 本月支出上限（分），0 表示未设置
  final int monthlyLimitCents;

  final bool isLoading;
  final String? errorMessage;

  const ExpenseState({
    this.selectedPeriod = ExpensePeriod.month,
    this.dayGroups = const [],
    this.totalExpenseCents = 0,
    this.totalIncomeCents = 0,
    this.monthlyExpenseCents = 0,
    this.monthlyLimitCents = 0,
    this.isLoading = true,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && dayGroups.isEmpty;

  ExpenseState copyWith({
    ExpensePeriod? selectedPeriod,
    List<ExpenseDayGroup>? dayGroups,
    int? totalExpenseCents,
    int? totalIncomeCents,
    int? monthlyExpenseCents,
    int? monthlyLimitCents,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      ExpenseState(
        selectedPeriod: selectedPeriod ?? this.selectedPeriod,
        dayGroups: dayGroups ?? this.dayGroups,
        totalExpenseCents: totalExpenseCents ?? this.totalExpenseCents,
        totalIncomeCents: totalIncomeCents ?? this.totalIncomeCents,
        monthlyExpenseCents: monthlyExpenseCents ?? this.monthlyExpenseCents,
        monthlyLimitCents: monthlyLimitCents ?? this.monthlyLimitCents,
        isLoading: isLoading ?? this.isLoading,
        errorMessage:
            clearError ? null : (errorMessage ?? this.errorMessage),
      );
}
