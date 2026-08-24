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

  /// 晴图标
  static const String weatherSunny = '$_base/qmtq_weather_sunny.png';

  /// 多云图标
  static const String weatherCloudy = '$_base/qmtq_weather_cloudy.png';

  /// 雨图标
  static const String weatherRain = '$_base/qmtq_weather_rain.png';

  /// 雷图标
  static const String weatherThunder = '$_base/qmtq_weather_thunder.png';

  /// 15日天气标题图标
  static const String weatherForecastTitle =
      '$_base/qmtq_weather_forecast_title.png';

  /// 底部导航 - 首页
  static const String tabHomeNormal = '$_base/qmtq_tab_home_normal.png';
  static const String tabHomeSelected = '$_base/qmtq_tab_home_selected.png';

  /// 底部导航 - 日历
  static const String tabCalendarNormal = '$_base/qmtq_tab_calendar_normal.png';
  static const String tabCalendarSelected =
      '$_base/qmtq_tab_calendar_selected.png';

  /// 底部导航 - 空气
  static const String tabAirNormal = '$_base/qmtq_tab_air_normal.png';
  static const String tabAirSelected = '$_base/qmtq_tab_air_selected.png';

  /// 日历卡片背景(335x328)
  static const String calendarCard = '$_base/qmtq_calendar_card.png';

  /// 日历上一月箭头(28dp)
  static const String calendarLeft = '$_base/qmtq_calendar_left.png';

  /// 日历下一月箭头(28dp)
  static const String calendarRight = '$_base/qmtq_calendar_right.png';

  /// 日历选中周背景
  static const String calendarWeekHighlight =
      '$_base/qmtq_calendar_week_highlight.png';

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
  static const String settingFeedbackIcon =
      '$_base/setting_4_feedback_icon.webp';

  // ====== 海拔/指南针页资源 ======
  /// 从 Android AltitudeFragment/CompassFragment 迁入并统一加 outdoor_ 前缀，避免资源重名。
  static const String outdoorHomeBackground =
      '$_base/outdoor_home_background.png';
  static const String outdoorAddressIcon = '$_base/outdoor_address_icon.png';
  static const String outdoorAirIcon = '$_base/outdoor_air_icon.png';
  static const String outdoorUvIcon = '$_base/outdoor_uv_icon.png';
  static const String outdoorWindDirectionIcon =
      '$_base/outdoor_wind_direction_icon.png';
  static const String outdoorWindSpeedIcon =
      '$_base/outdoor_wind_speed_icon.png';
  static const String outdoorAltitudeIcon = '$_base/outdoor_altitude_icon.png';

  // ====== WeatherChildFragment 天气详情资源 ======
  /// Android WeatherChildFragment 的整页深蓝背景。
  static const String weatherChildBackground =
      '$_base/weather_child_background.png';
  static const String weatherChildWindIcon = '$_base/weather_child_wind.png';
  static const String weatherChildPressureIcon =
      '$_base/weather_child_pressure.png';
  static const String weatherChildHumidityIcon =
      '$_base/weather_child_humidity.png';
  static const String weatherChildClothingIcon =
      '$_base/weather_child_clothing.png';
  static const String weatherChildSunblockIcon =
      '$_base/weather_child_sunblock.png';
  static const String weatherChildTravelIcon =
      '$_base/weather_child_travel.png';
  static const String weatherChildSportIcon = '$_base/weather_child_sport.png';
  static const String weatherChildTrafficIcon =
      '$_base/weather_child_traffic.png';
  static const String weatherChildMakeupIcon =
      '$_base/weather_child_makeup.png';
  static const String weatherChildUvIcon = '$_base/weather_child_uv.png';
  static const String weatherChildCarWashIcon =
      '$_base/weather_child_car_wash.png';

  // ====== ToolsBoxFragment 资源 ======
  static const String toolsBoxBackground =
      '$_base/toolsbox_home_background.png';
  static const String toolsBoxRuler = '$_base/toolsbox_ruler.png';
  static const String toolsBoxLevel = '$_base/toolsbox_level.png';
  static const String toolsBoxProtractor = '$_base/toolsbox_protractor.png';
  static const String toolsBoxTabNormal = '$_base/toolsbox_tab_normal.png';
  static const String toolsBoxTabSelected = '$_base/toolsbox_tab_selected.png';
  static const String toolsBoxSettingUser = '$_base/toolsbox_setting_user.png';
  static const String toolsBoxSettingPrivacy =
      '$_base/toolsbox_setting_privacy.png';
  static const String toolsBoxSettingAbout =
      '$_base/toolsbox_setting_about.png';
  static const String toolsBoxSettingFeedback =
      '$_base/toolsbox_setting_feedback.png';
  static const String toolsBoxSettingRevoke =
      '$_base/toolsbox_setting_revoke.png';
  static const String toolsBoxSettingCancel =
      '$_base/toolsbox_setting_cancel.png';
  static const String toolsBoxSettingArrow =
      '$_base/toolsbox_setting_arrow.png';

  // Android MainWeatherActivity 底部导航原始图标（xxhdpi，按 24dp 使用）。
  static const String bottomTabAltitudeNormal =
      '$_base/toolsbox_bottom_tab_1_normal.png';
  static const String bottomTabAltitudeSelected =
      '$_base/toolsbox_bottom_tab_1_selected.png';
  static const String bottomTabCompassNormal =
      '$_base/toolsbox_bottom_tab_2_normal.png';
  static const String bottomTabCompassSelected =
      '$_base/toolsbox_bottom_tab_2_selected.png';
  static const String bottomTabWeatherNormal =
      '$_base/toolsbox_bottom_tab_3_normal.png';
  static const String bottomTabWeatherSelected =
      '$_base/toolsbox_bottom_tab_3_selected.png';
  static const String bottomTabToolsNormal =
      '$_base/toolsbox_bottom_tab_4_normal.png';
  static const String bottomTabToolsSelected =
      '$_base/toolsbox_bottom_tab_4_selected.png';
}
