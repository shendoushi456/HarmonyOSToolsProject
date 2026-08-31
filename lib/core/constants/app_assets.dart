// 资源路径常量 - 统一管理所有图片资源路径
class AppAssets {
  AppAssets._();

  static const String _base = 'assets/images';

  /// 顶部天空背景
  static const String skyBackground = '$_base/qmtq_sky_background.png';

  /// 天气卡片背景
  static const String homeWeatherCard = '$_base/qmtq_home_weather_card.png';

  /// 小时预报卡背景
  static const String homeHourlyCard = '$_base/qmtq_home_hourly_card.png';

  /// 趋势卡背景
  static const String homeTrendCard = '$_base/qmtq_home_trend_card.png';

  /// 列表卡背景
  static const String homeListCard = '$_base/qmtq_home_list_card.png';

  /// 城市切换图标
  static const String weatherCitySwitch = '$_base/qmtq_weather_city_switch.png';

  /// 风速指标图标
  static const String weatherWind = '$_base/qmtq_weather_wind.png';

  /// 气压指标图标
  static const String weatherPressure = '$_base/qmtq_weather_pressure.png';

  /// 湿度指标图标
  static const String weatherHumidity = '$_base/qmtq_weather_humidity.png';

  /// 大天气图标(雨/雪/默认)
  static const String weatherLarge = '$_base/qmtq_weather_large.png';

  // ====== 新 UI 资源（对齐 Android 第一个 WeatherFragment Compose UI）======
  /// TemperatureDisplay 卡片背景图（对齐 Android weather_lbg）
  static const String weatherCardBg = '$_base/weather_lbg.png';

  /// 顶部栏定位图标（对齐 Android llocation，黑色 tint）
  static const String weatherLocation = '$_base/llocation.png';

  /// 二十四节气卡片图标（对齐 Android llifejq）
  static const String weatherToolSolarTerms = '$_base/llifejq.png';

  /// 历史上的今天卡片图标（对齐 Android llifetoday）
  static const String weatherToolHistoryToday = '$_base/llifetoday.png';

  /// 卡片右箭头 18dp（对齐 Android arrow_right_ic，区别于设置页 arrowRight）
  static const String arrowRightIcon = '$_base/arrow_right_ic.png';

  /// 七日预报 - 晴天图标（对齐 Android ic_six_7day_sun）
  static const String weatherDaySun = '$_base/ic_six_7day_sun.png';

  /// 七日预报 - 多云/阴图标（对齐 Android ic_six_7day_cloudy）
  static const String weatherDayCloudy = '$_base/ic_six_7day_cloudy.png';

  /// 七日预报 - 雨图标（对齐 Android ic_six_7day_rain，雷也复用此图标——还原原 Bug）
  static const String weatherDayRain = '$_base/ic_six_7day_rain.png';

  /// 七日预报 - 雷雨图标（对齐 Android ic_six_7day_thunderstorm，保真保留未启用）
  static const String weatherDayThunderstorm = '$_base/ic_six_7day_thunderstorm.png';

  // ====== 空气质量新 UI 资源（对齐 Android WeatherShChildFragment Compose UI）======
  /// 风速图标（对齐 Android ic_feng_main_2_1，WeatherInfoCard 风速项）
  static const String airWindSpeed = '$_base/ic_feng_main_2_1.png';

  /// 气压图标（对齐 Android ic_feng_main_2_2，WeatherInfoCard 气压项）
  static const String airPressure = '$_base/ic_feng_main_2_2.png';

  /// 湿度图标（对齐 Android ic_feng_main_2_3，WeatherInfoCard 湿度项）
  static const String airHumidity = '$_base/ic_feng_main_2_3.png';

  /// PM2.5 污染物图标（对齐 Android ic_shzn_01，细颗粒物）
  static const String icShzn01 = '$_base/ic_shzn_01.png';

  /// PM10 污染物图标（对齐 Android ic_shzn_02，粗颗粒度）
  static const String icShzn02 = '$_base/ic_shzn_02.png';

  /// NO₂ 污染物图标（对齐 Android ic_shzn_03，二氧化氮）
  static const String icShzn03 = '$_base/ic_shzn_03.png';

  /// SO₂ 污染物图标（对齐 Android ic_shzn_04，二氧化硫）
  static const String icShzn04 = '$_base/ic_shzn_04.png';

  /// CO 污染物图标（对齐 Android ic_shzn_05，一氧化碳）
  static const String icShzn05 = '$_base/ic_shzn_05.png';

  /// O3 污染物图标（对齐 Android ic_shzn_06，臭氧）
  static const String icShzn06 = '$_base/ic_shzn_06.png';

