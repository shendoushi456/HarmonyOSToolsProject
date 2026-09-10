// QxHome 首页天气页 UI 状态 - 对齐 Android QxUiModels.kt 中 QxHomeUiState 部分
// 迁移自 toolbox_c toolsbox_moduel QxHomeFragment 对应数据模型
import '../../../core/constants/app_assets.dart';

/// 每日预报条目（对齐 Android ForecastDayUi）
class QxForecastDayUi {
  final String label;
  final String condition;
  final String high;
  final String low;

  /// 天气小图标资源路径（对齐 Android @DrawableRes iconRes）
  final String iconPath;

  const QxForecastDayUi({
    required this.label,
    required this.condition,
    required this.high,
    required this.low,
    required this.iconPath,
  });
}

/// 实时指标条目（对齐 Android WeatherMetricUi）
class QxWeatherMetricUi {
  final String label;
  final String value;
  final String iconPath;

  const QxWeatherMetricUi({
    required this.label,
    required this.value,
    required this.iconPath,
  });
}

/// 首页天气整体状态（对齐 Android QxHomeUiState，默认值一致）
class QxHomeUiState {
  final bool loading;
  final String cityName;
  final String weekday;
  final String dateText;
  final String temperature;
  final String condition;
  final String tempRange;
  final String sunrise;
  final String sunset;

  /// 实时天气大图标路径（对齐 Android weatherIconRes 默认 ic_six_7day_big_sun）
  final String weatherIconPath;
  final List<QxWeatherMetricUi> metrics;
  final List<QxForecastDayUi> forecasts;
  final String? error;

  const QxHomeUiState({
    this.loading = true,
    this.cityName = '北京',
    this.weekday = '星期二',
    this.dateText = '2026-5-12',
    this.temperature = '26',
    this.condition = '晴',
    this.tempRange = '18°-26°',
    this.sunrise = '08:04',
    this.sunset = '17:04',
    this.weatherIconPath = AppAssets.toolboxWeatherBigSun,
    this.metrics = const [],
    this.forecasts = const [],
    this.error,
  });

  /// 对齐 Android QxHomeUiState.copy(loading = true)：保留已有展示字段仅切换加载态
  QxHomeUiState copyWith({bool? loading}) {
    return QxHomeUiState(
      loading: loading ?? this.loading,
      cityName: cityName,
      weekday: weekday,
      dateText: dateText,
      temperature: temperature,
      condition: condition,
      tempRange: tempRange,
      sunrise: sunrise,
      sunset: sunset,
      weatherIconPath: weatherIconPath,
      metrics: metrics,
      forecasts: forecasts,
      error: error,
    );
  }
}
