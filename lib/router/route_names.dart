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
  static const String recognition = 'recognition';

  // ====== toolbox_c 首页链路二级页(保真: 原首页入口按钮 gone,暂无 UI 入口) ======
  /// 附近 WiFi 列表 - 对齐 Android WiFiListActivity
  static const String wifiList = 'wifiList';

  /// WiFi 详情 - 对齐 Android WiFiStrengthActivity(首页 Wi-Fi详情卡可达)
  static const String wifiStrength = 'wifiStrength';

  /// 网速测试 - 对齐 Android SpeedNetActivity
  static const String speedNet = 'speedNet';

  /// WiFi 设置(通知网速) - 对齐 Android AppSettingsActivity
  static const String wifiSettings = 'wifiSettings';

  // ====== toolbox_c 工具箱链路二级页 ======
  /// 特效图(LowPoly) - 对齐 Android PictureLowPolyActivity
  static const String lowPoly = 'lowPoly';

  /// 自制二维码 - 对齐 Android QRCodeActivity
  static const String qrCode = 'qrCode';

  /// LED滚动设置 - 对齐 Android LedActivity
  static const String led = 'led';

  /// LED 全屏显示 - 对齐 Android Led1/Led2Activity(query: mode/text/bg/fg/size/speed)
  static const String ledDisplay = 'ledDisplay';

  // ====== toolbox_c 工具箱 PDF 功能(复用 master_mianfeisaosaowang 迁移实现) ======
  /// PDF 转图片
  static const String pdfToImage = 'pdfToImage';

  /// 图片转 PDF
  static const String imageToPdf = 'imageToPdf';

  /// PDF 加密
  static const String pdfEncrypt = 'pdfEncrypt';

  /// PDF 压缩
  static const String pdfCompress = 'pdfCompress';
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
  static const String recognition = '/recognition';

  // ====== toolbox_c 首页链路二级页 ======
  static const String wifiList = '/wifiList';
  static const String wifiStrength = '/wifiStrength';
  static const String speedNet = '/speedNet';
  static const String wifiSettings = '/wifiSettings';

  // ====== toolbox_c 工具箱链路二级页 ======
  static const String lowPoly = '/lowPoly';
  static const String qrCode = '/qrCode';
  static const String led = '/led';
  static const String ledDisplay = '/ledDisplay';

  // ====== toolbox_c 工具箱 PDF 功能 ======
  static const String pdfToImage = '/pdfToImage';
  static const String imageToPdf = '/imageToPdf';
  static const String pdfEncrypt = '/pdfEncrypt';
  static const String pdfCompress = '/pdfCompress';
}
