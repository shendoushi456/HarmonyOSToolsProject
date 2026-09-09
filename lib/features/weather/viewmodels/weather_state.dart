// 天气状态 - 不可变状态类,对应 Android TravelViewModel 的 StateFlow
import 'package:flutter/foundation.dart';
import '../models/hourly_weather.dart';
import '../models/weather_model.dart';

@immutable
class WeatherState {
  /// 当前城市名
  final String cityName;

  /// 日期 "yyyy/M"
  final String date;

  /// 日
  final String day;

  /// 完整天气数据(15天)
  final WeatherInfo? weather;

  /// 今日天气
  final DailyWeather? today;

  /// 空气质量
  final AirQuality? airQuality;

  /// 24小时预报(对齐 Android TravelViewModel.hourlyWeatherData)
  final List<HourlyWeather> hourly;

  /// 是否首次加载
  final bool isFirst;

  /// 是否加载中
  final bool isLoading;

  /// 错误信息
  final String? error;

  const WeatherState({
    this.cityName = '北京',
    this.date = '',
    this.day = '',
    this.weather,
    this.today,
    this.airQuality,
    this.hourly = const [],
    this.isFirst = true,
    this.isLoading = false,
    this.error,
  });

  WeatherState copyWith({
    String? cityName,
    String? date,
    String? day,
    WeatherInfo? weather,
    DailyWeather? today,
    AirQuality? airQuality,
    List<HourlyWeather>? hourly,
    bool? isFirst,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearHourly = false,
  }) {
    return WeatherState(
      cityName: cityName ?? this.cityName,
      date: date ?? this.date,
      day: day ?? this.day,
      weather: weather ?? this.weather,
      today: today ?? this.today,
      airQuality: airQuality ?? this.airQuality,
      hourly: clearHourly ? const [] : (hourly ?? this.hourly),
      isFirst: isFirst ?? this.isFirst,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
