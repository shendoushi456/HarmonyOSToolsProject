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

  /// MoreFragment 可迁移工具页。
  static const String timeScreen = 'timeScreen';
  static const String compass = 'compass';
  static const String calculator = 'calculator';

  /// 新增倒数日页（对齐 Android AddClockIn 同级的 AddCountdownActivity）。
  static const String countdownAdd = 'countdownAdd';

  /// 添加账单页（对齐 Android AddExpenseActivity）。
  static const String expenseAdd = 'expenseAdd';

  /// 记事本列表与编辑页。
  static const String notebook = 'notebook';
  static const String notebookRecord = 'notebookRecord';
  static const String recognition = 'recognition';
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

  static const String timeScreen = '/timeScreen';
  static const String compass = '/compass';
  static const String calculator = '/calculator';
  static const String countdownAdd = '/countdownAdd';
  static const String expenseAdd = '/expenseAdd';
  static const String notebook = '/notebook';
  static const String notebookRecord = '/notebookRecord';
  static const String recognition = '/recognition';
}
