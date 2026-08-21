// 历史上的今天事件 - 对齐 Android HistoryActivity HashMap keys (time/name/img/gk)
import 'package:flutter/foundation.dart';

@immutable
class HistoryEvent {
  /// 年份(如 "1990" 或 "今日")
  final String time;

  /// 事件标题
  final String name;

  /// 图片 URL(空字符串表示无图)
  final String img;

  /// 事件详情(对应 Android HashMap 的 "gk" key)
  final String detail;

  const HistoryEvent({
    required this.time,
    required this.name,
    required this.img,
    required this.detail,
  });
}
