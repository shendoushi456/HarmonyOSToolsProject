// 天气数据映射器 - DTO → 领域模型转换
// 对应 Android 中 Gson 解析后手动构建 UI 模型的过程
import 'weather_dto.dart';
import 'weather_model.dart';

class WeatherMapper {
  WeatherMapper._();

  /// WeatherBeanInfoDTO → WeatherInfo
  static WeatherInfo toWeatherInfo(WeatherBeanInfoDTO dto) {
    return WeatherInfo(
      code: dto.code,
      daily: dto.daily.map(toDailyWeather).toList(),
      air: dto.now != null ? toAirQuality(dto.now!) : null,
    );
  }

  /// Weather7DDTO → DailyWeather
  static DailyWeather toDailyWeather(Weather7DDTO dto) {
    return DailyWeather(
      sunrise: dto.sunrise,
      sunset: dto.sunset,
      tempMax: dto.tempMax,
      tempMin: dto.tempMin,
      fxDate: dto.fxDate,
      iconDay: dto.iconDay,
      textDay: dto.textDay,
      windDirDay: dto.windDirDay,
      windScaleDay: dto.windScaleDay,
      windSpeedDay: dto.windSpeedDay,
      humidity: dto.humidity,
      pressure: dto.pressure,
      precip: dto.precip,
      uvIndex: dto.uvIndex,
      vis: dto.vis,
    );
  }

  /// AirbeanDTO → AirQuality
  static AirQuality toAirQuality(AirbeanDTO dto) {
    return AirQuality(
      aqi: dto.aqi,
      category: dto.category,
      level: dto.level,
      primary: dto.primary,
      pm10: dto.pm10,
      pm2p5: dto.pm2p5,
      no2: dto.no2,
      o3: dto.o3,
      co: dto.co,
      so2: dto.so2,
    );
  }
}
