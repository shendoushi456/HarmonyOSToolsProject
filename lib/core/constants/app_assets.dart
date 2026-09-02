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

  // ====== 畅行（bus）模块资源 - 对齐 Android jbcx_* 系列 ======
  /// 畅行无标题图（128dp 宽）
  static const String jbcxHomeTitle = '$_base/jbcx_home_title.png';

  /// 首页右侧 hero 图（178dp）
  static const String jbcxHomeHero = '$_base/jbcx_home_hero.png';

  /// 畅行搜索图标（19dp）
  static const String jbcxSearch = '$_base/jbcx_search.png';

  /// 步行路线图标
  static const String jbcxRouteWalk = '$_base/jbcx_route_walk.png';

  /// 骑行路线图标
  static const String jbcxRouteCycle = '$_base/jbcx_route_cycle.png';

  /// 驾车路线图标
  static const String jbcxRouteDrive = '$_base/jbcx_route_drive.png';

  /// 公交路线图标
  static const String jbcxRouteBus = '$_base/jbcx_route_bus.png';

  /// 家地址图标
  static const String jbcxAddressHome = '$_base/jbcx_address_home.png';

  /// 公司地址图标
  static const String jbcxAddressCompany = '$_base/jbcx_address_company.png';

  /// 学校地址图标
  static const String jbcxAddressSchool = '$_base/jbcx_address_school.png';

  /// 权限引导页背景图（450dp 高）
  static const String icMainBg = '$_base/ic_main_bg.webp';

  /// 权限引导页定位图标
  static const String icMainLocation = '$_base/ic_main_location.webp';

  /// 搜索空状态图（207x153dp）
  static const String icBusSearchEmpty = '$_base/ic_bus_search_empty.webp';

  /// "到这去"图标（18dp）
  static const String icBusStopGo = '$_base/ic_bus_stop_go.webp';

  /// 交换位置图标（20x19dp）
  static const String icBusRouteCommutation =
      '$_base/ic_bus_route_commutation.png';

  // ====== Android RoutenquiryFragment 迁移资源 ======
  // 独立目录避免与既有 jbcx_* 资源及其他马甲包资源同名冲突。
  static const String toolboxRouteCar =
      '$_base/toolbox_route/xxx_route_car.png';
  static const String toolboxRouteBus =
      '$_base/toolbox_route/xxx_route_bus.png';
  static const String toolboxRouteBike =
      '$_base/toolbox_route/xxx_route_bike.png';
  static const String toolboxRouteWalk =
      '$_base/toolbox_route/xxx_route_walk.png';
  static const String toolboxRouteSearch =
      '$_base/toolbox_route/xxx_ic_search.png';
  static const String toolboxAddressHome =
      '$_base/toolbox_route/xxx_ic_home.png';
  static const String toolboxAddressCompany =
      '$_base/toolbox_route/xxx_ic_company.png';
  static const String toolboxAddressSchool =
      '$_base/toolbox_route/xxx_ic_school.png';
  static const String toolboxAddressBar =
      '$_base/toolbox_route/xxx_address_bar.png';
  static const String toolboxNearbyMall =
      '$_base/toolbox_route/xxx_ic_mall.png';
  static const String toolboxNearbyToilet =
      '$_base/toolbox_route/xxx_ic_toilet.png';
  static const String toolboxArrow = '$_base/toolbox_route/xxx_ic_arrow.png';
  static const String toolboxVr1 = '$_base/toolbox_route/ic_scenic_vr_1.webp';
  static const String toolboxVr2 = '$_base/toolbox_route/ic_scenic_vr_2.webp';
  static const String toolboxVr3 = '$_base/toolbox_route/ic_scenic_vr_3.webp';
  static const String toolboxVr4 = '$_base/toolbox_route/ic_scenic_vr_4.webp';
  static const String toolboxVr5 = '$_base/toolbox_route/ic_scenic_vr_5.webp';
  static const String toolboxVr6 = '$_base/toolbox_route/ic_scenic_vr_6.webp';
  static const String toolboxVr7 = '$_base/toolbox_route/ic_scenic_vr_7.webp';
  static const String toolboxVr8 = '$_base/toolbox_route/ic_scenic_vr_8.webp';
  static const String toolboxVr9 = '$_base/toolbox_route/ic_scenic_vr_9.webp';
  static const String toolboxVr10 = '$_base/toolbox_route/ic_scenic_vr_10.webp';

  // ====== Android NearbyFragment 迁移资源 ======
  // 单独目录管理，避免与此前版本的 nearby_* 资源和后续马甲资源混用。
  static const String toolboxNearbySupermarket =
      '$_base/toolbox_nearby/icondd_func_supermarket.png';
  static const String toolboxNearbyEntertainment =
      '$_base/toolbox_nearby/icondd_func_entertainment.png';
  static const String toolboxNearbyFood =
      '$_base/toolbox_nearby/icondd_func_food.png';
  static const String toolboxNearbySubway =
      '$_base/toolbox_nearby/icondd_func_subway.png';
  static const String toolboxNearbyHotel =
      '$_base/toolbox_nearby/icondd_func_hotel.png';
  static const String toolboxNearbyScenic =
      '$_base/toolbox_nearby/icondd_func_scenic.png';
  static const String toolboxNearbyFood2 =
      '$_base/toolbox_nearby/icondd_func_food2.png';
  static const String toolboxNearbyBus =
      '$_base/toolbox_nearby/icondd_func_bus.png';

  // ====== Android TravelSettingFragment 迁移资源 ======
  // 独立目录避免与旧设置页图标以及其他马甲包资源同名冲突。
  static const String toolboxProfileLocation =
      '$_base/toolbox_profile/llocation.png';
  static const String toolboxProfileWeather =
      '$_base/toolbox_profile/icond_weather_icon.png';
  static const String toolboxProfileAvatar =
      '$_base/toolbox_profile/icond_avatar.png';
  static const String toolboxProfilePrivacy =
      '$_base/toolbox_profile/icond_privacy.png';
  static const String toolboxProfileAgreement =
      '$_base/toolbox_profile/icond_agreement.png';
  static const String toolboxProfileAbout =
      '$_base/toolbox_profile/icond_about.png';
  static const String toolboxProfileFeedback =
      '$_base/toolbox_profile/icond_feedback.png';

  // ====== Android ViewpointFragment 迁移资源 ======
  static const String toolboxViewpointTopBackground =
      '$_base/toolbox_viewpoint/icondv_top_bg.png';
  static const String toolboxViewpointArrow =
      '$_base/toolbox_viewpoint/icondv_arrow.png';
  static const String toolboxViewpointArrowExpanded =
      '$_base/toolbox_viewpoint/icondv_arrow_item.png';
  static const String toolboxViewpoint1 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_1.webp';
  static const String toolboxViewpoint2 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_2.webp';
  static const String toolboxViewpoint3 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_3.webp';
  static const String toolboxViewpoint4 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_4.webp';
  static const String toolboxViewpoint5 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_5.webp';
  static const String toolboxViewpoint6 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_6.webp';
  static const String toolboxViewpoint7 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_7.webp';
  static const String toolboxViewpoint8 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_8.webp';
  static const String toolboxViewpoint9 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_9.webp';
  static const String toolboxViewpoint10 =
      '$_base/toolbox_viewpoint/ic_scenic_vp_10.webp';
  static const String toolboxHongKongDisneyGate =
      '$_base/toolbox_viewpoint/dishini_h_menpai.webp';
  static const String toolboxHongKongDisneyPark =
      '$_base/toolbox_viewpoint/dishini_h_leyuan.webp';
  static const String toolboxHongKongDisneyFood =
      '$_base/toolbox_viewpoint/dishini_h_meishi.webp';
  static const String toolboxHongKongDisneyBack =
      '$_base/toolbox_viewpoint/ic_back_gray_white.webp';

  // ====== Android MainWeatherActivity 底部导航资源 ======
  static const String toolboxTab1Normal =
      '$_base/toolbox_bottom_nav/ic_tab_1_false.webp';
  static const String toolboxTab1Selected =
      '$_base/toolbox_bottom_nav/ic_tab_1_true.webp';
  static const String toolboxTab2Normal =
      '$_base/toolbox_bottom_nav/ic_tab_2_false.webp';
  static const String toolboxTab2Selected =
      '$_base/toolbox_bottom_nav/ic_tab_2_true.webp';
  static const String toolboxTab3Normal =
      '$_base/toolbox_bottom_nav/ic_tab_3_false.webp';
  static const String toolboxTab3Selected =
      '$_base/toolbox_bottom_nav/ic_tab_3_true.webp';
  static const String toolboxTab4Normal =
      '$_base/toolbox_bottom_nav/ic_tab_4_false.webp';
  static const String toolboxTab4Selected =
      '$_base/toolbox_bottom_nav/ic_tab_4_true.webp';

  // ====== 旅行规划（travel）模块资源 - 对齐 Android ViewpointFragment ======
  /// 旅行卡片图（9 张，154dp 高）
  static const String travelDisney = '$_base/jbcx_travel_disney.webp';
  static const String travelBund = '$_base/jbcx_travel_bund.webp';
  static const String travelForbiddenCity =
      '$_base/jbcx_travel_forbidden_city.png';
  static const String travelUniversalBeijing =
      '$_base/jbcx_travel_universal_beijing.png';
  static const String travelGreatWall = '$_base/jbcx_travel_great_wall.png';
  static const String travelTerracottaWarriors =
      '$_base/jbcx_travel_terracotta_warriors.png';
  static const String travelHuanglong = '$_base/jbcx_travel_huanglong.png';
  static const String travelLeshanBuddha =
      '$_base/jbcx_travel_leshan_buddha.png';
  static const String travelWestLake = '$_base/jbcx_travel_west_lake.png';

  // ====== 景点详情页资源 - 对齐 Android hotSceniclib ======
  /// 迪士尼攻略图（3 张）
  static const String disneyMenpai = '$_base/dishini_s_menpai.webp';
  static const String disneyLeyuan = '$_base/dishini_sh_leyuan.webp';
  static const String disneyFood = '$_base/dishini_s_food.webp';

  /// 图片攻略图（7 张，对应 EditorPicTipsActivity）
  static const String scenicGugong = '$_base/guggong_bg2.webp';
  static const String scenicHuanqiiu = '$_base/huanqiiu.webp';
  static const String scenicBadaling = '$_base/badaling.webp';
  static const String scenicBingmayong = '$_base/bingmayong.webp';
  static const String scenicWaitan = '$_base/waitan.webp';
  static const String scenicJiuzhaigou = '$_base/jiuzhaigou.webp';
  static const String scenicXihu = '$_base/xihu.webp';

  /// 乐山峨眉攻略图（4 张）
  static const String leshanHead = '$_base/img_head_leshan.webp';
  static const String leshanDafo = '$_base/leshan_dafo.webp';
  static const String emeishan = '$_base/emeishan.webp';
  static const String sichuanChuanchuan = '$_base/sichuan_chuanchuan.webp';

  /// 通用返回按钮（灰白色）
  static const String icBackGrayWhite = '$_base/ic_back_gray_white.webp';

  // ====== 个人主页（TravelSetting）模块资源 - 对齐 Android TravelSettingFragment ======
  /// 应用 Logo
  static const String icLogo = '$_base/ic_logo.png';

  /// 今日天气行右箭头（复用已有 arrowRight）

  /// 生活指数图标（6 个）— 对齐 Android ic_ling_main_2_*
  static const String lifeIndexDressing = '$_base/ic_ling_main_2_1.png';
  static const String lifeIndexTravel = '$_base/ic_ling_main_2_2.png';
  static const String lifeIndexSunscreen = '$_base/ic_ling_main_2_3.png';
  static const String lifeIndexTraffic = '$_base/ic_ling_main_2_4.png';
  static const String lifeIndexMakeup = '$_base/ic_ling_main_2_5.png';
  static const String lifeIndexUv = '$_base/ic_ling_main_2_6.png';

  /// 设置菜单图标（4 个）— 对齐 Android ic_man_own_2_* + ic_lu_own_3_4
  static const String settingPrivacy = '$_base/ic_man_own_2_1.webp';
  static const String settingUserTerms = '$_base/ic_man_own_2_2.webp';
  static const String settingFeedback = '$_base/ic_man_own_2_3.webp';
  static const String settingAbout = '$_base/ic_lu_own_3_4.png';

  /// 设置菜单项右箭头
  static const String icMyMore = '$_base/ic_my_more.webp';

  // ====== 首页（Nearby）模块资源 - 对齐 Android NearbyFragment ======
  /// 大卡片图标（美食、超市）
  static const String nearbyFood = '$_base/ic_man_nearby_1_1.png';
  static const String nearbyFoodBg = '$_base/meishi_icon.png';
  static const String nearbyMarket = '$_base/ic_man_nearby_1_3.png';
  static const String nearbyMarketBg = '$_base/chaoshi_icon.png';

  /// 小图标（8 个功能项）
  static const String nearbyEntertainment = '$_base/ic_man_nearby_1_2.png';
  static const String nearbyHotel = '$_base/ic_man_nearby_1_4.png';
  static const String nearbyScenic = '$_base/ic_man_nearby_1_5.png';
  static const String nearbyToilet = '$_base/ic_man_nearby_1_10.png';
  static const String nearbySubway = '$_base/ic_man_nearby_1_8.png';
  static const String nearbyBus = '$_base/ic_man_nearby_1_7.png';
  static const String nearbyGas = '$_base/ic_man_nearby_1_9.png';
  static const String nearbyParking = '$_base/ic_man_nearby_1_6.png';

  /// 大卡片右侧箭头
  static const String carrowIcon = '$_base/carrow_icon.png';
}
