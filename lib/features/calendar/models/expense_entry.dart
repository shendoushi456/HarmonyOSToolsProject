// 记账条目 - 对齐 Android CalendarFragment.ExpenseEntry
import 'package:flutter/foundation.dart';

@immutable
class ExpenseEntry {
  /// 唯一 ID(时间戳)
  final int id;

  /// 日期(yyyy-MM-dd)
  final String date;

  /// 是否收入(true=收入,false=支出)
  final bool income;

  /// 金额(字符串,对齐原版)
  final String amount;

  /// 说明
  final String note;

  const ExpenseEntry({
    required this.id,
    required this.date,
    required this.income,
    required this.amount,
    required this.note,
  });

  ExpenseEntry copyWith({
    int? id,
    String? date,
    bool? income,
    String? amount,
    String? note,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      income: income ?? this.income,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }

  /// 序列化为 JSON - 对齐 Android saveExpenses 的 JSONObject.put
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'income': income,
        'amount': amount,
        'note': note,
      };

  /// 从 JSON 反序列化 - 对齐 Android loadExpenses 的 optLong/optString/optBoolean
  factory ExpenseEntry.fromJson(Map<String, dynamic> json) {
    return ExpenseEntry(
      id: json['id'] as int? ?? 0,
      date: json['date']?.toString() ?? '',
      income: json['income'] as bool? ?? false,
      amount: json['amount']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
    );
  }
}
