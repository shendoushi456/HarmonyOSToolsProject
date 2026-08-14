// 历史上的今天事件 - 对齐 Android CalendarFragment.HistoryEvent
import 'package:flutter/foundation.dart';

@immutable
class HistoryEvent {
  /// 年份(如 "1990" 或 "今日")
  final String time;

  /// 事件标题
  final String name;

  /// 事件详情
  final String detail;

  const HistoryEvent({
    required this.time,
    required this.name,
    required this.detail,
  });
}
