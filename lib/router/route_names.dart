// 路由名集中定义 - 禁止散落字符串跳转
class RouteNames {
  RouteNames._();

  /// 底部 Tab 容器
  static const String home = 'home';

  /// 启动页(对齐 Android SplashActivity)
  static const String splash = 'splash';

  /// Tab1 天气(首页)
  static const String weather = 'weather';

  /// Tab2 日历(预留)
  static const String calendar = 'calendar';

  /// Tab3 空气质量(预留)
  static const String airQuality = 'airQuality';

  /// 城市选择页(单选模式) - 对齐 Android AddCityActivity
  static const String citySelect = 'citySelect';

  /// 设置页(对齐 Android Setting4Activity)
  static const String setting = 'setting';

  /// 协议页(对齐 Android PolicyToolsSetActivity,query: title+url)
  static const String policy = 'policy';

  /// 关于页(对齐 Android AboutToolSetActivity)
  static const String about = 'about';

  /// 反馈页(对齐 Android FeedBackSettingActivity)
  static const String feedback = 'feedback';

  /// 二十四节气 H5 页(对齐 Android WeatherWebViewActivity 加载 ershisijieqi/index.html)
  static const String solarTerms = 'solarTerms';

  /// 历史上的今天页(对齐 Android HistoryActivity)
  static const String historyToday = 'historyToday';

  /// 生活小贴士 H5 页(对齐 Android WeatherWebViewActivity 加载 xiaoqiaomen.html)
  static const String lifeTips = 'lifeTips';

  /// 长途规划（对齐 Android LongTripPlanActivity）
  static const String longTrip = 'longTrip';
}

class RoutePaths {
  RoutePaths._();

  /// 启动页路径
  static const String splash = '/splash';

  static const String weather = '/weather';
  static const String calendar = '/calendar';
  static const String airQuality = '/airQuality';

  /// 城市选择页路径
  static const String citySelect = '/citySelect';

  /// 设置页路径
  static const String setting = '/setting';

  /// 协议页路径(query: ?title=&url=)
  static const String policy = '/policy';

  /// 关于页路径
  static const String about = '/about';

  /// 反馈页路径
  static const String feedback = '/feedback';

  /// 二十四节气 H5 页路径
  static const String solarTerms = '/solarTerms';

  /// 历史上的今天页路径
  static const String historyToday = '/historyToday';

  /// 生活小贴士 H5 页路径
  static const String lifeTips = '/lifeTips';

  static const String longTrip = '/longTrip';
}
