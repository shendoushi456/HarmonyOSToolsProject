// 天气图标映射工具 - 迁移自 Android WeatherChildFragment large/smallWeatherIcon
// 根据天气文字描述返回对应图标资源路径
import '../constants/app_assets.dart';

class WeatherIconUtil {
  WeatherIconUtil._();

  /// 大天气图标(用于天气卡片左侧圆形图标)
  static String largeIcon(String condition) {
    if (condition.contains('雷')) {
      return AppAssets.weatherThunder;
    }
    if (condition.contains('雨') || condition.contains('雪')) {
      return AppAssets.weatherLarge;
    }
    if (condition.contains('晴') && !condition.contains('云')) {
      return AppAssets.weatherSunny;
    }
    return AppAssets.weatherLarge;
  }

  /// 小天气图标(用于逐小时预报、15日预报列表/趋势)
  static String smallIcon(String condition) {
    if (condition.contains('雷')) {
      return AppAssets.weatherThunder;
    }
    if (condition.contains('雨') || condition.contains('雪')) {
      return AppAssets.weatherRain;
    }
    if (condition.contains('晴') && !condition.contains('云')) {
      return AppAssets.weatherSunny;
    }
    return AppAssets.weatherCloudy;
  }
}
