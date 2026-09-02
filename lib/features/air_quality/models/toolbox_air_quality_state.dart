import '../../weather/models/weather_model.dart';

/// AirQualityFragment 的页面状态；UI 只消费此模型，便于后续替换整套马甲界面。
class ToolboxAirQualityState {
  final String cityName;
  final AirQuality? air;
  final CurrentWeather? currentWeather;
  final DailyWeather? dailyWeather;
  final bool loading;
  final String? errorMessage;

  const ToolboxAirQualityState({
    this.cityName = '',
    this.air,
    this.currentWeather,
    this.dailyWeather,
    this.loading = true,
    this.errorMessage,
  });

  ToolboxAirQualityState copyWith({
    String? cityName,
    AirQuality? air,
    CurrentWeather? currentWeather,
    DailyWeather? dailyWeather,
    bool? loading,
    String? errorMessage,
    bool clearAir = false,
    bool clearCurrentWeather = false,
    bool clearDailyWeather = false,
    bool clearError = false,
  }) {
    return ToolboxAirQualityState(
      cityName: cityName ?? this.cityName,
      air: clearAir ? null : air ?? this.air,
      currentWeather:
          clearCurrentWeather ? null : currentWeather ?? this.currentWeather,
      dailyWeather:
          clearDailyWeather ? null : dailyWeather ?? this.dailyWeather,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
