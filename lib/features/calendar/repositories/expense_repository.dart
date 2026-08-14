// 记账存储仓库 - 对齐 Android CalendarFragment.loadExpenses/saveExpenses
// 使用 SharedPreferences 存储记账列表(JSON 数组)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_entry.dart';

class ExpenseRepository {
  /// 记账列表存储 key
  /// Android 原版用独立 SP 文件 qmtq_calendar_expense + key calendar_entries
  /// Flutter shared_preferences 只支持单文件,故用文件名作 key 以保持隔离与独特性
  static const String _entriesKey = 'qmtq_calendar_expense';

  /// 加载记账列表 - 对齐 Android loadExpenses(行 1027-1041)
  Future<List<ExpenseEntry>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final source = prefs.getString(_entriesKey) ?? '[]';
      final array = jsonDecode(source) as List;
      return array
          .map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // 解析失败返回空列表,对齐 Android runCatching.getOrDefault
      return const [];
    }
  }

  /// 保存记账列表 - 对齐 Android saveExpenses(行 1043-1059)
  Future<void> save(List<ExpenseEntry> entries) async {
    final array = entries.map((e) => e.toJson()).toList();
    final json = jsonEncode(array);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_entriesKey, json);
  }
}
