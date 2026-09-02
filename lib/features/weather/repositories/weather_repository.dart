// 天气数据仓库 - 对齐 Android TravelViewModel.loadData 流程
// 调用 Service,DTO→模型转换,15d 失败回退 7d
import '../models/weather_model.dart';
import '../models/hourly_weather.dart';
import '../models/weather_mapper.dart';
import '../services/weather_service.dart';
import '../models/weather_warning.dart';

/// 城市定位后的农业气象数据。一次定位，复用同一 locationId / 经纬度请求，
/// 与 Android TravelViewModel 的请求顺序保持一致。
class AgricultureWeatherData {
  final WeatherInfo? dailyWeather;
  final List<HourlyWeather> hourlyWeather;
  final List<WeatherWarning> warnings;

  const AgricultureWeatherData({
    required this.dailyWeather,
    required this.hourlyWeather,
    required this.warnings,
  });
}

class WeatherRepository {
  final WeatherService _service;

  WeatherRepository({WeatherService? service})
      : _service = service ?? WeatherService();

  /// 城市名 → 城市ID
  /// 对应 Android WeatherUtils.getCityLocationID
  Future<String> resolveCityId(String cityName) async {
    final location = await _service.lookupCity(cityName);
    return location.id;
  }

  /// 加载每日预报(15天,失败回退7天)
  /// 对应 Android TravelViewModel.getWeather15Day + getWeather7Day
  Future<WeatherInfo> loadDailyWeather(String cityId) async {
    try {
      final dto = await _service.getWeather15d(cityId);
      return WeatherMapper.toWeatherInfo(dto);
    } catch (e) {
      // 15d 失败,回退到 7d
      final dto = await _service.getWeather7d(cityId);
      return WeatherMapper.toWeatherInfo(dto);
    }
  }

  /// 加载空气质量
  /// 对应 Android TravelViewModel.getAQI
  Future<AirQuality?> loadAirQuality(String cityId) async {
    try {
      final dto = await _service.getAirNow(cityId);
      if (dto.now != null) {
        return WeatherMapper.toAirQuality(dto.now!);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 加载实时天气，供空气质量页显示 Android 原版的天气图标与当前温度。
  Future<CurrentWeather?> loadCurrentWeather(String cityId) async {
    try {
      final dto = await _service.getWeatherNow(cityId);
      final now = dto.now;
      return now == null ? null : WeatherMapper.toCurrentWeather(now);
    } catch (_) {
      return null;
    }
  }

  /// 按城市名查询预警。定位失败或接口暂不可用时交由调用方以空态呈现。
  Future<List<WeatherWarning>> loadWarnings(String cityName) async {
    final location = await _service.lookupCity(cityName);
    if (location.latitude.isEmpty || location.longitude.isEmpty)
      return const [];
    return _service.getWeatherAlerts(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  Future<List<HourlyWeather>> loadHourlyWeather(String cityName) async {
    final cityId = await resolveCityId(cityName);
    return _service.getWeather24h(cityId);
  }

  /// 农业页完整数据请求：先城市名→locationId，再并发获取日预报、24h 与预警。
  Future<AgricultureWeatherData> loadAgricultureWeather(String cityName) async {
    final location = await _service.lookupCity(cityName);
    final results = await Future.wait<Object?>([
      _loadDailySafely(location.id),
      _loadHourlySafely(location.id),
      _loadWarningsForLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      ).catchError((_) => <WeatherWarning>[]),
    ]);
    return AgricultureWeatherData(
      dailyWeather: results[0] as WeatherInfo?,
      hourlyWeather: results[1] as List<HourlyWeather>,
      warnings: results[2] as List<WeatherWarning>,
    );
  }

  Future<List<WeatherWarning>> _loadWarningsForLocation({
    required String latitude,
    required String longitude,
  }) {
    if (latitude.isEmpty || longitude.isEmpty) return Future.value(const []);
    return _service.getWeatherAlerts(
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<WeatherInfo?> _loadDailySafely(String cityId) async {
    try {
      return await loadDailyWeather(cityId);
    } catch (_) {
      return null;
    }
  }

  Future<List<HourlyWeather>> _loadHourlySafely(String cityId) async {
    try {
      return await _service.getWeather24h(cityId);
    } catch (_) {
      return const [];
    }
  }
}
