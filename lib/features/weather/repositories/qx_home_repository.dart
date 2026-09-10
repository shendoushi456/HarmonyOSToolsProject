// QxHome 首页天气数据仓库 - 对齐 Android QxWeatherRepository.loadHome
// 迁移自 toolbox_c toolsbox_moduel weather/data/QxWeatherRepository.kt
// 城市 → 城市ID(5s超时回退默认) → 7d预报/实时天气(8s超时容错) → 组装 QxHomeUiState
import 'dart:async';

import '../../../core/constants/app_assets.dart';
import '../models/city_bean.dart';
import '../models/qx_home_ui_state.dart';
import '../models/weather_dto.dart';
import '../models/weather_city_dto.dart';
import 'city_repository.dart';
import 'weather_repository.dart';

class QxHomeRepository {
  final WeatherRepository _weatherRepository;
  final CityRepository _cityRepository;

  QxHomeRepository({
    WeatherRepository? weatherRepository,
    CityRepository? cityRepository,
  })  : _weatherRepository = weatherRepository ?? WeatherRepository(),
        _cityRepository = cityRepository ?? CityRepository();

  /// 加载首页天气（对齐 Android QxWeatherRepository.loadHome）
  Future<QxHomeUiState> loadHome() async {
    final city = await _selectedCity();
    final today = DateTime.now();
    final location = await _runCatching(
      () => _lookupCity(city.cityName).timeout(const Duration(seconds: 5)),
      fallback: () => _defaultLocation(city.cityName),
    );
    final daily = await _runCatchingNull(
      () => _loadDaily(location.id).timeout(const Duration(seconds: 8)),
    );
    final now = await _runCatchingNull(
      () => _loadNow(location.id).timeout(const Duration(seconds: 8)),
    );

    final first = daily?.daily.isNotEmpty == true ? daily!.daily.first : null;
    final forecasts = _buildForecasts(daily);
    final tempMin = first?.tempMin._takeNotBlank() ?? '18';
    final tempMax = first?.tempMax._takeNotBlank() ?? '26';
    final windSpeed = first?.windSpeedDay._takeNotBlank() ??
        now?._takeNotBlankWindSpeed() ??
        '25';
    final pressure = first?.pressure._takeNotBlank() ??
        now?._takeNotBlankPressure() ??
        '1000';
    final humidity = first?.humidity._takeNotBlank() ??
        now?._takeNotBlankHumidity() ??
        '0';

    return QxHomeUiState(
      loading: false,
      cityName: city.cityName.isNotEmpty ? city.cityName : '北京',
      weekday: _weekday(today),
      dateText: '${today.year}-${today.month}-${today.day}',
      temperature: now?.temp._takeNotBlank() ?? tempMax,
      condition: now?.text._takeNotBlank() ??
          first?.textDay._takeNotBlank() ??
          '晴',
      tempRange: '$tempMin°-$tempMax°',
      sunrise: first?.sunrise._takeNotBlank() ?? '08:04',
      sunset: first?.sunset._takeNotBlank() ?? '17:04',
      weatherIconPath: _bigWeatherIcon(
        now?.text._takeNotBlank() ?? first?.textDay,
      ),
      metrics: [
        QxWeatherMetricUi(
          label: '风速',
          value: '${windSpeed}km/h',
          iconPath: AppAssets.qxHomeWindIcon,
        ),
        QxWeatherMetricUi(
          label: '气压',
          value: '${pressure}hPa',
          iconPath: AppAssets.qxHomePressureIcon,
        ),
        QxWeatherMetricUi(
          label: '湿度',
          value: '$humidity%',
          iconPath: AppAssets.qxHomeHumidityIcon,
        ),
      ],
      forecasts: forecasts,
      error: (daily == null && now == null)
          ? '天气数据暂未更新，已显示默认城市信息'
          : null,
    );
  }

  /// 当前选中城市（对齐 Android QxCityStore.selectedCity：列表 + fragment_position）
  Future<CityBean> _selectedCity() async {
    final cities = await _cityRepository.loadCities();
    if (cities.isEmpty) return CityBean.defaultCity();
    final index = _cityRepository.loadPosition();
    return cities[index.clamp(0, cities.length - 1)];
  }

  /// 城市名 → 城市定位（对齐 Android lookupCity，失败由调用方回退默认位置）
  Future<CityLocationDTO> _lookupCity(String cityName) async {
    return _weatherRepository.resolveCity(cityName);
  }

  /// 默认位置（对齐 Android defaultLocation：城市名 + 北京城市ID）
  CityLocationDTO _defaultLocation(String cityName) {
    return CityLocationDTO(
      name: cityName.isNotEmpty ? cityName : '北京',
      id: '101010100',
      fxLink: '',
      latitude: '',
      longitude: '',
    );
  }

  /// 7 天预报（对齐 Android loadDaily 使用 getWeather7Day）
  Future<WeatherBeanInfoDTO?> _loadDaily(String cityId) async {
    return _weatherRepository.load7d(cityId);
  }

