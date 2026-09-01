// 日历页状态 - 对齐 Android WeatherFragment.kt 的页面级数据
// monthTitle/historyDesc 均在 tools_fr_weather.xml + initView 中一次性设置,
// 翻月不更新标题(安卓未挂任何日历月份监听)。
import 'package:flutter/foundation.dart';

@immutable
class WeatherCalendarState {
  /// 日历卡标题 - 对齐 mToolsTodayText: "${currentYear}年${currentMonth}月"
  /// (静态, 初始化一次)
  final String monthTitle;

  /// 历史上的今天描述 - 对齐 mToolsTadayFs:
  /// 初始为 XML 默认文案(小寒…), 网络抓取 360 首条 desc 后替换;
  /// 失败保持默认文案(对齐安卓网络失败不清空文本的行为)
  final String historyDesc;

  /// 是否正在抓取历史描述
  final bool historyLoading;

  const WeatherCalendarState({
    this.monthTitle = '',
    this.historyDesc = '',
    this.historyLoading = false,
  });

  WeatherCalendarState copyWith({
    String? monthTitle,
    String? historyDesc,
    bool? historyLoading,
  }) {
    return WeatherCalendarState(
      monthTitle: monthTitle ?? this.monthTitle,
      historyDesc: historyDesc ?? this.historyDesc,
      historyLoading: historyLoading ?? this.historyLoading,
    );
  }
}
