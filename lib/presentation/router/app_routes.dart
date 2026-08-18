/// 路由路径常量
///
/// 集中管理路由路径，便于马甲包替换页面实现但保留路由路径。
abstract final class AppRoutes {
  /// 启动页（协议弹框 + 入口判断）
  static const splash = '/splash';

  /// ScanMenu 底部导航主页（3 Tab 容器）
  static const scanMenu = '/scan-menu';

  /// 违章代码查询输入页
  static const violationCodeSearch = '/violation-code/search';

  /// 违章代码查询结果页（:code 为查询的代码）
  static const violationCodeResult = '/violation-code/result/:code';

  /// 违章处理列表页
  static const violationProcessing = '/violation-processing';

  /// 汽车养护页
  static const carMaintenance = '/car-maintenance';

  /// 图片展示页前缀（详情类型通过路径参数拼接）
  static const carDetail = '/car-detail';

  /// 图片展示页路由模板（:type 为详情类型，如"交通标志"）
  static const carDetailPattern = '/car-detail/:type';

  /// 指示灯完整列表页
  static const indicatorLight = '/indicator-light';

  /// 驾照扣分规则页
  static const drivingLicense = '/driving-license';

  /// Markdown 页（空实现，还原原 Android Bug）
  static const markdown = '/markdown';

  /// 设置页
  static const settings = '/settings';

  /// 协议页（用户协议/隐私协议，extra 传 title + url）
  static const settingsPolicy = '/settings/policy';

  /// 关于页
  static const settingsAbout = '/settings/about';

  /// 意见反馈页
  static const settingsFeedback = '/settings/feedback';
}
