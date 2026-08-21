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

  // ====== 畅行（bus）模块路由 - 对齐 Android bus 包 Activity ======
  /// 搜索选址页(对齐 Android BusSearchActivity)
  static const String busSearch = 'busSearch';

  /// 地图搜索页(对齐 Android BusMapSearchActivity)
  static const String busMapSearch = 'busMapSearch';

  /// 路线规划页(对齐 Android MapRouteActivity)
  static const String mapRoute = 'mapRoute';

  /// 路线导航页(对齐 Android BusRouteActivity)
  static const String busRoute = 'busRoute';

  /// 地点详情页(对齐 Android BusLocationDetailActivity)
  static const String busLocationDetail = 'busLocationDetail';

  /// 公交换乘详情页(对齐 Android BusRouteLineDetailActivity)
  static const String busRouteLineDetail = 'busRouteLineDetail';

  /// 导航页(对齐 Android MapNaviActivity)
  static const String mapNavi = 'mapNavi';

  /// 步行导航页(对齐 Android WalkNaviActivity)
  static const String walkNavi = 'walkNavi';

  /// 迪士尼攻略页(对齐 Android DisneyShangHaiScenicDetailActivity)
  static const String disneyScenic = 'disneyScenic';

  /// 图片攻略页(对齐 Android EditorPicTipsActivity)
  static const String editorPicTips = 'editorPicTips';

  /// 乐山峨眉攻略页(对齐 Android LeShanScenicDetailActivity)
  static const String leShanScenic = 'leShanScenic';
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

  // ====== 畅行（bus）模块路由路径 ======
  /// 搜索选址页路径
  static const String busSearch = '/busSearch';

  /// 地图搜索页路径
  static const String busMapSearch = '/busMapSearch';

  /// 路线规划页路径
  static const String mapRoute = '/mapRoute';

  /// 路线导航页路径
  static const String busRoute = '/busRoute';

  /// 地点详情页路径
  static const String busLocationDetail = '/busLocationDetail';

  /// 公交换乘详情页路径
  static const String busRouteLineDetail = '/busRouteLineDetail';

  /// 导航页路径
  static const String mapNavi = '/mapNavi';

  /// 步行导航页路径
  static const String walkNavi = '/walkNavi';

  // ====== 旅行规划（travel）模块路由路径 ======
  /// 迪士尼攻略页路径
  static const String disneyScenic = '/disneyScenic';

  /// 图片攻略页路径
  static const String editorPicTips = '/editorPicTips';

  /// 乐山峨眉攻略页路径
  static const String leShanScenic = '/leShanScenic';
}