  // ====== WeatherChildFragment Compose UI 资源（对齐 Android WeatherChildFragment）======
  /// 4 指标卡气压列图标（对齐 Android ic_feng_main_2_4，WeatherInfoCard 第4列气压）
  /// 注意：现有 airPressure=_2_2 被 air_quality 模块复用，此处 _2_4 给天气页 WeatherInfoCard 第4列
  static const String weatherInfoPressure = '$_base/ic_feng_main_2_4.png';

  /// 日出图标（对齐 Android ic_feng_main_3_1，SunriseSunsetCard2 日出行）
  static const String sunriseIcon = '$_base/ic_feng_main_3_1.png';

  /// 日落图标（对齐 Android ic_feng_main_3_2，SunriseSunsetCard2 日落行）
  static const String sunsetIcon = '$_base/ic_feng_main_3_2.png';

  /// 日出日落进度条太阳图标（对齐 Android ic_sun.png，注意区别于日历模块的 ic_sun.webp/calendarSunIcon）
  static const String daylightSunIcon = '$_base/ic_sun.png';

  // ====== CalendarFragment 资源（对齐 Android CalendarFragment Compose UI）======
  /// 健康生活方式卡片图标 - 营养（对齐 Android ic_jkshfs_01，NewFunctionRow1）
  static const String icJkshfs01 = '$_base/ic_jkshfs_01.png';

  /// 健康生活方式卡片图标 - 如何缓解压力（对齐 Android ic_jkshfs_02，NewFunctionRow1）
  static const String icJkshfs02 = '$_base/ic_jkshfs_02.png';

  /// 健康生活方式卡片图标 - 24节气（对齐 Android ic_jkshfs_03，NewFunctionRow2）
  static const String icJkshfs03 = '$_base/ic_jkshfs_03.png';

  /// 健康生活方式卡片图标 - 历史上的今天（对齐 Android ic_jkshfs_04，NewFunctionRow2）
  static const String icJkshfs04 = '$_base/ic_jkshfs_04.png';

  /// WebView 标题栏返回箭头 - 黑色（对齐 Android icon_black_back）
  static const String webviewBackBlack = '$_base/icon_black_back.png';

  /// WebView 标题栏返回箭头（对齐 Android ic_back）
  static const String webviewBack = '$_base/ic_back.png';

  /// 晴图标
  static const String weatherSunny = '$_base/qmtq_weather_sunny.png';

  /// 多云图标
  static const String weatherCloudy = '$_base/qmtq_weather_cloudy.png';

  /// 雨图标
  static const String weatherRain = '$_base/qmtq_weather_rain.png';

  /// 雷图标
  static const String weatherThunder = '$_base/qmtq_weather_thunder.png';

  /// 15日天气标题图标
  static const String weatherForecastTitle = '$_base/qmtq_weather_forecast_title.png';

  /// 底部导航 - 天气（对齐 Android icon_tab_tools_1，ic_tab_1_true/false）
  static const String tabWeatherTrue = '$_base/ic_tab_1_true.png';
  static const String tabWeatherFalse = '$_base/ic_tab_1_false.png';

  /// 底部导航 - 日历（对齐 Android icon_tab_tools_2，ic_tab_2_true/false）
  static const String tabCalendarTrue = '$_base/ic_tab_2_true.png';
  static const String tabCalendarFalse = '$_base/ic_tab_2_false.png';

  /// 底部导航 - 生活指南（对齐 Android icon_tab_tools_3，ic_tab_3_true/false）
  static const String tabLifeGuideTrue = '$_base/ic_tab_3_true.png';
  static const String tabLifeGuideFalse = '$_base/ic_tab_3_false.png';

  /// 城市搜索图标(16dp)
  static const String icSearch = '$_base/ic_search.webp';

  // ====== 空气质量页资源 ======
  /// AQI 卡片右侧"实时更新"图标
  static const String airRefresh = '$_base/qmtq_air_refresh.png';

  /// 紫外线指数图标
  static const String airUv = '$_base/qmtq_air_uv.png';

  /// 化妆指数图标
  static const String airMakeup = '$_base/qmtq_air_makeup.png';

  // ====== 设置页资源 ======
  /// 应用 logo
  static const String appLogo = '$_base/ic_logo.png';

  /// 右箭头(设置项)
  static const String arrowRight = '$_base/arrow_right.png';

  /// 白色返回箭头(设置页顶部栏)
  static const String iconWhiteBack = '$_base/icon_white_back.webp';

  /// 用户协议图标
  static const String settingUserIcon = '$_base/setting_4_user_icon.webp';

  /// 隐私协议图标
  static const String settingPrivateIcon = '$_base/setting_4_private_icon.webp';

  /// 关于我们图标
  static const String settingAboutIcon = '$_base/setting_4_about_icon.webp';

  /// 意见反馈图标
  static const String settingFeedbackIcon = '$_base/setting_4_feedback_icon.webp';
}
