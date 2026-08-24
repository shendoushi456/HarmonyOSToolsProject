// 天气 ViewModel - 对齐 Android TravelViewModel.kt
// 使用 riverpod Notifier 管理状态
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_util.dart';
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

      // 4. 并发加载每日天气、空气质量和真实24小时预报。
      // 小时预报失败不应阻断主天气页，对齐 Android 三个接口独立回调的行为。
      final results = await Future.wait([
        _repository.loadDailyWeather(cityId),
        _repository.loadAirQuality(cityId),
        _loadHourlySafely(cityId),
      ]);

      final weather = results[0] as WeatherInfo;
      final airQuality = results[1] as AirQuality?;
      final hourlyWeather = results[2] as List<HourlyWeather>;

      final today = weather.daily.isNotEmpty ? weather.daily.first : null;

      state = state.copyWith(
        weather: weather,
        today: today,
        airQuality: airQuality,
        hourlyWeather: hourlyWeather,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<List<HourlyWeather>> _loadHourlySafely(String cityId) async {
    try {
      return await _repository.loadHourlyWeather(cityId);
    } catch (_) {
      return const [];
    }
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

  /// 将真实小时预报转换为展示模型 - 对齐 Android TwentyFourHourWeatherScreen
  List<HourForecast> buildHourly(List<HourlyWeather> hourlyWeather) {
    return hourlyWeather.take(24).map((weather) {
      final dateTime = DateTime.tryParse(weather.fxTime.replaceFirst(' ', 'T'));
      final time = dateTime == null
          ? weather.fxTime
          : '${dateTime.hour.toString().padLeft(2, '0')}时';
      return HourForecast(
        time: time,
        temperature: '${weather.temp}°',
        condition: weather.text,
      );
    }).toList();
  }
}

/// 天气 ViewModel Provider
final weatherViewModelProvider =
    NotifierProvider<WeatherViewModel, WeatherState>(WeatherViewModel.new);