  /// 实时天气（对齐 Android loadNow，取响应中的 now 节点所需字段）
  Future<AirbeanDTO?> _loadNow(String cityId) async {
    return _weatherRepository.loadNowDto(cityId);
  }

  /// 组装 6 天预报列表（对齐 Android forecasts 构造 + defaultForecasts）
  List<QxForecastDayUi> _buildForecasts(WeatherBeanInfoDTO? daily) {
    final items = daily?.daily.take(6).toList() ?? const <Weather7DDTO>[];
    if (items.isEmpty) return _defaultForecasts();
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return QxForecastDayUi(
        label: _dayLabel(index, item.fxDate),
        condition: item.textDay.isNotEmpty ? item.textDay : '晴',
        high: '${item.tempMax}°',
        low: '${item.tempMin}°',
        iconPath: _smallWeatherIcon(item.textDay),
      );
    }).toList();
  }

  /// 默认预报数据（对齐 Android defaultForecasts）
  List<QxForecastDayUi> _defaultForecasts() => const [
        QxForecastDayUi(
            label: '今天',
            condition: '晴',
            high: '30°',
            low: '28°',
            iconPath: AppAssets.weatherDaySun),
        QxForecastDayUi(
            label: '明天',
            condition: '多云',
            high: '32°',
            low: '28°',
            iconPath: AppAssets.weatherDayCloudy),
        QxForecastDayUi(
            label: '星期三',
            condition: '阴',
            high: '29°',
            low: '24°',
            iconPath: AppAssets.weatherDayCloudy),
        QxForecastDayUi(
            label: '星期四',
            condition: '小雨',
            high: '29°',
            low: '25°',
            iconPath: AppAssets.weatherDayRain),
        QxForecastDayUi(
            label: '星期五',
            condition: '阴',
            high: '28°',
            low: '22°',
            iconPath: AppAssets.weatherDayCloudy),
        QxForecastDayUi(
            label: '星期六',
            condition: '多云',
            high: '28°',
            low: '22°',
            iconPath: AppAssets.weatherDayCloudy),
      ];

  /// 日期标签（对齐 Android dayLabel：今天/明天/星期X，解析失败回退"星期N"保真）
  String _dayLabel(int index, String fxDate) {
    if (index == 0) return '今天';
    if (index == 1) return '明天';
    final parsed = DateTime.tryParse(fxDate);
    if (parsed == null) return '星期${index + 1}';
    return _weekday(parsed);
  }

  /// 星期文本（对齐 Android weekday）
  String _weekday(DateTime date) {
    const names = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    return names[date.weekday - 1];
  }

  /// 大天气图标（对齐 Android QxWeatherAssets.bigWeatherIcon，含雪→雷图标的原版映射）
  String _bigWeatherIcon(String? condition) {
    final text = condition ?? '';
    if (text.contains('雨')) return AppAssets.toolboxWeatherBigRain;
    if (text.contains('雪')) return AppAssets.toolboxWeatherBigThunderstorm;
    if (text.contains('阴') || text.contains('云')) {
      return AppAssets.toolboxWeatherBigCloudy;
    }
    return AppAssets.toolboxWeatherBigSun;
  }

  /// 小天气图标（对齐 Android QxWeatherAssets.smallWeatherIcon）
  String _smallWeatherIcon(String? condition) {
    final text = condition ?? '';
    if (text.contains('雨')) return AppAssets.weatherDayRain;
    if (text.contains('雪')) return AppAssets.weatherDayThunderstorm;
    if (text.contains('阴') || text.contains('云')) {
      return AppAssets.weatherDayCloudy;
    }
    return AppAssets.weatherDaySun;
  }

  /// runCatching + 兜底（对齐 Android runCatching{...}.getOrElse）
  Future<T> _runCatching<T>(
    Future<T> Function() block, {
    required T Function() fallback,
  }) async {
    try {
      return await block();
    } catch (_) {
      return fallback();
    }
  }

  /// runCatching + 失败返回 null（对齐 Android runCatching{...}.getOrNull）
  Future<T?> _runCatchingNull<T>(Future<T> Function() block) async {
    try {
      return await block();
    } catch (_) {
      return null;
    }
  }
}

extension _NotBlank on String? {
  /// 对齐 Android String?.takeNotBlank()
  String? _takeNotBlank() => this?.isNotEmpty == true ? this : null;
}

extension _NowFields on AirbeanDTO? {
  /// /v7/weather/now 的风速（对齐 Android now?.windSpeed 回退）
  String? _takeNotBlankWindSpeed() => this?.windSpeed.isNotEmpty == true
      ? this!.windSpeed
      : null;

  /// /v7/weather/now 的气压（对齐 Android now?.pressure 回退）
  String? _takeNotBlankPressure() =>
      this?.pressure.isNotEmpty == true ? this!.pressure : null;

  /// /v7/weather/now 的湿度（对齐 Android now?.humidity 回退）
  String? _takeNotBlankHumidity() =>
      this?.humidity.isNotEmpty == true ? this!.humidity : null;
}
