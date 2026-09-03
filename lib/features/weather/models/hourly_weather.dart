// 24 小时预报领域模型，对齐 Android HourlyWeatherBean。
import 'dart:convert';

class HourlyWeather {
  final String fxTime;
  final String precipitation;
  final String precipitationProbability;
  final String windScale;

  const HourlyWeather({
    required this.fxTime,
    required this.precipitation,
    required this.precipitationProbability,
    required this.windScale,
  });
}

/// 24 小时接口的原始响应。保留业务状态码，避免把接口失败误当成“无降水”。
class HourlyWeatherResponse {
  final String code;
  final List<HourlyWeather> hourly;

  const HourlyWeatherResponse({required this.code, required this.hourly});
}

HourlyWeatherResponse? hourlyWeatherResponseFromJson(Object? source) {
  try {
    final decoded = source is String ? jsonDecode(source) : source;
    if (decoded is! Map) return null;
    final root = Map<String, dynamic>.from(decoded);
    final hourly = (root['hourly'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => HourlyWeather(
            fxTime: item['fxTime']?.toString() ?? '',
            precipitation: item['precip']?.toString() ?? '',
            precipitationProbability: item['pop']?.toString() ?? '',
            windScale: item['windScale']?.toString() ?? '',
          ),
        )
        .toList();
    return HourlyWeatherResponse(
      code: root['code']?.toString() ?? '',
      hourly: hourly,
    );
  } catch (_) {
    return null;
  }
}
