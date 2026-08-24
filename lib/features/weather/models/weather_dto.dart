// 天气数据 DTO - 对应 Android WeatherBeanInfo.kt
// 用于解析和风天气 API 返回的 JSON
import 'dart:convert';

/// 天气预报响应 DTO
class WeatherBeanInfoDTO {
  final String code;
  final List<Weather7DDTO> daily;
  final AirbeanDTO? now;

  const WeatherBeanInfoDTO({
    required this.code,
    required this.daily,
    this.now,
  });

  factory WeatherBeanInfoDTO.fromJson(Map<String, dynamic> json) {
    return WeatherBeanInfoDTO(
      code: json['code']?.toString() ?? '',
      daily: (json['daily'] as List?)
              ?.map((e) => Weather7DDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      now: json['now'] != null
          ? AirbeanDTO.fromJson(json['now'] as Map<String, dynamic>)
          : null,
    );
  }

  static WeatherBeanInfoDTO? fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WeatherBeanInfoDTO.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

/// 每日预报 DTO - 对应 Weather7D
class Weather7DDTO {
  final String sunrise;
  final String sunset;
  final String tempMax;
  final String tempMin;
  final String fxDate;
  final String iconDay;
  final String textDay;
  final String windDirDay;
  final String windScaleDay;
  final String windSpeedDay;
  final String windDirNight;
  final String humidity;
  final String pressure;
  final String precip;
  final String uvIndex;
  final String vis;
  final String cloud;

  const Weather7DDTO({
    required this.sunrise,
    required this.sunset,
    required this.tempMax,
    required this.tempMin,
    required this.fxDate,
    required this.iconDay,
    required this.textDay,
    required this.windDirDay,
    required this.windScaleDay,
    required this.windSpeedDay,
    required this.windDirNight,
    required this.humidity,
    required this.pressure,
    required this.precip,
    required this.uvIndex,
    required this.vis,
    required this.cloud,
  });

  factory Weather7DDTO.fromJson(Map<String, dynamic> json) {
    return Weather7DDTO(
      sunrise: json['sunrise']?.toString() ?? '',
      sunset: json['sunset']?.toString() ?? '',
      tempMax: json['tempMax']?.toString() ?? '',
      tempMin: json['tempMin']?.toString() ?? '',
      fxDate: json['fxDate']?.toString() ?? '',
      iconDay: json['iconDay']?.toString() ?? '',
      textDay: json['textDay']?.toString() ?? '',
      windDirDay: json['windDirDay']?.toString() ?? '',
      windScaleDay: json['windScaleDay']?.toString() ?? '',
      windSpeedDay: json['windSpeedDay']?.toString() ?? '',
      windDirNight: json['windDirNight']?.toString() ?? '',
      humidity: json['humidity']?.toString() ?? '',
      pressure: json['pressure']?.toString() ?? '',
      precip: json['precip']?.toString() ?? '',
      uvIndex: json['uvIndex']?.toString() ?? '',
      vis: json['vis']?.toString() ?? '',
      cloud: json['cloud']?.toString() ?? '',
    );
  }
}

/// 空气质量 DTO - 对应 Airbean
/// 注意:和风天气 API 中 pm2.5 字段名为 pm2p5
class AirbeanDTO {
  final String name;
  final int aqi;
  final String temp;
  final String text;
  final String vis;
  final String level;
  final String category;
  final String primary;
  final String pm10;
  final String pm2p5;
  final String no2;
  final String o3;
  final String co;
  final String so2;

  const AirbeanDTO({
    required this.name,
    required this.aqi,
    required this.temp,
    required this.text,
    required this.vis,
    required this.level,
    required this.category,
    required this.primary,
    required this.pm10,
    required this.pm2p5,
    required this.no2,
    required this.o3,
    required this.co,
    required this.so2,
  });

  factory AirbeanDTO.fromJson(Map<String, dynamic> json) {
    return AirbeanDTO(
      name: json['name']?.toString() ?? '',
      aqi: _parseInt(json['aqi']),
      temp: json['temp']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      vis: json['vis']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      primary: json['primary']?.toString() ?? '',
      pm10: json['pm10']?.toString() ?? '',
      pm2p5: (json['pm2p5'] ?? json['pm25'])?.toString() ?? '',
      no2: json['no2']?.toString() ?? '',
      o3: json['o3']?.toString() ?? '',
      co: json['co']?.toString() ?? '',
      so2: json['so2']?.toString() ?? '',
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// 24小时天气响应 DTO - 对应 Android HourlyWeatherBean
class HourlyWeatherBeanDTO {
  final String code;
  final List<HourlyWeatherDTO> hourly;

  const HourlyWeatherBeanDTO({
    required this.code,
    required this.hourly,
  });

  factory HourlyWeatherBeanDTO.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherBeanDTO(
      code: json['code']?.toString() ?? '',
      hourly: (json['hourly'] as List?)
              ?.map((item) =>
                  HourlyWeatherDTO.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static HourlyWeatherBeanDTO? fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HourlyWeatherBeanDTO.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

/// 单小时天气 DTO - 保留领域层需要的时间、温度和天气描述
class HourlyWeatherDTO {
  final String fxTime;
  final String temp;
  final String icon;
  final String text;

  const HourlyWeatherDTO({
    required this.fxTime,
    required this.temp,
    required this.icon,
    required this.text,
  });

  factory HourlyWeatherDTO.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherDTO(
      fxTime: json['fxTime']?.toString() ?? '',
      temp: json['temp']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}
