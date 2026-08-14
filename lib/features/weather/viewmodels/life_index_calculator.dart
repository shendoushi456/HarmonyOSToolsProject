// 生活指数计算器 - 迁移自 Android TravelViewModel 的 7 个生活指数方法
// 基于天气数据本地计算,不依赖额外 API

class LifeIndexCalculator {
  LifeIndexCalculator._();

  /// 穿衣指数(基于平均温度)
  static String generateDressing(String tempMax, String tempMin) {
    final max = int.tryParse(tempMax) ?? 20;
    final min = int.tryParse(tempMin) ?? 10;
    final avg = (max + min) ~/ 2;
    if (avg >= 30) return '短袖';
    if (avg >= 22) return 'T恤';
    if (avg >= 15) return '夹克';
    if (avg >= 8) return '毛衣';
    return '棉服';
  }

  /// 紫外线描述
  static String generateUvDescription(String uvIndexStr) {
    final uv = int.tryParse(uvIndexStr) ?? 0;
    if (uv <= 2) return '最弱';
    if (uv <= 5) return '中等';
    if (uv <= 7) return '强';
    if (uv <= 10) return '很强';
    return '极强';
  }

  /// 紫外线防护建议
  static String generateUv(String uvIndexStr) {
    final uv = int.tryParse(uvIndexStr) ?? 0;
    if (uv <= 2) return '无需防护';
    if (uv <= 5) return '适当防护';
    if (uv <= 7) return '注意防晒';
    if (uv <= 10) return '避免暴晒';
    return '务必防晒';
  }

  /// 化妆指数
  static String generateMakeup(
      String tempMax, String humidity, String condition) {
    final maxTemp = int.tryParse(tempMax) ?? 20;
    final humidityValue = int.tryParse(humidity) ?? 50;
    if (condition.contains('雨') || condition.contains('雪')) return '防水彩妆';
    if (maxTemp >= 28 && humidityValue >= 75) return '控油定妆';
    if (condition.contains('风') && maxTemp <= 15) return '注意保湿';
    if (maxTemp >= 30) return '宜清爽些';
    if (maxTemp <= 5) return '需重保湿';
    return '适宜妆容';
  }

  /// 旅游指数
  static String generateTravel(String tempMax, String condition) {
    final maxTemp = int.tryParse(tempMax) ?? 20;
    if (condition.contains('雨') || condition.contains('雪')) return '不宜出游';
    if (maxTemp > 35 || maxTemp < 0) return '谨慎出游';
    return '适宜出游';
  }

  /// 交通指数
  static String generateTraffic(String condition) {
    if (condition.contains('雨') ||
        condition.contains('雪') ||
        condition.contains('雾')) {
      return '请慢行';
    }
    return '宜出行';
  }

  /// 运动指数
  static String generateSport(
      String tempMax, String tempMin, String condition, String humidity) {
    final maxTemp = int.tryParse(tempMax) ?? 20;
    final minTemp = int.tryParse(tempMin) ?? 10;
    final avgTemp = (maxTemp + minTemp) ~/ 2;
    final humidityValue = int.tryParse(humidity) ?? 50;
    if (condition.contains('雨') || condition.contains('雪')) return '不适宜';
    if (condition.contains('雾') || condition.contains('霾')) return '不适宜';
    if (avgTemp > 35 || avgTemp < -5) return '不适宜';
    if (avgTemp > 32 || avgTemp < 0) return '较不适宜';
    if (humidityValue > 85) return '较不适宜';
    if (avgTemp >= 15 && avgTemp <= 25 && humidityValue >= 40 && humidityValue <= 70) {
      return '适宜';
    }
    return '较适宜';
  }

  /// 洗车指数
  static String generateCarWash(String condition, String precip) {
    final precipitation = double.tryParse(precip) ?? 0;
    if (condition.contains('雨') || condition.contains('雪')) return '不适宜';
    if (condition.contains('沙尘') || condition.contains('霾')) return '不适宜';
    if (precipitation > 0.5) return '不适宜';
    if (condition.contains('多云') || condition.contains('阴')) return '较适宜';
    if (condition.contains('晴') || condition.contains('少云')) return '适宜';
    return '适宜';
  }

  /// 日照进度计算(0.0~1.0)
  /// 默认日出 06:00, 日落 18:00
  static double calculateDaylightProgress(String? sunrise, String? sunset) {
    final now = DateTime.now();
    final nowSeconds = now.hour * 3600 + now.minute * 60 + now.second;

    int sunriseSeconds = 6 * 3600; // 默认 06:00
    int sunsetSeconds = 18 * 3600; // 默认 18:00

    if (sunrise != null && sunrise.isNotEmpty) {
      final parts = sunrise.split(':');
      if (parts.length >= 2) {
        sunriseSeconds = (int.tryParse(parts[0]) ?? 6) * 3600 +
            (int.tryParse(parts[1]) ?? 0) * 60;
      }
    }
    if (sunset != null && sunset.isNotEmpty) {
      final parts = sunset.split(':');
      if (parts.length >= 2) {
        sunsetSeconds = (int.tryParse(parts[0]) ?? 18) * 3600 +
            (int.tryParse(parts[1]) ?? 0) * 60;
      }
    }

    final totalDaylight = sunsetSeconds - sunriseSeconds;
    if (totalDaylight <= 0) return 0;

    final progress = (nowSeconds - sunriseSeconds) / totalDaylight;
    return progress.clamp(0.0, 1.0);
  }
}
