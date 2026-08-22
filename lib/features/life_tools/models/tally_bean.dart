// Tally - 记账数据 Model
// 对齐 Android third-module/tallynotes/src/main/java/com/example/tallynotes/Bean/Tally.java
// 字段对齐 tally 表(id/date/type/money/state)
import 'package:flutter/foundation.dart';

@immutable
class Tally {
  const Tally({
    this.id,
    required this.tallyTime,
    required this.tallyType,
    required this.tallyMoney,
    required this.tallyState,
  });

  /// 记账 id(对齐 tally 表 id)
  final int? id;

  /// 日期 yyyy-MM-dd(对齐 tally 表 date)
  final String tallyTime;

  /// 类型:收入/支出(对齐 tally 表 type)
  final String tallyType;

  /// 金额(对齐 tally 表 money, float)
  final double tallyMoney;

  /// 说明(对齐 tally 表 state)
  final String tallyState;

  factory Tally.fromMap(Map<String, dynamic> map) {
    return Tally(
      id: map['id'] as int?,
      tallyTime: map['date'] as String? ?? '',
      tallyType: map['type'] as String? ?? '',
      tallyMoney: (map['money'] as num?)?.toDouble() ?? 0,
      tallyState: map['state'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': tallyTime,
      'type': tallyType,
      'money': tallyMoney,
      'state': tallyState,
    };
  }

  Tally copyWith({
    int? id,
    String? tallyTime,
    String? tallyType,
    double? tallyMoney,
    String? tallyState,
  }) {
    return Tally(
      id: id ?? this.id,
      tallyTime: tallyTime ?? this.tallyTime,
      tallyType: tallyType ?? this.tallyType,
      tallyMoney: tallyMoney ?? this.tallyMoney,
      tallyState: tallyState ?? this.tallyState,
    );
  }
}
