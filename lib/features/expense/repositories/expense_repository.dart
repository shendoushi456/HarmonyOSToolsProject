import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense_models.dart';

/// 记账数据访问层 - 对齐 Android ExpenseRepository（Room 软删除）。
/// SharedPreferences 存全量记录（含软删除项），查询在内存中完成。
class ExpenseRepository {
  static const _storageKey = 'toolbox_expense_v1';

  Future<List<ExpenseRecord>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((value) =>
              ExpenseRecord.fromJson(value as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<ExpenseRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, jsonEncode(records.map((e) => e.toJson()).toList()));
  }

  /// 月支出上限（分）- 对齐 Android SP 文件 nxtx_expense_preferences。
  Future<int> loadMonthlyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final cents = prefs.getInt(_monthlyLimitKey) ?? 0;
    return cents < 0 ? 0 : cents;
  }

  Future<void> saveMonthlyLimit(int cents) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_monthlyLimitKey, cents < 0 ? 0 : cents);
  }

  static const _monthlyLimitKey = 'monthly_expense_limit_cents';
}
