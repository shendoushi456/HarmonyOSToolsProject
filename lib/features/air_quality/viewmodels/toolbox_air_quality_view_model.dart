import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/repositories/weather_repository.dart';
import '../../weather/viewmodels/toolbox_weather_view_model.dart';
import '../models/toolbox_air_quality_state.dart';

/// AirQualityChildFragment 的数据协调层。
/// 监听 toolbox 天气页所选城市，在一次城市定位后并发请求空气质量和实时天气。
class ToolboxAirQualityViewModel extends Notifier<ToolboxAirQualityState> {
  final WeatherRepository _weatherRepository = WeatherRepository();
  int _requestVersion = 0;

  @override
  ToolboxAirQualityState build() {
    ref.listen<String?>(
      toolboxWeatherPageViewModelProvider
          .select((value) => value.city?.cityName),
      (_, cityName) {
        if (cityName != null && cityName.trim().isNotEmpty) {
          loadForCity(cityName);
        }
      },
      fireImmediately: true,
    );
    return const ToolboxAirQualityState();
  }

  Future<void> refresh() {
    final cityName = state.cityName;
    return cityName.isEmpty ? Future.value() : loadForCity(cityName);
  }

  Future<void> loadForCity(String cityName) async {
    final version = ++_requestVersion;
    state = state.copyWith(
      cityName: cityName,
      loading: true,
      clearAir: true,
      clearCurrentWeather: true,
      clearDailyWeather: true,
      clearError: true,
    );
    try {
      final cityId = await _weatherRepository.resolveCityId(cityName);
      final results = await Future.wait([
        _weatherRepository.loadAirQuality(cityId),
        _weatherRepository.loadCurrentWeather(cityId),
        _loadDailySafely(cityId),
      ]);
      if (version != _requestVersion) return;
      final air = results[0] as AirQuality?;
      final weather = results[1] as CurrentWeather?;
      final daily = results[2] as WeatherInfo?;
      state = state.copyWith(
        loading: false,
        air: air,
        currentWeather: weather,
        dailyWeather:
            daily?.daily.isNotEmpty == true ? daily!.daily.first : null,
        errorMessage:
            air == null && weather == null ? '空气质量数据加载失败，请下拉重试' : null,
        clearError: air != null || weather != null,
      );
    } catch (_) {
      if (version != _requestVersion) return;
      state = state.copyWith(
        loading: false,
        errorMessage: '空气质量数据加载失败，请下拉重试',
      );
    }
  }

  Future<WeatherInfo?> _loadDailySafely(String cityId) async {
    try {
      return await _weatherRepository.loadDailyWeather(cityId);
    } catch (_) {
      return null;
    }
  }
}

final toolboxAirQualityViewModelProvider =
    NotifierProvider<ToolboxAirQualityViewModel, ToolboxAirQualityState>(
  ToolboxAirQualityViewModel.new,
);
