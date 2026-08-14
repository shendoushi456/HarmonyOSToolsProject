// 天气领域模型 - UI 直接消费的不可变模型
// 对应 Android WeatherChildFragment 内部数据类 + TravelViewModel.WeeklyForecast

/// 天气信息(完整)
class WeatherInfo {
  final String code;
  final List<DailyWeather> daily;
  final AirQuality? air;

  const WeatherInfo({
    required this.code,
    required this.daily,
    this.air,
  });
}

/// 每日天气(领域模型)
class DailyWeather {
  final String sunrise;
  final String sunset;
  final String tempMax;
  final String tempMin;
  final String fxDate;
  final String iconDay;
  final String textDay;
  final String windDirDay;
  final String windScaleDay;
  final String windSpeedDay;
  final String humidity;
  final String pressure;
  final String precip;
  final String uvIndex;
  final String vis;

  const DailyWeather({
    required this.sunrise,
    required this.sunset,
    required this.tempMax,
    required this.tempMin,
    required this.fxDate,
    required this.iconDay,
    required this.textDay,
    required this.windDirDay,
    required this.windScaleDay,
    required this.windSpeedDay,
    required this.humidity,
    required this.pressure,
    required this.precip,
    required this.uvIndex,
    required this.vis,
  });
}

/// 空气质量(领域模型)
class AirQuality {
  final int aqi;
  final String category;
  final String level;
  final String primary;
  final String pm10;
  final String pm2p5;
  final String no2;
  final String o3;
  final String co;
  final String so2;

  const AirQuality({
    required this.aqi,
    required this.category,
    required this.level,
    required this.primary,
    required this.pm10,
    required this.pm2p5,
    required this.no2,
    required this.o3,
    required this.co,
    required this.so2,
  });
}

/// 15日预报 UI 展示模型 - 对应 Android HomeForecast
class HomeForecast {
  final String dayLabel;
  final String dateLabel;
  final String tempMax;
  final String tempMin;
  final String condition;
  final String windDir;
  final String windScale;
  final String airCategory;

  const HomeForecast({
    required this.dayLabel,
    required this.dateLabel,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.windDir,
    required this.windScale,
    required this.airCategory,
  });
}

/// 逐小时预报 UI 展示模型 - 对应 Android HourForecast
class HourForecast {
  final String time;
  final String temperature;
  final String condition;

  const HourForecast({
    required this.time,
    required this.temperature,
    required this.condition,
  });
}
