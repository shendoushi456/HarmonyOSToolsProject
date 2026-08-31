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

  /// WiFi 连接卡左侧 wifi 图标(72dp, 对齐 @mipmap/wifi_icon)
  static const String wifiIcon = '$_base/wifi_icon.png';

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

  // ====== Weather 资源 - 对齐 WeatherFragment.kt + tools_fr_weather.xml ======
  /// 日历页设置图标(对齐 @mipmap/ic_setting)
  static const String weatherIcSetting = '$_base/ic_setting.png';

  /// 日历月份切换箭头(对齐 @mipmap/ic_arrow_left / ic_arrow_right)
  static const String weatherIcArrowLeft = '$_base/ic_arrow_left.png';
  static const String weatherIcArrowRight = '$_base/ic_arrow_right.png';

  /// 2×2 功能按钮背景图(对齐 @mipmap/btn_01~04)
  static const String weatherBtnJrjq = '$_base/btn_01.png';
  static const String weatherBtnLssdjt = '$_base/btn_02.png';
  static const String weatherBtnShxqm = '$_base/btn_03.png';
  static const String weatherBtnShjyl = '$_base/btn_04.png';

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

  // CleanMainFragment 纵向工具列表图标（从 Android 原工程迁移并独立命名）。
  static const String cleanToolBankCard = '$_base/clean_tool_bank_card.png';
  static const String cleanToolColourize = '$_base/clean_tool_colourize.png';
  static const String cleanToolStyle = '$_base/clean_tool_style.png';
  static const String cleanToolAnime = '$_base/clean_tool_anime.png';
  static const String cleanToolQr = '$_base/clean_tool_qr.png';
  static const String cleanToolText = '$_base/clean_tool_text.png';
  static const String cleanShortcutPlant = '$_base/clean_shortcut_plant.png';
  static const String cleanShortcutIngredient =
      '$_base/clean_shortcut_ingredient.png';
  static const String cleanShortcutAnimal = '$_base/clean_shortcut_animal.png';

  // NewLifeFragment 首页资源（直接取自 Android 原工程）
  static const String newLifeAddNote = '$_base/new_life_add_note.png';
  static const String newLifeCalendarPrevious =
      '$_base/new_life_calendar_previous.png';
  static const String newLifeCalendarNext = '$_base/new_life_calendar_next.png';
  static const String newLifeSettings = '$_base/new_life_settings.png';

  // ====== NewDrawBoardFragment 首页资源 - 对齐 fragment_new_drawboard.xml ======
  /// 图片编辑器卡片箭头（jiantou_right_icon）
  static const String homeArrowRight = '$_base/jiantou_right_icon.png';
  /// 图片编辑器卡片大图（zpbjq_icon）
  static const String homeImageEditorIcon = '$_base/zpbjq_icon.png';
  /// 花草识别图标（newhomehcsb）
  static const String homePlantIcon = '$_base/newhomehcsb.png';
  /// 果蔬识别图标（newhomegssb）
  static const String homeFruitIcon = '$_base/newhomegssb.png';
  /// 动物识别图标（newhomedwsb）
  static const String homeAnimalIcon = '$_base/newhomedwsb.png';
  /// 特效图图标（newhometxt）
  static const String homeEffectIcon = '$_base/newhometxt.png';
  /// 马赛克图标（newhomemsk）
  static const String homeMosaicIcon = '$_base/newhomemsk.png';
  /// LED灯图标（newhomeled）
  static const String homeLedIcon = '$_base/newhomeled.png';
  /// 扫码识别图标（newhomesmsb）
  static const String homeQrScanIcon = '$_base/newhomesmsb.png';
  /// 涂鸦卡片右上箭头（xiejt_icon）
  static const String homeGraffitiArrow = '$_base/xiejt_icon.png';
  /// 分类涂鸦卡片大图（flty_icon）
  static const String homeCategoryGraffitiIcon = '$_base/flty_icon.png';
  /// 离线涂鸦卡片大图（lxty_icon）
  static const String homeOfflineGraffitiIcon = '$_base/lxty_icon.png';

  // ====== TuyaActivity 分流页资源 - 对齐 activity_tuya.xml ======
  /// 返回按钮（iv_back）
  static const String tuyaBack = '$_base/iv_back.png';
  /// 水果分类图标（newtoolssg）
  static const String tuyaFruit = '$_base/newtoolssg.png';
  /// 字母分类图标（newtoolszm）
  static const String tuyaLetter = '$_base/newtoolszm.png';
  /// 数字分类图标（newtoolssz）
  static const String tuyaNumber = '$_base/newtoolssz.png';
  /// 曼茶罗分类图标（newtoolsmcl）
  static const String tuyaMandala = '$_base/newtoolsmcl.png';
  /// 卡通分类图标（cartoon）
  static const String tuyaCartoon = '$_base/cartoon.png';
  /// 动物分类图标（animal）
  static const String tuyaAnimal = '$_base/animal.png';
  /// 食物分类图标（food）
  static const String tuyaFood = '$_base/food.png';
  /// 交通分类图标（traffic）
  static const String tuyaTraffic = '$_base/traffic.png';
  /// 自然分类图标（nature）
  static const String tuyaNature = '$_base/nature.png';
  /// 鲜花分类图标（flower）
  static const String tuyaFlower = '$_base/flower.png';

  // ====== 底部 Tab 图标（对齐 master_lingganhuasebao color_draw） ======
  static const String colorTabHomeNormal = '$_base/color_draw/icon_tab_tuse.png';
  static const String colorTabHomeSelected =
      '$_base/color_draw/icon_tab_tuse2.png';
  static const String colorTabBoardNormal = '$_base/color_draw/icon_tab_hb.png';
  static const String colorTabBoardSelected =
      '$_base/color_draw/icon_tab_hb2.png';
  static const String colorTabMoreNormal = '$_base/color_draw/icon_tab_gj.png';
  static const String colorTabMoreSelected =
      '$_base/color_draw/icon_tab_gj2.png';

  // ====== ColorDrawPage 画板工具图标（对齐 master_lingganhuasebao color_draw） ======
  static const String colorDrawPenSize = '$_base/color_draw/icon_draw_c1.png';
  static const String colorDrawPencil = '$_base/color_draw/icon_draw_c2.png';
  static const String colorDrawUndo = '$_base/color_draw/icon_draw_c3.png';
  static const String colorDrawRedo = '$_base/color_draw/icon_draw_c4.png';
  static const String colorDrawClear = '$_base/color_draw/icon_draw_c5.png';
  static const String colorDrawPen = '$_base/color_draw/icon_draw_pen.png';
  static const String colorDrawEraser =
      '$_base/color_draw/icon_draw_xiangpi.png';
  static const String colorDrawSave = '$_base/color_draw/icon_hb_save.png';

  // ====== CategoryDrawPage 顶栏图标（对齐 MainActivityTwo） ======
  static const String categoryDrawBack = '$_base/icon_white_back.webp';
  static const String categoryDrawUndo = '$_base/undo_icon.png';
  static const String categoryDrawSoundOn = '$_base/sound_on.png';
  static const String categoryDrawSoundOff = '$_base/sound_off.png';
  static const String categoryDrawSave = '$_base/save_icon.png';

  // ====== CategoryDrawPage 音频资源 ======
  static const String _sndBase = 'assets/sounds';
  static const String categoryDrawBgMusic = '$_sndBase/background_1.mp4';
  static const String categoryDrawClickSfx = '$_sndBase/click.wav';

  // ====== AllToolsFragment 工具页资源 - 对齐 fragment_all_tools.xml ======
  /// 设置按钮（shezhi）
  static const String allToolsSetting = '$_base/shezhi.webp';
  /// 图像风格转换大图（mtoolsl_dmh）
  static const String allToolsStyleTransfer = '$_base/mtoolsl_dmh.png';
  /// 二十四节气图标（jrjq_icon）
  static const String allToolsSolarTerms = '$_base/jrjq_icon.png';
  /// 马赛克图标（msk_icon）
  static const String allToolsMosaic = '$_base/msk_icon.png';
  /// 旅行清单图标（mtoolsl_lxqd）
  static const String allToolsTravelList = '$_base/mtoolsl_lxqd.png';
  /// 花费记账图标（hfjz_icon）
  static const String allToolsTally = '$_base/hfjz_icon.png';
  /// 像素图图标（xst_icon）
  static const String allToolsPixel = '$_base/xst_icon.png';
  /// 黑白上色图标（newhomehbss）
  static const String allToolsColorize = '$_base/newhomehbss.png';
  /// 字体放大图标（ztfd_icon）
  static const String allToolsTextSize = '$_base/ztfd_icon.png';

  // ====== NewDrawkFragment 画板页资源 - 对齐 fragment_new_draw_tool.xml ======
  /// 保存按钮（iv_save2）
  static const String drawkSave = '$_base/iv_save2.png';
  /// 画笔大小图标（lhbdxicon）
  static const String drawkPenSize = '$_base/lhbdxicon.png';
  /// 画笔颜色图标（lhbysicon）
  static const String drawkPenColor = '$_base/lhbysicon.png';
  /// 撤销图标（lcxicon）
  static const String drawkUndo = '$_base/lcxicon.png';
  /// 重做图标（lqjicon）
  static const String drawkRedo = '$_base/lqjicon.png';
  /// 清空图标（lqcicon）
  static const String drawkClear = '$_base/lqcicon.png';
  /// 画板大图（mtoolsl_hb_icon）
  static const String drawkBoardIcon = '$_base/mtoolsl_hb_icon.png';
  /// 跟图绘画图标（newhomegthhdraw）
  static const String drawkTraceDraw = '$_base/newhomegthhdraw.png';
  /// 形状绘画图标（newhomexzhhdraw）
  static const String drawkShapeDraw = '$_base/newhomexzhhdraw.png';
  /// 画笔图标（lhbicon）
  static const String drawkPen = '$_base/lhbicon.png';
  /// 橡皮图标（lxpcicon）
  static const String drawkEraser = '$_base/lxpcicon.png';
}
