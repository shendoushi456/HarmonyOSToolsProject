// 应用颜色常量 - 对齐 Android 端 WeatherChildFragment.kt 的颜色定义
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// 主蓝色 - 标题/选中态/趋势切换选中
  static const Color qmtqBlue = Color(0xFF159BD8);

  /// 橙色 - 高温曲线/今日高亮
  static const Color qmtqOrange = Color(0xFFFFB55D);

  /// 主文本色
  static const Color qmtqText = Color(0xFF1E1E1E);

  /// 天气大图标圆形背景
  static const Color weatherIconBg = Color(0xFF86D2FE);

  /// 低温曲线
  static const Color lowTemp = Color(0xFF5CAFF1);

  /// 日落标记橙
  static const Color sunsetMark = Color(0xFFFFAF00);

  /// 空气质量"优"标签背景
  static const Color airGood = Color(0xFF5CAFF1);

  /// 空气质量其他标签背景
  static const Color airOther = Color(0xFFFFB964);

  /// 趋势/列表切换背景灰
  static const Color switchBg = Color(0xFFF6F6F6);

  /// 白色
  static const Color white = Color(0xFFFFFFFF);

  /// 日历主蓝(选中圆/Tab选中) - 对齐 Android CalendarFragment CalendarBlue
  static const Color calendarBlue = Color(0xFF59B5F7);

  /// 日历主文本色 - 对齐 Android CalendarText(与 qmtqText 相同)
  static const Color calendarText = Color(0xFF1E1E1E);

  /// 日历选中周日期色 - 对齐 Android CalendarDateBlue
  static const Color calendarDateBlue = Color(0xFF6B91C0);

  /// 选城市页背景蓝 - 对齐 Android ac_add_city.xml #3F5BDF
  static const Color addCityBg = Color(0xFF3F5BDF);

  /// 搜索框半透明白背景 - 对齐 Android shape_search_bg.xml #1AFFFFFF
  static const Color searchBoxBg = Color(0x1AFFFFFF);

  /// 日历分隔线灰
  static const Color calendarDivider = Color(0xFFE3E3E3);

  /// 日历非本月日期灰
  static const Color calendarOffMonth = Color(0xFFD4D4D4);

  /// 日历次要文本灰
  static const Color calendarHint = Color(0xFF8B8B8B);

  /// 记账支出橙(对齐安卓 ExpenseContent)
  static const Color expenseOrange = Color(0xFFFF9E3D);

  // ====== 空气质量页颜色 - 对齐 AirQualityDashboardFragment ======
  /// 空气质量图标主色(对齐 AirBlue)
  static const Color airBlue = Color(0xFF36B4F7);

  /// 空气质量标签背景(对齐 AirTagBlue)
  static const Color airTagBlue = Color(0xFFE1F5FF);

  /// AQI 卡片渐变起点
  static const Color airGradientStart = Color(0xFFD3F2FF);

  /// AQI 卡片渐变终点
  static const Color airGradientEnd = Color(0xFF35B4F7);

  // ====== 设置页颜色 - 对齐 yzqx_setting_theme 等 ======
  /// 设置页顶部栏蓝(对齐 yzqx_setting_theme #6FBFFF)
  static const Color settingTheme = Color(0xFF6FBFFF);

  /// 设置项文字色
  static const Color settingItemText = Color(0xFF404040);

  /// 设置页次要灰(版本号)
  static const Color settingSubText = Color(0xFF999999);

  /// 设置页应用名色
  static const Color settingAppName = Color(0xFF333333);

  // ====== WiFi 工具页颜色 - 对齐 activity_main_tool.xml + item_my_wifi_list.xml ======
  /// WiFi 页背景灰(对齐 activity_main_tool.xml 根 #E3EEFF)
  static const Color wifiHomeBg = Color(0xFFE3EEFF);

  /// WiFi 页背景灰
  static const Color wifiPageBg = Color(0xFFEDEFF9);

  /// "当前网络状态良好"绿(对齐 net_status #FF51AB30)
  static const Color wifiConnectGreen = Color(0xFF51AB30);

  /// "已连接"按钮蓝(对齐 blue_btn, 取色 #317EFE)
  static const Color wifiBlueBtn = Color(0xFF317EFE);

  /// WiFi 卡片标题色("wifi列表" #1E1E1E)
  static const Color wifiCardText = Color(0xFF1E1E1E);

  /// WiFi 列表已连接项文字蓝(对齐 lmwifiylj #3674EB)
  static const Color wifiConnectedBlue = Color(0xFF3674EB);

  /// WiFi 列表未连接项文字深灰(对齐 text_primary #3C3C3C)
  static const Color wifiDisconnectedText = Color(0xFF3C3C3C);

  /// WiFi 卡片阴影色(对齐 shape_shadowColor #666666)
  static const Color wifiCardShadow = Color(0x66666666);

  /// WiFi dialog 确认按钮蓝(对齐 dialog_wifi #FF5597F7)
  static const Color wifiDialogConfirm = Color(0xFF5597F7);

  // ====== LifeTools 颜色 - 对齐 LifeFragment.kt + TravelChecklistScreen.kt ======
  /// 工具页顶栏背景(旅行清单/记账/记事本,对齐 #F0FFB8)
  static const Color toolsTopBarBg = Color(0xFFF0FFB8);

  /// 顶栏标题色
  static const Color toolsTitleText = Color(0xFF4C4C4C);

  /// RouteItem label 色
  static const Color toolsCardText = Color(0xFF1E1E1E);

  /// 旅行清单 section 标题
  static const Color toolsSectionTitle = Color(0xFF303030);

  /// 旅行清单 "x/y" 计数
  static const Color toolsSectionCount = Color(0xFF737373);

  // ====== 指南针颜色 - 对齐 ChaosCompassView colors.xml ======
  /// 对齐 R.color.darkRed #702216
  static const Color compassDarkRed = Color(0xFF702216);

  /// 对齐 R.color.deepGray #8B8B8B
  static const Color compassDeepGray = Color(0xFF8B8B8B);

  /// 对齐 R.color.lightGray #323232
  static const Color compassLightGray = Color(0xFF323232);

  /// 偏转红弧(mAnglePaint) - 对齐 R.color.red #FF0000
  static const Color compassRed = Color(0xFFFF0000);

  /// 对齐内圆辐射渐变起点 #323232(与 lightGray 同)
  static const Color compassInnerStart = Color(0xFF323232);

  /// 对齐内圆辐射渐变终点 #000000
  static const Color compassInnerEnd = Color(0xFF000000);

  // ====== LifeFragment 卡片图标背景色 - 对齐 LifeFragment.kt:271-452 ======
  /// 旅行清单图标背景(对齐 ic_tong_life_3_3 #FEF9C3)
  static const Color cardTravelIconBg = Color(0xFFFEF9C3);

  /// 指南针图标背景(对齐 ic_tong_life_3_4 #F3E8FF)
  static const Color cardCompassIconBg = Color(0xFFF3E8FF);

  /// 花费记账图标背景(对齐 ic_shan_main_4_8 #DCFCE7)
  static const Color cardTallyIconBg = Color(0xFFDCFCE7);

  /// 今天吃什么图标背景(对齐 eat_icon #F3E8FF)
  static const Color cardEatIconBg = Color(0xFFF3E8FF);

  /// json编辑器图标背景(对齐 json_icon #DBEAFE)
  static const Color cardJsonIconBg = Color(0xFFDBEAFE);

  /// 画板图标背景(对齐 drawb_icon #DCFCE7)
  static const Color cardDrawIconBg = Color(0xFFDCFCE7);

  /// 马赛克图标背景(对齐 ic_shan_main_4_9 #FEF9C3)
  static const Color cardBlurIconBg = Color(0xFFFEF9C3);

  // ====== 记事本/记账 tallynotes 模块颜色 ======
  /// 记事本/记账顶栏蓝(对齐 activity_record.xml @color/blue)
  static const Color notepadTitleBlue = Color(0xFF7B68EE);

  /// 记事本次要文字紫(对齐 item_time #7b68ee)
  static const Color notepadSubText = Color(0xFF7B68EE);

  /// 记账表头文字色(对齐 record_item_layout #404040)
  static const Color tallyHeaderText = Color(0xFF404040);

  /// 记账分隔线色(对齐 0.5dp #D8D3D3)
  static const Color tallyDivider = Color(0xFFD8D3D3);

  // ====== MenuHome 颜色 - 对齐 MenuFragment.kt:202-526 ======
  /// 常用工具卡片背景色(白)
  static const Color menuCardBg = Color(0xFFFFFFFF);

  /// 生成二维码图标背景(对齐 ic_tong_life_2_1 #C9F0FF)
  static const Color qrGenerateIconBg = Color(0xFFC9F0FF);

  /// 扫描二维码图标背景(对齐 ic_tong_life_2_2 #E6B5FA)
  static const Color qrScanIconBg = Color(0xFFE6B5FA);

  /// MenuHome 分组标题色(对齐 #1E1E1E)
  static const Color menuSectionTitle = Color(0xFF1E1E1E);

  /// MenuHome 卡片副标题色(对齐 #757575)
  static const Color menuCardSubtitle = Color(0xFF757575);

  /// MenuHome 卡片阴影色(对齐 #0A000000)
  static const Color menuCardShadow = Color(0x0A000000);

  // ====== NewDrawBoardFragment 首页颜色 - 对齐 fragment_new_drawboard.xml ======
  /// 首页背景米黄(对齐 #FFF1EBD5)
  static const Color homeBg = Color(0xFFF1EBD5);

  /// 图片编辑器卡片蓝(对齐 #FF89BDE5)
  static const Color homeImageEditorCard = Color(0xFF89BDE5);

  /// 识别卡半透明白(对齐 #4DFFFFFF)
  static const Color homeRecognitionCard = Color(0x4DFFFFFF);

  /// 涂鸦卡渐变色(对齐 #FFF5F1E2)
  static const Color homeGraffitiGradient = Color(0xFFF5F1E2);

  // ====== CategoryDrawPage 17 色 - 对齐 MainActivityTwo colors.xml:93-110 ======
  // 注意: deepPurple 保真 Bug，命名紫色但实际值是橙色 #ebab7f
  static const Color categoryBlack = Color(0xFF000000);
  static const Color categoryGray = Color(0xFF757575);
  static const Color categoryBrown = Color(0xFF795548);
  static const Color categoryDeepBlue = Color(0xFF303F9F);
  static const Color categoryLightBlue = Color(0xFF03A9F4);
  static const Color categoryDeepPurple = Color(0xFFEBAB7F); // 保真 Bug: 命名紫实际橙
  static const Color categoryLightPurple = Color(0xFF9C27B0);
  static const Color categoryRed = Color(0xFFE53935);
  static const Color categoryLightPink = Color(0xFFFF80AB);
  static const Color categoryDeepPink = Color(0xFFD81B60);
  static const Color categoryDeepGreen = Color(0xFF2E7D32);
  static const Color categoryLightGreen = Color(0xFF8BC34A);
  static const Color categoryYellow = Color(0xFFFFEB3B);
  static const Color categoryLightOrange = Color(0xFFFFE39F);
  static const Color categoryDeepOrange = Color(0xFFFF9800);
  static const Color categoryWhite = Color(0xFFFFFFFF);
}
