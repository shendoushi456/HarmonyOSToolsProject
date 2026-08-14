// 历史上的今天服务 - 对齐 Android CalendarFragment.loadRealHistory + parseHistoryResponse
// 抓取 360 网站 HTML 并正则解析
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/history_event.dart';

class HistoryService {
  final Dio _dio;

  /// 用独立 Dio 实例(不带和风 key 拦截器) - 360 网站不是和风 API
  HistoryService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              responseType: ResponseType.plain,
            ));

  /// 抓取"历史上的今天" - 对齐 Android loadRealHistory(行 967-981)
  Future<List<HistoryEvent>> fetchHistory(DateTime date) async {
    try {
      final datePath = DateFormat('MMdd').format(date);
      final response = await _dio.get<String>(
        'http://hao.360.com/histoday/$datePath.html',
        options: Options(
          headers: {
            'Charset': 'UTF-8',
            'User-Agent': 'Mozilla/5.0',
          },
        ),
      );
      if (response.statusCode != 200) return const [];
      return _parseHistoryResponse(response.data ?? '');
    } catch (_) {
      // 请求失败返回空列表,对齐 Android runCatching.getOrDefault(emptyList())
      return const [];
    }
  }

  /// 解析 HTML - 对齐 Android parseHistoryResponse(行 983-1013)
  List<HistoryEvent> _parseHistoryResponse(String response) {
    if (response.isEmpty) return const [];
    // 匹配 <dl class="tih-item...">...</dl> 块
    final blockPattern =
        RegExp(r'<dl\s+class="tih-item(?:\s+open)?"[\s\S]*?</dl>');
    final events = <HistoryEvent>[];
    for (final match in blockPattern.allMatches(response)) {
      final block = match.group(0) ?? '';
      final dateHtml = _regexGroup(block, r'<dt[^>]*>([\s\S]*?)</dt>');
      final emphasizedYear =
          _cleanHtml(_regexGroup(dateHtml, r'<em[^>]*>([\s\S]*?)</em>'));
      final plainDate = _cleanHtml(dateHtml);
      var time = emphasizedYear;
      if (time.isEmpty) {
        final m = RegExp(r'(\d{1,4})').firstMatch(plainDate);
        time = m?.group(1) ?? '';
      }
      String name;
      if (time.isEmpty) {
        name = plainDate;
      } else {
        // 去掉 time 前缀 - 对齐原版正则替换
        final escapeTime = RegExp.escape(time);
        final replaced = plainDate.replaceFirst(
          RegExp('^\\s*$escapeTime\\s*[\\.。]?\\s*-?\\s*'),
          '',
        );
        name = replaced.trim();
      }
      final detail = _cleanHtml(
        _regexGroup(block, r'<div\s+class="desc"[^>]*>([\s\S]*?)</div>'),
      );
      if (name.trim().isNotEmpty) {
        events.add(HistoryEvent(
          time: time.isEmpty ? '今日' : time,
          name: name,
          detail: detail.isEmpty ? name : detail,
        ));
      }
    }
    return events;
  }

  /// 正则提取第一组 - 对齐 Android regexGroup(行 1015-1016)
  String _regexGroup(String source, String expression) {
    final match = RegExp(expression).firstMatch(source);
    return match?.group(1) ?? '';
  }

  /// 清理 HTML - 对齐 Android cleanHtml(行 1018-1025)
  String _cleanHtml(String source) {
    return source
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
