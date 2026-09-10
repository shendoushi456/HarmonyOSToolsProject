// QxCalendar 日历数据仓库 - 对齐 Android QxCalendarRepository.kt
// 1) 抓取 360 "历史上的今天" H5 并按 Qx 版正则解析（title/year/desc/图片）
// 2) 用 7 天预报计算雨日集合（textDay/iconDay/precip 判定）
import 'package:dio/dio.dart';

import '../../weather/models/weather_dto.dart';
import '../../weather/repositories/city_repository.dart';
import '../../weather/repositories/weather_repository.dart';
import '../models/qx_calendar_models.dart';

class QxCalendarRepository {
  final Dio _dio;
  final WeatherRepository _weatherRepository;
  final CityRepository _cityRepository;

  /// 独立 Dio 实例（不带和风 key 拦截器）- 对齐 Android WeatherHttpManager.doCalendarGet
  QxCalendarRepository({
    Dio? dio,
    WeatherRepository? weatherRepository,
    CityRepository? cityRepository,
  })  : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              responseType: ResponseType.plain,
            )),
        _weatherRepository = weatherRepository ?? WeatherRepository(),
        _cityRepository = cityRepository ?? CityRepository();

  /// 抓取"历史上的今天"（对齐 Android loadHistoryToday，8s 超时失败返回空）
  Future<List<QxHistoryEventUi>> loadHistoryToday(
    DateTime date, {
    int limit = 20,
  }) async {
    final requestDate =
        '${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final String? payload;
    try {
      payload = await _dio
          .get<String>(
            'http://hao.360.com/histoday/$requestDate.html',
            options: Options(
              headers: {'Charset': 'UTF-8', 'User-Agent': 'Mozilla/5.0'},
            ),
          )
          .then((response) => response.statusCode == 200 ? response.data : null)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      return const [];
    }
    if (payload == null) return const [];
    try {
      return _parseHistoryHtml(payload)
          .take(limit)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// 计算雨日集合（对齐 Android loadRainDates：已存城市定位 5s → 7d 预报 8s → isRainDay）
  Future<Set<DateTime>> loadRainDates() async {
    try {
      final cityName = await _savedCityName();
      final location = await _weatherRepository
          .resolveCity(cityName)
          .timeout(const Duration(seconds: 5));
      final daily = await _weatherRepository
          .load7d(location.id)
          .timeout(const Duration(seconds: 8));
      return daily.daily
          .map((item) {
            final date = DateTime.tryParse(item.fxDate);
            if (date == null || !_isRainDay(item)) return null;
            return DateTime(date.year, date.month, date.day);
          })
          .whereType<DateTime>()
          .toSet();
    } catch (_) {
      return {};
    }
  }

  /// 当前选中城市名（对齐 Android QxCityStore.selectedCity）
  Future<String> _savedCityName() async {
    final cities = await _cityRepository.loadCities();
    if (cities.isEmpty) return '北京';
    final index = _cityRepository.loadPosition();
    final city = cities[index.clamp(0, cities.length - 1)];
    return city.cityName.isNotEmpty ? city.cityName : '北京';
  }

  /// 是否雨日（对齐 Android isRainDay：textDay 含雨/雷、iconDay 300..399、precip>0）
  bool _isRainDay(Weather7DDTO item) {
    final icon = int.tryParse(item.iconDay);
    final precip = double.tryParse(item.precip) ?? 0.0;
    return item.textDay.contains('雨') ||
        item.textDay.contains('雷') ||
        (icon != null && icon >= 300 && icon <= 399) ||
        precip > 0.0;
  }

  /// 解析 360 历史页 HTML（对齐 Android parseHistoryHtml）
  List<QxHistoryEventUi> _parseHistoryHtml(String payload) {
    final blockPattern =
        RegExp(r'''<dl\s+class=["']tih-item(?:\s+open)?["'][^>]*>([\s\S]*?)</dl>''');
    return blockPattern
        .allMatches(payload)
        .map((match) => _parseHistoryBlock(match.group(1) ?? ''))
        .whereType<QxHistoryEventUi>()
        .toList();
  }

  /// 解析单个事件块（对齐 Android parseHistoryBlock）
  QxHistoryEventUi? _parseHistoryBlock(String block) {
    var heading = _firstMatch(block, RegExp(r'<dt[^>]*>([\s\S]*?)</dt>'))
        .replaceFirst(RegExp(r'^\d+\.\s*'), '');
    if (heading.trim().isEmpty) return null;

    final parts =
        heading.split(RegExp(r'\s*[-－]\s*'));
    final year = parts.isNotEmpty ? _normalizeYear(parts[0]) : '';
    var title = parts.length > 1 && parts[1].trim().isNotEmpty
        ? parts[1]
        : (parts.isNotEmpty ? heading : '');
    title = title.trim();
    if (title.isEmpty) return null;

    return QxHistoryEventUi(
      title: title,
      year: year,
      description:
          _firstMatch(block, RegExp(r'''<div\s+class=["']desc["'][^>]*>([\s\S]*?)</div>''')),
      imageUrl: _normalizeImageUrl(
          _firstAttribute(block, 'data-src').trim().isNotEmpty
              ? _firstAttribute(block, 'data-src')
              : _firstAttribute(block, 'src')),
    );
  }

  /// 正则取第一捕获组并清洗（对齐 Android firstMatch + cleanHtml）
  String _firstMatch(String text, RegExp regex) {
    return _cleanHtml(regex.firstMatch(text)?.group(1) ?? '');
  }

  /// 取首个属性值（对齐 Android firstAttribute）
  String _firstAttribute(String text, String name) {
    return RegExp('''\\b$name=["']([^"']+)["']''').firstMatch(text)?.group(1) ?? '';
  }

  /// 年份归一化（对齐 Android normalizeYear：纯数字补"年"）
  String _normalizeYear(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty || clean.contains('年')) return clean;
    final year = RegExp(r'\d{1,4}').firstMatch(raw)?.group(0) ?? '';
    return year.isNotEmpty ? '$year年' : clean;
  }

  /// 图片地址归一化（对齐 Android normalizeImageUrl：// → https:、http → https）
  String _normalizeImageUrl(String raw) {
    if (raw.startsWith('//')) return 'https:$raw';
    if (raw.startsWith('http://')) return raw.replaceFirst('http://', 'https://');
    if (raw.startsWith('https://')) return raw;
    return '';
  }

  /// 清洗 HTML（对齐 Android cleanHtml）
  String _cleanHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
