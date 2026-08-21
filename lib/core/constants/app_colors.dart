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
}
