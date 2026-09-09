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
  static const String weatherDayThunderstorm =
      '$_base/ic_six_7day_thunderstorm.png';

  // ====== Toolbox 天气页资源 ======
  // 这些资源从 toolbox_c 的 WeatherChildFragment 当前 Compose 页面迁入，
  // 独立放在 toolbox_weather 命名空间，避免与现有马甲 UI 资源重名。
  static const String _toolboxWeatherBase = '$_base/toolbox_weather';

  static const String toolboxWeatherBackground =
      '$_toolboxWeatherBase/ic_six_weather_bg.png';
  static const String toolboxWeatherMainCard =
      '$_toolboxWeatherBase/ic_shun_main_1_1.png';
  static const String toolboxWeatherSunriseCard =
      '$_toolboxWeatherBase/ic_shun_main_1_2.png';
  static const String toolboxWeatherWind =
      '$_toolboxWeatherBase/ic_shun_main_2_1.png';
  static const String toolboxWeatherPressure =
      '$_toolboxWeatherBase/ic_shun_main_2_2.png';
  static const String toolboxWeatherHumidity =
      '$_toolboxWeatherBase/ic_shun_main_2_3.png';
  static const String toolboxWeatherSunrise =
      '$_toolboxWeatherBase/ic_shun_main_3_1.png';
  static const String toolboxWeatherSunset =
      '$_toolboxWeatherBase/ic_shun_main_3_2.png';
  static const String toolboxWeatherBigSun =
      '$_toolboxWeatherBase/ic_six_7day_big_sun.png';
  static const String toolboxWeatherBigCloudy =
      '$_toolboxWeatherBase/ic_six_7day_big_cloudy.png';
  static const String toolboxWeatherBigRain =
      '$_toolboxWeatherBase/ic_six_7day_big_rain.png';
  static const String toolboxWeatherBigThunderstorm =
      '$_toolboxWeatherBase/ic_six_7day_big_thunderstorm.png';
  static const String toolboxWeatherLongTrip =
      '$_toolboxWeatherBase/waetopbg.png';
  static const String toolboxWeatherSolarTerms =
      '$_toolboxWeatherBase/llifejq.png';
  static const String toolboxWeatherHistoryToday =
      '$_toolboxWeatherBase/llifetoday.png';
  static const String toolboxWeatherArrowRight =
      '$_toolboxWeatherBase/arrow_right_ic.png';

  // ====== zxxtq 天气首页资源（对齐 Android WeatherChildFragment Compose UI）======
  /// 顶部 Hero 城市剪影（对齐 Android zxxtq_weather_cityscape，142dp 高）
  static const String zxxtqWeatherCityscape =
      '$_toolboxWeatherBase/zxxtq_weather_cityscape.png';

  /// 顶部 Hero 云图（对齐 Android zxxtq_weather_hero_cloud，180x132dp）
  static const String zxxtqWeatherHeroCloud =
      '$_toolboxWeatherBase/zxxtq_weather_hero_cloud.png';

  /// 空气胶囊叶子图标（对齐 Android zxxtq_air_leaf，14dp）
  static const String zxxtqAirLeaf = '$_toolboxWeatherBase/zxxtq_air_leaf.png';

  /// 顶部定位图标（对齐 Android ic_airbox_loc，17dp）
  static const String zxxtqLocation = '$_toolboxWeatherBase/ic_airbox_loc.png';

  /// 当前天气卡 - 体感温度图标（对齐 Android zxxtq_metric_temperature）
  static const String zxxtqMetricTemperature =
      '$_toolboxWeatherBase/zxxtq_metric_temperature.png';

  /// 当前天气卡 - 湿度图标（对齐 Android zxxtq_metric_humidity）
  static const String zxxtqMetricHumidity =
      '$_toolboxWeatherBase/zxxtq_metric_humidity.png';

  /// 当前天气卡 - 风速图标（对齐 Android zxxtq_metric_wind）
  static const String zxxtqMetricWind =
      '$_toolboxWeatherBase/zxxtq_metric_wind.png';

  /// 当前天气卡 - 舒适度图标（对齐 Android zxxtq_metric_comfort）
  static const String zxxtqMetricComfort =
      '$_toolboxWeatherBase/zxxtq_metric_comfort.png';

  /// 生活建议 - 穿衣图标（对齐 Android zxxtq_life_clothes）
  static const String zxxtqLifeClothes =
      '$_toolboxWeatherBase/zxxtq_life_clothes.png';

  /// 生活建议 - 紫外线图标（对齐 Android zxxtq_life_uv）
  static const String zxxtqLifeUv = '$_toolboxWeatherBase/zxxtq_life_uv.png';

  /// 生活建议 - 洗车图标（对齐 Android zxxtq_life_car）
  static const String zxxtqLifeCar = '$_toolboxWeatherBase/zxxtq_life_car.png';

  /// 生活建议 - 运动图标（对齐 Android zxxtq_life_sport）
  static const String zxxtqLifeSport =
      '$_toolboxWeatherBase/zxxtq_life_sport.png';

  /// 长途规划入口图标（对齐 Android zxxtq_longtrip_route，56dp）
  static const String zxxtqLongTripRoute =
      '$_toolboxWeatherBase/zxxtq_longtrip_route.png';

  // ZyytHomeScreen 原始 Android 资源（与通用天气资源隔离）。
  static const String zyytHomeClouds =
      '$_toolboxWeatherBase/zyyt_home_clouds.png';
  static const String zyytLongTripBanner =
      '$_toolboxWeatherBase/zyyt_long_trip_banner.png';
  static const String zyytHomeSun = '$_toolboxWeatherBase/zyyt_home_sun.png';
  static const String zyytBack = '$_toolboxWeatherBase/zyyt_back.png';
  static const String zyytWeatherSunny =
      '$_toolboxWeatherBase/zyyt_weather_sunny.png';
  static const String zyytWeatherPartlyCloudy =
      '$_toolboxWeatherBase/zyyt_weather_partly_cloudy.png';
  static const String zyytWeatherThunder =
      '$_toolboxWeatherBase/zyyt_weather_thunder.png';
  static const String zyytWeatherFog =
      '$_toolboxWeatherBase/zyyt_weather_fog.png';
  static const String zyytMetricHumidity =
      '$_toolboxWeatherBase/zyyt_metric_humidity.png';
  static const String zyytMetricPressure =
      '$_toolboxWeatherBase/zyyt_metric_pressure.png';
  static const String zyytMetricVisibility =
      '$_toolboxWeatherBase/zyyt_metric_visibility.png';
  static const String zyytMetricUv = '$_toolboxWeatherBase/zyyt_metric_uv.png';
  static const String zyytMetricRainfall =
      '$_toolboxWeatherBase/zyyt_metric_rainfall.png';
  static const String zyytMetricWindDirection =
      '$_toolboxWeatherBase/zyyt_metric_wind_direction.png';
  static const String zyytMetricWindSpeed =
      '$_toolboxWeatherBase/zyyt_metric_wind_speed.png';
  static const String zyytMetricWindForce =
      '$_toolboxWeatherBase/zyyt_metric_wind_force.png';
  static const String zyytTabWeatherSelected =
      '$_toolboxWeatherBase/zyyt_tab_weather_selected.png';
  static const String zyytTabWeatherNormal =
      '$_toolboxWeatherBase/zyyt_tab_weather_unselected.png';
  static const String zyytTabLifeSelected =
      '$_toolboxWeatherBase/zyyt_tab_life_selected.png';
  static const String zyytTabLifeNormal =
      '$_toolboxWeatherBase/zyyt_tab_life_unselected.png';
  static const String zyytTabCalendarSelected =
      '$_toolboxWeatherBase/zyyt_tab_calendar_selected.png';
  static const String zyytTabCalendarNormal =
      '$_toolboxWeatherBase/zyyt_tab_calendar_unselected.png';
  static const String zyytTabAgricultureSelected =
      '$_toolboxWeatherBase/zyyt_tab_agriculture_selected.png';
  static const String zyytTabAgricultureNormal =
      '$_toolboxWeatherBase/zyyt_tab_agriculture_unselected.png';
  static const String zyytCalendarProfile =
      '$_toolboxWeatherBase/zyyt_calendar_profile.png';
  static const String zyytCalendarTripBanner =
      '$_toolboxWeatherBase/zyyt_calendar_trip_banner.png';
  static const String zyytCalendarNutrition =
      '$_toolboxWeatherBase/zyyt_calendar_nutrition.png';
  static const String zyytCalendarStress =
      '$_toolboxWeatherBase/zyyt_calendar_stress.png';
  static const String zyytCalendarSolarTerm =
      '$_toolboxWeatherBase/zyyt_calendar_solar_term.png';
  static const String zyytCalendarHistory =
      '$_toolboxWeatherBase/zyyt_calendar_history.png';
  static const String zyytAgriCropBanner =
      '$_toolboxWeatherBase/zyyt_agri_crop_banner.png';
  static const String zyytAgriSunHours =
      '$_toolboxWeatherBase/zyyt_agri_sun_hours.png';
  static const String zyytAgriGust = '$_toolboxWeatherBase/zyyt_agri_gust.png';
  static const String zyytAgriUv = '$_toolboxWeatherBase/zyyt_agri_uv.png';
  static const String zyytAgriHumidity =
      '$_toolboxWeatherBase/zyyt_agri_humidity.png';
  static const String toolboxTabWeatherSelected =
      '$_toolboxWeatherBase/ic_six_tab_1_true.png';
  static const String toolboxTabWeatherNormal =
      '$_toolboxWeatherBase/ic_six_tab_1_false.png';
  static const String toolboxTabHomeSelected =
      '$_toolboxWeatherBase/ic_six_tab_2_true.png';
  static const String toolboxTabHomeNormal =
      '$_toolboxWeatherBase/ic_six_tab_2_false.png';
  static const String toolboxTabAirSelected =
      '$_toolboxWeatherBase/ic_six_tab_3_true.png';
  static const String toolboxTabAirNormal =
      '$_toolboxWeatherBase/ic_six_tab_3_false.png';

  // MainWeatherActivity 的 MyBottomNavView 四项图标，来自 navtools_menu.xml。
  static const String toolboxNavWeatherNormal =
      '$_toolboxWeatherBase/ic_tab_1_false.png';
  static const String toolboxNavWeatherSelected =
      '$_toolboxWeatherBase/ic_tab_1_true.png';
  static const String toolboxNavCalendarNormal =
      '$_toolboxWeatherBase/ic_tab_2_false.png';
  static const String toolboxNavCalendarSelected =
      '$_toolboxWeatherBase/ic_tab_2_true.png';
  static const String toolboxNavAgricultureNormal =
      '$_toolboxWeatherBase/ic_tab_3_false.png';
  static const String toolboxNavAgricultureSelected =
      '$_toolboxWeatherBase/ic_tab_3_true.png';
  static const String toolboxNavLifeGuideNormal =
      '$_toolboxWeatherBase/ic_tab_4_false.png';
  static const String toolboxNavLifeGuideSelected =
      '$_toolboxWeatherBase/ic_tab_4_true.png';

  // ====== Toolbox AirQualityFragment 资源 ======
  // 与其它迁入页面分目录，避免覆写 HarmonyOS 工程中已有的空气质量资源。
  static const String _toolboxAirQualityBase = '$_base/toolbox_air_quality';
  static const String toolboxAirQualityBackground =
      '$_toolboxAirQualityBase/weather_home_shap_airbox_bg.png';
  static const String toolboxAirQualityLocation =
      '$_toolboxAirQualityBase/ic_airbox_loc.png';
  static const String toolboxAirQualitySun =
      '$_toolboxAirQualityBase/icon_day_airbox_big_sun.png';
  static const String toolboxAirQualityCloudy =
      '$_toolboxAirQualityBase/icon_day_airbox_big_cloudy.png';
  static const String toolboxAirQualityRain =
      '$_toolboxAirQualityBase/icon_day_airbox_big_rain.png';
  static const String toolboxAirQualityThunderstorm =
      '$_toolboxAirQualityBase/icon_day_airbox_big_thunderstorm.png';
  static const String toolboxAirQualityPm25 =
      '$_toolboxAirQualityBase/icon_air_airbox_menu1.png';
  static const String toolboxAirQualityPm10 =
      '$_toolboxAirQualityBase/icon_air_airbox_menu2.png';
  static const String toolboxAirQualityNo2 =
      '$_toolboxAirQualityBase/icon_air_airbox_menu3.png';
  static const String toolboxAirQualitySo2 =
      '$_toolboxAirQualityBase/icon_air_airbox_menu4.png';
  static const String toolboxAirQualityCo =
      '$_toolboxAirQualityBase/icon_air_airbox_menu5.png';
  static const String toolboxAirQualityO3 =
      '$_toolboxAirQualityBase/icon_air_airbox_menu6.png';
  static const String toolboxAirHealthHero =
      '$_toolboxAirQualityBase/ic_shun_health_1_1.png';
  static const String toolboxAirHealthFood =
      '$_toolboxAirQualityBase/ic_shun_health_2_1.png';
  static const String toolboxAirHealthCard =
      '$_toolboxAirQualityBase/ic_shun_health_1_2.png';
  static const String toolboxAirHealthCardIcon =
      '$_toolboxAirQualityBase/ic_shun_health_3_1.png';
  static const String toolboxAirHumidity =
      '$_toolboxAirQualityBase/ic_shun_health_4_1.png';
  static const String toolboxAirPressure =
      '$_toolboxAirQualityBase/ic_shun_health_4_2.png';
  static const String toolboxAirVisibility =
      '$_toolboxAirQualityBase/ic_shun_health_4_3.png';
  static const String toolboxAirUv =
      '$_toolboxAirQualityBase/ic_shun_health_4_4.png';
  static const String toolboxAirPrecip =
      '$_toolboxAirQualityBase/ic_shun_health_4_5.png';
  static const String toolboxAirWindDir =
      '$_toolboxAirQualityBase/ic_shun_health_4_6.png';
  static const String toolboxAirWindSpeed =
      '$_toolboxAirQualityBase/ic_shun_health_4_7.png';
  static const String toolboxAirWindScale =
      '$_toolboxAirQualityBase/ic_shun_health_4_8.png';
  static const String toolboxTabAirQualityNormal =
      '$_toolboxAirQualityBase/ic_six_tab_3_false.png';
  static const String toolboxTabAirQualitySelected =
      '$_toolboxAirQualityBase/ic_six_tab_3_true.png';

  // ====== WeatherShFragment 生活指数页资源 ======
  static const String toolboxLifeBanner =
      '$_toolboxWeatherBase/zyyt_life_banner.png';
  static const String toolboxLifeSport =
      '$_toolboxWeatherBase/zyyt_life_sport.png';
  static const String toolboxLifeCar = '$_toolboxWeatherBase/zyyt_life_car.png';
  static const String toolboxLifeClothing =
      '$_toolboxWeatherBase/zyyt_life_clothing.png';
  static const String toolboxLifePollutantPm25 =
      '$_toolboxWeatherBase/zyyt_pollutant_pm25.png';
  static const String toolboxLifePollutantPm10 =
      '$_toolboxWeatherBase/zyyt_pollutant_pm10.png';
  static const String toolboxLifePollutantNo2 =
      '$_toolboxWeatherBase/zyyt_pollutant_no2.png';
  static const String toolboxLifePollutantSo2 =
      '$_toolboxWeatherBase/zyyt_pollutant_so2.png';
  static const String toolboxLifePollutantCo =
      '$_toolboxWeatherBase/zyyt_pollutant_co.png';
  static const String toolboxLifePollutantO3 =
      '$_toolboxWeatherBase/zyyt_pollutant_o3.png';

  // ====== Toolbox LifeFragment 资源 ======
  static const String _toolboxLifeBase = '$_base/toolbox_life';
  static const String toolboxLifeSolarCard =
      '$_toolboxLifeBase/ic_shun_life_1_1.png';
  static const String toolboxLifeHistoryCard =
      '$_toolboxLifeBase/ic_shun_life_1_2.png';
  static const String toolboxLifeSolarIcon =
      '$_toolboxLifeBase/ic_shun_life_2_1.png';
  static const String toolboxLifeHistoryIcon =
      '$_toolboxLifeBase/ic_shun_life_2_2.png';

  // ====== Toolbox NongyeFragment / 长途规划资源 ======
  static const String _toolboxAgricultureBase = '$_base/toolbox_agriculture';
  static const String agricultureRecordBoard =
      '$_toolboxAgricultureBase/fyzn_ny_new_record_board.png';
  static const String agricultureSunshine =
      '$_toolboxAgricultureBase/icon_ny_rz.png';
  static const String agricultureWind =
      '$_toolboxAgricultureBase/icon_ny_fl.png';
  static const String agricultureUv = '$_toolboxAgricultureBase/ic_uv.png';
  static const String agricultureHumidity =
      '$_toolboxAgricultureBase/ic_humidity.png';
  static const String agricultureWarning =
      '$_toolboxAgricultureBase/ic_weather_warning.png';
  static const String agricultureCategoryGrain =
      '$_toolboxAgricultureBase/fyzn_ny_new_category_grain.png';
  static const String agricultureCategoryFruitVegetable =
      '$_toolboxAgricultureBase/fyzn_ny_new_category_fruit_vegetable.png';
  static const String agricultureCategoryGreenhouse =
      '$_toolboxAgricultureBase/fyzn_ny_new_category_greenhouse.png';
  static const String agricultureCategoryForest =
      '$_toolboxAgricultureBase/fyzn_ny_new_category_forest.png';
  static const String agricultureCategoryOil =
      '$_toolboxAgricultureBase/fyzn_ny_new_category_oil.png';
  static const String agricultureCategoryList =
      '$_toolboxAgricultureBase/fyzn_ny_new_category_list.png';
  static const String agricultureAddRecord =
      '$_toolboxAgricultureBase/fyzn_ny_new_add_record.png';
  static const String agricultureDeleteRecord =
      '$_toolboxAgricultureBase/fyzn_ny_new_delete_record.png';
  static const String agricultureSaveRecord =
      '$_toolboxAgricultureBase/fyzn_ny_new_save_record.png';
  static const String agricultureBack =
      '$_toolboxAgricultureBase/fyzn_ny_new_back_button.png';
  static const String agricultureSetting =
      '$_toolboxAgricultureBase/setting_black_icon.png';
  static const String agricultureZyytAdd =
      '$_toolboxAgricultureBase/zyyt_add.png';
  static const String agricultureZyytCategoryList =
      '$_toolboxAgricultureBase/zyyt_category_list.png';
  static const String agricultureZyytSave =
      '$_toolboxAgricultureBase/zyyt_save.png';
  static const String agricultureZyytCategoryGrain =
      '$_toolboxAgricultureBase/zyyt_category_grain.png';
  static const String agricultureZyytCategoryProduce =
      '$_toolboxAgricultureBase/zyyt_category_produce.png';
  static const String agricultureZyytCategoryGreenhouse =
      '$_toolboxAgricultureBase/zyyt_category_greenhouse.png';
  static const String agricultureZyytCategoryForest =
      '$_toolboxAgricultureBase/zyyt_category_forest.png';
  static const String agricultureZyytCategoryOil =
      '$_toolboxAgricultureBase/zyyt_category_oil.png';

  // ====== zxxtq 农业页资源（对齐 Android NongyeFragment Compose UI）======
  /// 农业页全屏背景图（对齐 Android zxxtq_agriculture_background）
  static const String zxxtqAgricultureBackground =
      '$_toolboxAgricultureBase/zxxtq_agriculture_background.png';

  /// 农业天气卡背景图（对齐 Android zxxtq_agriculture_weather_card，151dp 高）
  static const String zxxtqAgricultureWeatherCard =
      '$_toolboxAgricultureBase/zxxtq_agriculture_weather_card.png';

  /// 农业天气卡 - 湿度图标（对齐 Android zxxtq_agriculture_humidity，19dp）
  static const String zxxtqAgricultureHumidity =
      '$_toolboxAgricultureBase/zxxtq_agriculture_humidity.png';

  /// 农业天气卡 - 风速图标（对齐 Android zxxtq_agriculture_wind，19dp）
  static const String zxxtqAgricultureWind =
      '$_toolboxAgricultureBase/zxxtq_agriculture_wind.png';

  /// 农业天气卡 - 日照图标（对齐 Android zxxtq_agriculture_sunshine，19dp）
  static const String zxxtqAgricultureSunshine =
      '$_toolboxAgricultureBase/zxxtq_agriculture_sunshine.png';

  /// 农作物记录卡插图（对齐 Android fyzn_ny_new_record_illustration，86x81dp）
  static const String agricultureRecordIllustration =
      '$_toolboxAgricultureBase/fyzn_ny_new_record_illustration.png';

  static const String _toolboxLongTripBase = '$_base/toolbox_long_trip';
  static const String longTripHomeIcon =
      '$_toolboxLongTripBase/fyzn_ny_tjd_home_route_icon.png';
  static const String longTripBack =
      '$_toolboxLongTripBase/fyzn_ny_tjd_back_button.png';
  static const String longTripEmpty =
      '$_toolboxLongTripBase/fyzn_ny_tjd_empty_route.png';
  static const String longTripRouteBackground =
      '$_toolboxLongTripBase/yttqyj_icon.png';
  static const String longTripStart =
      '$_toolboxLongTripBase/fyzn_ny_tjd_draft_start_weather.png';
  static const String longTripWaypoint =
      '$_toolboxLongTripBase/fyzn_ny_tjd_draft_waypoint_weather.png';
  static const String longTripEnd =
      '$_toolboxLongTripBase/fyzn_ny_tjd_draft_end_weather.png';
  static const String longTripRemove =
      '$_toolboxLongTripBase/fyzn_ny_tjd_draft_remove.png';
  static const String longTripAlert =
      '$_toolboxLongTripBase/fyzn_ny_tjd_alert_triangle.png';
  static const String longTripSuggestionRoute =
      '$_toolboxLongTripBase/fyzn_ny_tjd_suggestion_route.png';
  static const String longTripSuggestionSupply =
      '$_toolboxLongTripBase/fyzn_ny_tjd_suggestion_supply.png';

  // ====== 空气质量新 UI 资源（对齐 Android WeatherShChildFragment Compose UI）======
  /// 风速图标（对齐 Android ic_feng_main_2_1，WeatherInfoCard 风速项）
  static const String airWindSpeed = '$_base/ic_feng_main_2_1.png';

  /// 气压图标（对齐 Android ic_feng_main_2_2，WeatherInfoCard 气压项）
  static const String airPressure = '$_base/ic_feng_main_2_2.png';

  /// 湿度图标（对齐 Android ic_feng_main_2_3，WeatherInfoCard 湿度项）
  static const String airHumidity = '$_base/ic_feng_main_2_3.png';

  /// PM2.5 污染物图标（对齐 Android ic_ling_life_2_1，细颗粒物）
  static const String pollutantPm25 = '$_base/ic_ling_life_2_1.png';

  /// PM10 污染物图标（对齐 Android ic_ling_life_2_2，粗颗粒度）
  static const String pollutantPm10 = '$_base/ic_ling_life_2_2.png';

  /// NO₂ 污染物图标（对齐 Android ic_ling_life_2_3，二氧化氮）
  static const String pollutantNo2 = '$_base/ic_ling_life_2_3.png';

  /// SO₂ 污染物图标（对齐 Android ic_ling_life_2_4，二氧化硫）
  static const String pollutantSo2 = '$_base/ic_ling_life_2_4.png';

  /// CO 污染物图标（对齐 Android ic_ling_life_2_5，一氧化碳）
  static const String pollutantCo = '$_base/ic_ling_life_2_5.png';

  /// O3 污染物图标（对齐 Android ic_ling_life_2_6，臭氧）
  static const String pollutantO3 = '$_base/ic_ling_life_2_6.png';

  /// 圆环中心空气质量图标（对齐 Android kqzl_iocn，注意原拼写是 iocn 不是 icon）
  static const String airQualityCenterIcon = '$_base/kqzl_iocn.png';

  // ====== 日历新 UI 资源（对齐 Android NearbyFragment Compose UI）======
  /// 生活小窍门图标（对齐 Android shenghxts，106dp，点击→xiaoqiaomen.html H5）
  static const String lifeTipsIcon = '$_base/shenghxts.png';

  /// 压力管理卡片背景图（对齐 Android llifehjyl_bg，315x165dp）
  static const String pressureCardBg = '$_base/llifehjyl_bg.png';

  /// 压力管理卡片插图（对齐 Android llifehjyl，90dp）
  static const String pressureCardIllustration = '$_base/llifehjyl.png';

  /// 日历左箭头（对齐 Android ic_arrow_left，15dp）
  static const String calendarArrowLeft = '$_base/ic_arrow_left.png';

  /// 日历右箭头（对齐 Android ic_arrow_right，15dp）
  static const String calendarArrowRight = '$_base/ic_arrow_right.png';

  /// 日历天气占位图标（对齐 Android ic_sun.webp，gone 区域用，保真保留）
  static const String calendarSunIcon = '$_base/ic_sun.webp';

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

  // ====== 旅行规划（travel）模块资源 - 来自 master-qingyichuxingqixiang 分支 ======
  static const String _travelBase = '$_base/travel';

  /// 旅行卡片图（9 个目的地）
  static const String travelDisney = '$_travelBase/jbcx_travel_disney.webp';
  static const String travelBund = '$_travelBase/jbcx_travel_bund.webp';
  static const String travelForbiddenCity =
      '$_travelBase/jbcx_travel_forbidden_city.png';
  static const String travelUniversalBeijing =
      '$_travelBase/jbcx_travel_universal_beijing.png';
  static const String travelGreatWall =
      '$_travelBase/jbcx_travel_great_wall.png';
  static const String travelTerracottaWarriors =
      '$_travelBase/jbcx_travel_terracotta_warriors.png';
  static const String travelHuanglong =
      '$_travelBase/jbcx_travel_huanglong.png';
  static const String travelLeshanBuddha =
      '$_travelBase/jbcx_travel_leshan_buddha.png';
  static const String travelWestLake =
      '$_travelBase/jbcx_travel_west_lake.png';

  /// 迪士尼攻略页资源
  static const String disneyMenpai = '$_travelBase/dishini_s_menpai.webp';
  static const String disneyLeyuan = '$_travelBase/dishini_sh_leyuan.webp';
  static const String disneyFood = '$_travelBase/dishini_s_food.webp';

  /// 图片攻略页资源（外滩/故宫/环球/八达岭/兵马俑/九寨沟/西湖长图）
  static const String scenicGugong = '$_travelBase/guggong_bg2.webp';
  static const String scenicHuanqiiu = '$_travelBase/huanqiiu.webp';
  static const String scenicBadaling = '$_travelBase/badaling.webp';
  static const String scenicBingmayong = '$_travelBase/bingmayong.webp';
  static const String scenicWaitan = '$_travelBase/waitan.webp';
  static const String scenicJiuzhaigou = '$_travelBase/jiuzhaigou.webp';
  static const String scenicXihu = '$_travelBase/xihu.webp';

  /// 乐山峨眉攻略页资源
  static const String leshanHead = '$_travelBase/img_head_leshan.webp';
  static const String leshanDafo = '$_travelBase/leshan_dafo.webp';
  static const String emeishan = '$_travelBase/emeishan.webp';
  static const String sichuanChuanchuan =
      '$_travelBase/sichuan_chuanchuan.webp';

  /// 旅行详情页浮动返回按钮
  static const String icBackGrayWhite =
      '$_travelBase/ic_back_gray_white.webp';

  // ====== 设置 Tab 资源（对齐 Android WeatherSettingFragment 菜单图标）======
  static const String _toolboxSettingBase = '$_base/toolbox_setting';
  static const String settingTabUserAgreement =
      '$_toolboxSettingBase/yhtk_icon.png';
  static const String settingTabPrivacy =
      '$_toolboxSettingBase/ysxy_icon.png';
  static const String settingTabAbout =
      '$_toolboxSettingBase/gywm_icon.png';
  static const String settingTabFeedback =
      '$_toolboxSettingBase/yjfk_icon.png';
}
