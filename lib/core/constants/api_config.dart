// API 配置 - 和风天气接口常量
class ApiConfig {
  ApiConfig._();

  /// 和风天气 API 基础地址
  static const String baseUrl = 'https://nw63yugrmd.yun.qweatherapi.com';

  /// API Key
  static const String apiKey = '2c03afea14054273846f8a8148b2b26b';

  /// 城市定位查询 - /geo/v2/city/lookup
  static const String pathCityLookup = '/geo/v2/city/lookup';

  /// 7天预报 - /v7/weather/7d
  static const String pathWeather7d = '/v7/weather/7d';

  /// 15天预报 - /v7/weather/15d
  static const String pathWeather15d = '/v7/weather/15d';

  /// 24 小时预报（NongyeFragment 的降水预警数据源）
  static const String pathWeather24h = '/v7/weather/24h';

  /// 实时天气。空气质量页按 Android AirQualityChildFragment 的方式，
  /// 独立读取当前温度和天气现象，不能用日预报的最高温替代。
  static const String pathWeatherNow = '/v7/weather/now';

  /// 实时空气质量 - /v7/air/now
  static const String pathAirNow = '/v7/air/now';

  /// 实时气象灾害预警。路径使用城市经纬度，而非 location id。
  static const String pathWeatherAlert = '/weatheralert/v1/current';

  /// 网络超时时间(秒) - 对齐 Android 端 120s
  static const int connectTimeout = 120;
  static const int receiveTimeout = 120;

  /// 成功状态码
  static const String codeSuccess = '200';
}
