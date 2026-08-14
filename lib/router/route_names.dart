// 路由名集中定义 - 禁止散落字符串跳转
class RouteNames {
  RouteNames._();

  /// 底部 Tab 容器
  static const String home = 'home';

  /// Tab1 天气(首页)
  static const String weather = 'weather';

  /// Tab2 日历(预留)
  static const String calendar = 'calendar';

  /// Tab3 空气质量(预留)
  static const String airQuality = 'airQuality';
}

class RoutePaths {
  RoutePaths._();

  static const String weather = '/weather';
  static const String calendar = '/calendar';
  static const String airQuality = '/airQuality';
}
