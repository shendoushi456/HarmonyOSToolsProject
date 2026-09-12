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

  // ====== WiFi 工具页资源 - 对齐 Android ToolsWifiHomeFragment/activity_main_tool.xml ======
  /// 底部导航 - WiFi
  static const String tabWifiNormal = '$_base/qmtq_tab_wifi_normal.png';
  static const String tabWifiSelected = '$_base/qmtq_tab_wifi_selected.png';

  /// WiFi 页顶部背景
  static const String wifiTopBg = '$_base/wifi_top_bg.png';

  /// WiFi 详情卡左侧 wifi 图标(114dp)
  static const String wifiTopIcon = '$_base/top_wifi_icon.png';

  // ====== WiFi 列表 item 资源 - 对齐 item_my_wifi_list.xml + ClearLib Adapter ======
  // 信号强度图标(5 级 × 无锁/有锁 = 10 个)。命名对齐安卓原版(_locker/_locked/_excelent 拼写)
  /// 信号 0 级 - 无锁(disabled)
  static const String wifiSignalDisabled = '$_base/wifi_disabled.png';

  /// 信号 0 级 - 有锁(安卓原版命名 _locker)
  static const String wifiSignalDisabledLocked =
      '$_base/wifi_disabled_locker.png';

  /// 信号 1 级 - 无锁(low)
  static const String wifiSignalLow = '$_base/wifi_low.webp';

  /// 信号 1 级 - 有锁
  static const String wifiSignalLowLocked = '$_base/wifi_low_locked.webp';

  /// 信号 2 级 - 无锁(med)
  static const String wifiSignalMed = '$_base/wifi_med.webp';

  /// 信号 2 级 - 有锁
  static const String wifiSignalMedLocked = '$_base/wifi_med_locked.webp';

  /// 信号 3 级 - 无锁(high)
  static const String wifiSignalHigh = '$_base/wifi_high.webp';

  /// 信号 3 级 - 有锁
  static const String wifiSignalHighLocked = '$_base/wifi_high_locked.webp';

  /// 信号 4 级 - 无锁(安卓原版拼写 excelent)
  static const String wifiSignalExcellent = '$_base/wifi_excelent.png';

  /// 信号 4 级 - 有锁
  static const String wifiSignalExcellentLocked =
      '$_base/wifi_excelent_locked.png';

  /// wifi 列表已连接小图标(原 lwifiylj)
  static const String wifiConnected = '$_base/wifi_connected.png';

  /// wifi 列表未连接小图标(原 lwifiwlj)
  static const String wifiDisconnected = '$_base/wifi_disconnected.png';

  /// wifi 列表项右箭头(原 clearitemjt)
  static const String wifiArrow = '$_base/wifi_arrow.png';

  /// wifi 空状态图标(临时复用 wifi_disconnected，原 ic_wifi_empty 待补)
  static const String wifiEmpty = '$_base/wifi_disconnected.png';

  // ====== LifeTools 资源 - 对齐 LifeFragment.kt ======
  /// 入口卡片页背景图(对齐 ic_shan_main_1_1)
  static const String lifeBg = '$_base/ic_shan_main_1_1.png';

  /// 记事本卡片大图(对齐 ic_notebook)
  static const String notebookCard = '$_base/ic_notebook.png';

  /// 旅行清单图标(对齐 ic_tong_life_3_3)
  static const String icTravel = '$_base/ic_tong_life_3_3.png';

  /// 指南针图标(对齐 ic_tong_life_3_4)
  static const String icCompass = '$_base/ic_tong_life_3_4.png';

  /// 花费记账图标(对齐 ic_shan_main_4_8)
  static const String icTally = '$_base/ic_shan_main_4_8.png';

  /// 马赛克/毛玻璃图标(对齐 ic_shan_main_4_9)
  static const String icBlur = '$_base/ic_shan_main_4_9.png';

  /// 今天吃什么图标(对齐 eat_icon)
  static const String icEat = '$_base/eat_icon.png';

  /// json编辑器图标(对齐 json_icon)
  static const String icJson = '$_base/json_icon.png';

  /// 画板图标(对齐 drawb_icon)
  static const String icDraw = '$_base/drawb_icon.png';

  /// 白色右箭头(对齐 white_jt)
  static const String whiteArrow = '$_base/white_jt.png';

  // ====== MenuHome 资源 - 对齐 MenuFragment.kt ======
  /// MenuHome 入口背景图(对齐 ic_shan_main_1_1, 复用 lifeBg)
  static const String menuHomeBg = '$_base/ic_shan_main_1_1.png';

  /// PDF 转图片图标(对齐 ic_shan_main_4_1)
  static const String icPdfToImage = '$_base/ic_shan_main_4_1.png';

  /// 图片转 PDF 图标(对齐 ic_shan_main_4_2)
  static const String icImageToPdf = '$_base/ic_shan_main_4_2.png';

  /// 压缩 PDF 图标(对齐 ic_shan_main_4_3)
  static const String icPdfCompress = '$_base/ic_shan_main_4_3.png';

  /// 加密 PDF 图标(对齐 ic_shan_main_4_4)
  static const String icPdfEncrypt = '$_base/ic_shan_main_4_4.png';

  /// 生成二维码图标(对齐 ic_tong_life_2_1)
  static const String icQrGenerate = '$_base/ic_tong_life_2_1.png';

  /// 扫描二维码图标(对齐 ic_tong_life_2_2)
  static const String icQrScan = '$_base/ic_tong_life_2_2.png';

  // ====== ScanMenu 资源 - 仅来自 Android 源码 res/mipmap-xxhdpi ======
  static const String scanHomeBg = '$_base/scan_home_bg.png';
  static const String scanToolArchive = '$_base/scan_tool_archive.png';
  static const String scanToolQrScan = '$_base/scan_tool_qr_scan.png';
  static const String scanToolQrGenerate = '$_base/scan_tool_qr_generate.png';
  static const String scanPdfToImage = '$_base/scan_pdf_to_image.png';
  static const String scanImageToPdf = '$_base/scan_image_to_pdf.png';
  static const String scanPdfCompress = '$_base/scan_pdf_compress.png';
  static const String scanExchangeArrow = '$_base/scan_exchange_arrow.png';
  static const String scanDocumentBlue = '$_base/scan_document_blue.png';
  static const String scanDocumentGreen = '$_base/scan_document_green.png';
  static const String scanDocumentPurple = '$_base/scan_document_purple.png';
  static const String scanDocumentYellow = '$_base/scan_document_yellow.png';
  static const String scanDocumentIcon = '$_base/scan_document_icon.png';
  static const String scanDocumentEmpty = '$_base/scan_document_empty.png';
  static const String scanSortNewest = '$_base/scan_sort_newest.png';
  static const String scanSortOldest = '$_base/scan_sort_oldest.png';
  static const String scanSaveLocal = '$_base/scan_save_local.png';
  static const String scanDelete = '$_base/scan_delete.png';
  static const String scanCrop = '$_base/scan_crop.png';
  static const String scanRetake = '$_base/scan_retake.png';
  static const String scanWatermark = '$_base/scan_watermark.png';

  // ====== 便携工具资源 - 对齐 BianxieToolsFragment ======
  static const String portableToolsHomeBg = '$_base/portable_tools_home_bg.png';
  static const String portableToolsClearCamera =
      '$_base/portable_tools_clear_camera.png';
  static const String portableToolsSolarTerms =
      '$_base/portable_tools_solar_terms.png';
  static const String portableToolsCalculator =
      '$_base/portable_tools_calculator.png';
  static const String portableToolsPixel = '$_base/portable_tools_pixel.png';
  static const String portableToolsWatermark =
      '$_base/portable_tools_watermark.png';

  // CleanMainFragment 扫描工具资源
  static const String scanFestival = '$_base/jierijq.png';
  static const String scanHistoryToday = '$_base/lishijt.png';
  static const String scanItemIconQr = '$_base/scan_img_1.png';
  static const String scanItemIconText = '$_base/scan_img_2.png';
  static const String scanItemIconPlant = '$_base/scan_img_3.png';
  static const String scanItemIconAnimal = '$_base/scan_img_4.png';
  static const String scanItemBgQr = '$_base/scan_img_bg_1.png';
  static const String scanItemBgText = '$_base/scan_img_bg_2.png';
  static const String scanItemBgPlant = '$_base/scan_img_bg_3.png';
  static const String scanItemBgAnimal = '$_base/scan_img_bg_4.png';
  static const String scanItemBackground = '$_base/item_clear_tab_bg.png';
  static const String scanItemArrow = '$_base/clearitemjt.png';
  static const String recognitionBankIcon = '$_base/ic_tong_life_2_1.png';
  static const String recognitionBankCard = '$_base/nxtx_toolbox_bank_card.png';

  // NewLifeFragment 首页资源（直接取自 Android 原工程）
  static const String newLifeAddNote = '$_base/new_life_add_note.png';
  static const String newLifeCalendarPrevious =
      '$_base/new_life_calendar_previous.png';
  static const String newLifeCalendarNext = '$_base/new_life_calendar_next.png';
  static const String newLifeSettings = '$_base/new_life_settings.png';

  // ScanToolsFragment 工具页资源（取自 toolbox_c drawable/mipmap-xxhdpi）
  // PDF 工具区（MenuFragment PdfToolsSection）
  static const String iconPdfImg = '$_base/icon_pdf_img.png';
  static const String iconImgPdf = '$_base/icon_img_pdf.png';
  static const String iconYasuoPdf = '$_base/icon_yasuo_pdf.png';
  static const String iconJiamiPdf = '$_base/icon_jiami_pdf.png';
  // 图片工具区
  static const String mtoolslSst = '$_base/mtoolsl_sst.png';
  static const String mtoolslTxt = '$_base/mtoolsl_txt.png';
  static const String mtoolslYct = '$_base/mtoolsl_yct.png';
  static const String mtoolslHbss = '$_base/mtoolsl_hbss.png';
  // 其他区
  static const String mtoolslHlhs = '$_base/mtoolsl_hlhs.png';
  static const String mtoolslJzzh = '$_base/mtoolsl_jzzh.png';
  static const String mtoolslRqjs = '$_base/mtoolsl_rqjs.png';
  static const String mtoolslEw = '$_base/mtoolsl_ew.png';
  static const String mtoolslSjs = '$_base/mtoolsl_sjs.png';
  static const String mtoolslJson = '$_base/mtoolsl_json.png';
}
