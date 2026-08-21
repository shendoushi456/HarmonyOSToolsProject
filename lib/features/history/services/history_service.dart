// 历史上的今天服务 - 对齐 Android HistoryActivity.parseHistoryResponse + fallbackHistory
// 抓取 360 网站 HTML 并正则解析,失败/空时返回硬编码兜底数据
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/history_event.dart';

class HistoryService {
  final Dio _dio;

  /// 用独立 Dio 实例(不带和风 key 拦截器) - 360 网站不是和风 API
  /// 对齐 Android HistoryActivity 用 BaseOkHttp 独立请求
  HistoryService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              responseType: ResponseType.plain,
            ));

  /// 抓取"历史上的今天" - 对齐 Android loadHistory(url) + DatePickerDialog 拼接 URL
  /// 失败或结果为空时,对齐 Android 调用 fallbackHistory() 兜底
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
      if (response.statusCode != 200) return fallbackHistory();
      final parsed = _parseHistoryResponse(response.data ?? '');
      // 对齐 Android: result.isEmpty() → result.addAll(fallbackHistory())
      return parsed.isEmpty ? fallbackHistory() : parsed;
    } catch (_) {
      // 请求异常返回兜底数据(对齐 Android fallback)
      return fallbackHistory();
    }
  }

  /// 解析 HTML - 对齐 Android parseHistoryResponse(行 144-175)
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
        // 去掉 time 前缀 - 对齐 Android name.replaceFirst("^\\s*time\\s*[.。]?\\s*-?\\s*", "")
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
      // 提取图片 URL - 对齐 Android group(block, "src=\"([^\"]+)\"")
      var img = _regexGroup(block, r'src="([^"]+)"');
      // URL 修正 - 对齐 Android img.startsWith("//") / img.startsWith("/")
      if (img.startsWith('//')) {
        img = 'http:$img';
      } else if (img.startsWith('/')) {
        img = 'http://hao.360.com$img';
      }
      if (name.trim().isNotEmpty) {
        events.add(HistoryEvent(
          time: time.isEmpty ? '今日' : time,
          name: name.trim(),
          img: img,
          // detail 对应 Android HashMap 的 "gk" key
          detail: detail.isEmpty ? name.trim() : detail,
        ));
      }
    }
    return events;
  }

  /// 兜底数据 - 对齐 Android fallbackHistory()(行 195-210)
  /// 3 条硬编码(对应 7 月 9 日),网络失败或解析空时使用
  List<HistoryEvent> fallbackHistory() {
    return [
      const HistoryEvent(
        time: '1816',
        name: '阿根廷宣告独立',
        img: '',
        detail: '1816年7月9日,阿根廷正式宣告独立,这是南美独立运动中的重要事件。',
      ),
      const HistoryEvent(
        time: '1955',
        name: '罗素—爱因斯坦宣言发表',
        img: '',
        detail: '1955年7月9日,罗素—爱因斯坦宣言发表,呼吁人类正视核武器风险并避免战争。',
      ),
      const HistoryEvent(
        time: '1981',
        name: '任天堂街机游戏《大金刚》发行',
        img: '',
        detail: '1981年7月,《大金刚》街机游戏推出,马力欧角色由此进入大众视野。',
      ),
    ];
  }

  /// 正则提取第一组 - 对齐 Android group(text, regex)(行 183-193)
  String _regexGroup(String source, String expression) {
    final match = RegExp(expression).firstMatch(source);
    return match?.group(1) ?? '';
  }

  /// 清理 HTML - 对齐 Android cleanHtml(text)(行 183-193)
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
