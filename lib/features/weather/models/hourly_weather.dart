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

List<HourlyWeather> hourlyWeatherFromJson(String source) {
  try {
    final root = jsonDecode(source) as Map<String, dynamic>;
    return (root['hourly'] as List? ?? const [])
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
  } catch (_) {
    return const [];
  }
}
