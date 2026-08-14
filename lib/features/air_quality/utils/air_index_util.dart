// 空气质量生活指数工具 - 对齐 Android TravelViewModel 的 generate 方法 + buildIndices
import '../../../core/constants/app_assets.dart';
import '../../weather/models/weather_model.dart';
import '../models/air_index_item.dart';

class AirIndexUtil {
  AirIndexUtil._();

  /// 紫外线描述 - 对齐 generateUvDescription(行 382-391)
  static String generateUvDescription(String uvIndexStr) {
    final uv = int.tryParse(uvIndexStr);
    if (uv == null) return '较弱';
    if (uv <= 2) return '最弱';
    if (uv <= 5) return '中等';
    if (uv <= 7) return '强';
    if (uv <= 10) return '很强';
    return '极强';
  }

  /// 化妆指数 - 对齐 generateMakeup(行 412-445)
  static String generateMakeup(
    String tempMax,
    String humidity,
    String weather,
  ) {
    final maxTemp = int.tryParse(tempMax) ?? 0;
    final humidityValue = int.tryParse(humidity) ?? 0;
    if (weather.contains('雨') || weather.contains('雪')) return '防水彩妆';
    if (maxTemp >= 28 && humidityValue >= 75) return '控油定妆';
    if (weather.contains('风') && maxTemp <= 15) return '注意保湿';
    if (maxTemp >= 30) return '宜清爽些';
    if (maxTemp <= 5) return '需重保湿';
    return '适宜妆容';
  }

  /// 旅游指数 - 对齐 generateTravel(行 451-458)
  static String generateTravel(String tempMax, String weather) {
    final maxTemp = int.tryParse(tempMax) ?? 0;
    if (weather.contains('雨') || weather.contains('雪')) return '不宜出游';
    if (maxTemp > 35 || maxTemp < 0) return '谨慎出游';
    return '适宜出游';
  }

  /// 出行指数 - 对齐 generateTraffic(行 464-473)
  static String generateTraffic(String weather) {
    if (weather.contains('雨') ||
        weather.contains('雪') ||
        weather.contains('雾')) {
      return '请慢行';
    }
    return '宜出行';
  }

  /// AQI 推算 category - 对齐 getAirQuality(行 335-347)
  static String getAirQuality(String tempMax, String humidity) {
    final temp = int.tryParse(tempMax) ?? 0;
    final humid = int.tryParse(humidity) ?? 0;
    if (temp <= 10 && humid <= 30) return '优';
    if (temp <= 25 && humid <= 60) return '良';
    if (temp <= 30 && humid <= 80) return '优';
    if (temp > 30 || humid > 80) return '良';
    return '优';
  }

  /// AQI 数值映射 category - 对齐 aqiCategory(行 418-425)
  static String aqiCategory(int aqi) {
    if (aqi <= 50) return '优';
    if (aqi <= 100) return '良';
    if (aqi <= 150) return '轻度污染';
    if (aqi <= 200) return '中度污染';
    if (aqi <= 300) return '重度污染';
    return '严重污染';
  }

  /// 构建生活指数列表 - 对齐 buildIndices(行 376-416)
  /// 含 traffic/travel 重映射:
  ///   宜出行→一般, 请慢行→较差, 适宜出游→较容易, 不宜出游→较不易
  static List<AirIndexItem> buildIndices(DailyWeather? now) {
    // 默认值 - 对齐行 377-381
    final tempMax = now?.tempMax ?? '25';
    final tempMin = now?.tempMin ?? '15';
    final humidity = now?.humidity ?? '60';
    final weather =
        (now?.textDay == null || now!.textDay.isEmpty) ? '多云' : now.textDay;
    final uv = now?.uvIndex ?? '4';

    // 穿衣指数 - 内联计算(对齐行 382-388)
    final maxTempInt = int.tryParse(tempMax) ?? 25;
    final minTempInt = int.tryParse(tempMin) ?? 15;
    final average = (maxTempInt + minTempInt) ~/ 2;
    final clothing = average >= 28
        ? '炎热'
        : average >= 20
            ? '较舒适'
            : average >= 10
                ? '较凉'
                : '寒冷';

    // 出行指数 - generateTraffic + 重映射(对齐行 389-395)
    final trafficRaw = generateTraffic(weather);
    final traffic = trafficRaw == '宜出行'
        ? '一般'
        : trafficRaw == '请慢行'
            ? '较差'
            : trafficRaw;

    // 旅游指数 - generateTravel + 重映射(对齐行 396-402)
    final travelRaw = generateTravel(tempMax, weather);
    final travel = travelRaw == '适宜出游'
        ? '较容易'
        : travelRaw == '不宜出游'
            ? '较不易'
            : travelRaw;

    return [
      AirIndexItem(
        title: '紫外线指数',
        value: generateUvDescription(uv),
        imageAsset: AppAssets.airUv,
        iconType: AirIconType.sun,
      ),
      AirIndexItem(
        title: '化妆指数',
        value: generateMakeup(tempMax, humidity, weather),
        imageAsset: AppAssets.airMakeup,
        iconType: AirIconType.sun,
      ),
      AirIndexItem(
        title: '穿衣指数',
        value: clothing,
        imageAsset: null,
        iconType: AirIconType.clothing,
      ),
      AirIndexItem(
        title: '出行指数',
        value: traffic,
        imageAsset: null,
        iconType: AirIconType.transit,
      ),
      AirIndexItem(
        title: '旅游指数',
        value: travel,
        imageAsset: null, // 旅游图标用 CustomPainter TRAVEL(安卓只有 XML 矢量图,无 PNG)
        iconType: AirIconType.travel,
      ),
      AirIndexItem(
        title: '防晒指数',
        value: generateUvDescription(uv),
        imageAsset: null,
        iconType: AirIconType.sun,
      ),
    ];
  }
}
