// 天气数据仓库 - 对齐 Android TravelViewModel.loadData 流程
// 调用 Service,DTO→模型转换,15d 失败回退 7d
import '../models/weather_model.dart';
import '../models/weather_mapper.dart';
import '../services/weather_service.dart';

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
}
