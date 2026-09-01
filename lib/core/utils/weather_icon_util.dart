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

  /// toolbox_c 常用工具页/天气页使用的和风天气日间图标。
  ///
  /// 接口优先返回天气代码；文字仅作为接口无代码时的兜底，避免各页面
  /// 各自维护一份映射而出现图标不一致。
  static String toolboxDayIcon(String code, String condition) {
    if (code == '100') return AppAssets.toolboxWeatherIcon0d;
    if (const <String>{
      '101',
      '102',
      '103',
      '104',
      '151',
      '152',
      '153',
      '154',
    }.contains(code)) {
      return 'assets/images/toolbox_yingtian_icon.png';
    }
    if (const <String>{'302', '303', '304'}.contains(code)) {
      return 'assets/images/toolbox_dalei_icn.png';
    }
    if (const <String>{
      '400',
      '401',
      '402',
      '403',
      '408',
      '409',
      '410',
    }.contains(code)) {
      return AppAssets.toolboxWeatherIcon7a;
    }
    if (const <String>{
      '300',
      '301',
      '305',
      '306',
      '307',
      '308',
      '309',
      '310',
      '311',
      '312',
      '314',
      '315',
      '316',
      '317',
      '318',
      '350',
      '351',
      '399',
    }.contains(code)) {
      return 'assets/images/toolbox_xiayu_icon.png';
    }
    if (condition.contains('晴')) return AppAssets.toolboxWeatherIcon0d;
    if (condition.contains('雷')) return AppAssets.toolboxWeatherIcon4a;
    if (condition.contains('雨')) return AppAssets.toolboxWeatherIcon6a;
    if (condition.contains('雪')) return AppAssets.toolboxWeatherIcon7a;
    return AppAssets.toolboxWeatherIcon1a;
  }
}
