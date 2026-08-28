import 'package:flutter/foundation.dart';

/// 记账记录 - 对齐 Android ExpenseRecordEntity。
/// 金额始终以“分”的 int 存储，展示时再格式化为人民币字符串。
@immutable
class ExpenseRecord {
  static const int typeExpense = 0;
  static const int typeIncome = 1;

  final int id;
  final int typeCode; // 0=支出 1=收入
  final String categoryCode;
  final int amountCents;
  final String note;
  final DateTime occurredAt;
  final int createdAt;
  final int updatedAt;
  final bool isActive;

  const ExpenseRecord({
    required this.id,
    required this.typeCode,
    required this.categoryCode,
    required this.amountCents,
    required this.note,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  ExpenseRecord copyWith({
    int? typeCode,
    String? categoryCode,
    int? amountCents,
    String? note,
    DateTime? occurredAt,
    int? updatedAt,
    bool? isActive,
  }) =>
      ExpenseRecord(
        id: id,
        typeCode: typeCode ?? this.typeCode,
        categoryCode: categoryCode ?? this.categoryCode,
        amountCents: amountCents ?? this.amountCents,
        note: note ?? this.note,
        occurredAt: occurredAt ?? this.occurredAt,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'typeCode': typeCode,
        'categoryCode': categoryCode,
        'amountCents': amountCents,
        'note': note,
        'occurredAt': occurredAt.millisecondsSinceEpoch,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'isActive': isActive,
      };

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) => ExpenseRecord(
        id: (json['id'] as num?)?.toInt() ?? 0,
        typeCode: (json['typeCode'] as num?)?.toInt() ?? 0,
        categoryCode: json['categoryCode']?.toString() ?? '',
        amountCents: (json['amountCents'] as num?)?.toInt() ?? 0,
        note: json['note']?.toString() ?? '',
        occurredAt: DateTime.fromMillisecondsSinceEpoch(
            (json['occurredAt'] as num?)?.toInt() ??
                DateTime.now().millisecondsSinceEpoch),
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
        updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );
}

/// 筛选周期 - 对齐 Android ExpensePeriod。
enum ExpensePeriod {
  year('年', '本年'),
  month('月', '本月'),
  week('周', '本周'),
  day('日', '今日');

  const ExpensePeriod(this.tabText, this.summaryPrefix);

  final String tabText;
  final String summaryPrefix;
}

/// 按自然日分组的账单 - 对齐 Android ExpenseDayGroup。
@immutable
class ExpenseDayGroup {
  final DateTime day;
  final List<ExpenseRecord> records;
  final int expenseCents;
  final int incomeCents;

  const ExpenseDayGroup({
    required this.day,
    required this.records,
    required this.expenseCents,
    required this.incomeCents,
  });
}
