// 天气 ViewModel - 对齐 Android TravelViewModel.kt
// 使用 riverpod Notifier 管理状态
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_util.dart';
import '../../../core/utils/hourly_temp_util.dart';
import '../models/city_bean.dart';
import '../models/weather_model.dart';
import '../repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherViewModel extends Notifier<WeatherState> {
  final WeatherRepository _repository = WeatherRepository();

  @override
  WeatherState build() {
    return const WeatherState();
  }

  /// 加载天气数据 - 对齐 TravelViewModel.loadData
  Future<void> loadData(CityBean city) async {
    // 1. 设置日期
    final now = DateTime.now();
    state = state.copyWith(
      date: '${now.year}/${now.month}',
      day: now.day.toString(),
    );

    // 2. 城市未变化且非首次 -> 跳过(对齐 Android 逻辑)
    if (state.cityName == city.cityName && !state.isFirst) return;

    state = state.copyWith(
      cityName: city.cityName,
      isFirst: false,
      isLoading: true,
      clearError: true,
    );

    try {
      // 3. 城市名 → 城市ID
      final cityId = await _repository.resolveCityId(city.cityName);

      // 4. 并发加载天气和空气质量
      final results = await Future.wait([
        _repository.loadDailyWeather(cityId),
        _repository.loadAirQuality(cityId),
      ]);

      final weather = results[0] as WeatherInfo;
      final airQuality = results[1] as AirQuality?;

      final today = weather.daily.isNotEmpty ? weather.daily.first : null;

      state = state.copyWith(
        weather: weather,
        today: today,
        airQuality: airQuality,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 主动刷新同一城市天气，供 MoreFragment 对齐 Android onResume 刷新行为使用。
  Future<void> refresh(CityBean city) async {
    state = state.copyWith(isFirst: true);
    await loadData(city);
  }

  /// 构建 15 日预报列表 - 对齐 populateForecasts + buildForecasts
  List<HomeForecast> buildForecasts(WeatherInfo? info) {
    if (info == null || info.daily.isEmpty) return [];
    final forecasts = <HomeForecast>[];
    final count = info.daily.length < 15 ? info.daily.length : 15;
    for (var i = 0; i < count; i++) {
      final weather = info.daily[i];
      forecasts.add(HomeForecast(
        dayLabel: DateUtil.getWeekDay(i, weather.fxDate),
        dateLabel: DateUtil.formatDateMMdd(weather.fxDate),
        tempMax: weather.tempMax,
        tempMin: weather.tempMin,
        condition: weather.textDay,
        windDir: weather.windDirDay,
        windScale: weather.windScaleDay,
        airCategory: state.airQuality?.category ?? '优',
      ));
    }
    return forecasts;
  }

  /// 构建逐小时预报(24小时,本地模拟) - 对齐 buildHourlyForecasts
  List<HourForecast> buildHourly(DailyWeather? today) {
    if (today == null) return [];
    final minT = int.tryParse(today.tempMin) ?? 10;
    final maxT = int.tryParse(today.tempMax) ?? 20;
    final nowHour = DateTime.now().hour;
    final condition = today.textDay;

    return List.generate(24, (i) {
      final hour = (nowHour + i) % 24;
      final temp = HourlyTempUtil.hourlyTemperature(hour, minT, maxT);
      final time = i == 0 ? '现在' : '${hour.toString().padLeft(2, '0')}时';
      return HourForecast(
        time: time,
        temperature: '$temp°',
        condition: condition,
      );
    });
  }
}

/// 天气 ViewModel Provider
final weatherViewModelProvider =
    NotifierProvider<WeatherViewModel, WeatherState>(WeatherViewModel.new);
