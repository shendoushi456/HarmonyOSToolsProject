// 日历页 ViewModel - 对齐 Android WeatherFragment.kt 的数据编排
// 1. monthTitle: initView 中 "${currentYear}年${currentMonth}月" 一次性设置(翻月不更新)
// 2. mToolsTadayFs: HttpRequest 抓 http://hao.360.com/histoday/ 首条 desc,
//    复用 calendar feature 的 HistoryService(同源同解析), 取 events.first.detail。
// 3. mToolsJieQiData/mToolsTadayData 同为 "${currentYear}年${currentMonth}月", 由页面直接展示。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calendar/services/history_service.dart';
import 'weather_calendar_state.dart';

/// 历史描述初始文案 - tools_fr_weather.xml mToolsTaday_fs 默认 text 原文
const String kDefaultHistoryDesc =
    '小寒标志着寒气开始萌生，天气寒冷，但尚未达到最冷。此时节应注意保暖，饮食宜温补。';

class WeatherCalendarViewModel extends Notifier<WeatherCalendarState> {
  final HistoryService _historyService = HistoryService();

  @override
  WeatherCalendarState build() {
    final now = DateTime.now();
    // 对齐 initView: 三个年月文本均为当前年月, 一次性设置
    final monthTitle = '${now.year}年${now.month}月';
    final initState = WeatherCalendarState(
      monthTitle: monthTitle,
      historyDesc: kDefaultHistoryDesc,
      historyLoading: true,
    );
    // 异步抓取今日历史描述(对齐 HttpRequest histoday)
    Future.microtask(_loadHistoryDesc);
    return initState;
  }

  /// 抓取历史上的今天首条描述 - 对齐安卓 onResponse 中 index==0 的 desc
  /// 失败时保持默认文案(安卓网络失败时 response?.let 直接跳过, 文本不变)
  Future<void> _loadHistoryDesc() async {
    final events = await _historyService.fetchHistory(DateTime.now());
    state = state.copyWith(
      historyDesc: events.isNotEmpty ? events.first.detail : null,
      historyLoading: false,
    );
  }
}

/// 日历页 ViewModel Provider
final weatherCalendarViewModelProvider =
    NotifierProvider<WeatherCalendarViewModel, WeatherCalendarState>(
        WeatherCalendarViewModel.new);
