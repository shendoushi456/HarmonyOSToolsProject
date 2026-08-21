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

  // ====== 畅行（bus）模块颜色 - 对齐 Android bus/utils/BusThemeColors + HomeFragment.kt ======
  /// 畅行主题色（对齐 Android BusThemeColors.PRIMARY_COLOR = 0xFF31C580）
  static const Color busPrimary = Color(0xFF31C580);

  /// 畅行主题色上的对比色（对齐 Android BusThemeColors.ON_PRIMARY_COLOR）
  static const Color busOnPrimary = Color(0xFFFFFFFF);

  /// 畅行强调色（对齐 Android HomeFragment.JbcxAccent = 0xFF7CE2E2）
  static const Color jbcxAccent = Color(0xFF7CE2E2);

  /// 畅行主文本色（对齐 Android HomeFragment.JbcxText = 0xFF1E1E1E）
  static const Color jbcxText = Color(0xFF1E1E1E);

  /// 畅行次要文本灰（对齐 Android HomeFragment.kt 0xFF626262）
  static const Color jbcxSubText = Color(0xFF626262);

  /// 畅行输入框文本灰（对齐 Android HomeFragment.kt 0xFF666666）
  static const Color jbcxInputText = Color(0xFF666666);

  /// 畅行路线卡片背景灰（对齐 Android HomeFragment.kt 0xFFF3F3F3）
  static const Color jbcxRouteBg = Color(0xFFF3F3F3);

  /// 畅行路线起点绿（对齐 Android HomeFragment.kt 0xFF37D466）
  static const Color jbcxRouteStart = Color(0xFF37D466);

  /// 畅行路线终点红（对齐 Android HomeFragment.kt 0xFFD43737）
  static const Color jbcxRouteEnd = Color(0xFFD43737);

  /// 畅行分隔线灰（对齐 Android HomeFragment.kt 0xFFE0E0E0）
  static const Color jbcxDivider = Color(0xFFE0E0E0);

  /// 畅行头部渐变起点（对齐 Android HomeFragment.kt 0xFFBCFFFF）
  static const Color jbcxHeaderGradientStart = Color(0xFFBCFFFF);

  /// 畅行头部渐变终点
  static const Color jbcxHeaderGradientEnd = Color(0xFFFFFFFF);

  /// 畅行地址区域分隔线灰（对齐 Android AddressSection.kt 0xFFE5E5E5）
  static const Color jbcxAddressDivider = Color(0xFFE5E5E5);

  /// 畅行地址次要文本灰（对齐 Android AddressSection.kt 0xFF888888）
  static const Color jbcxAddressSubText = Color(0xFF888888);

  /// 畅行交换图标色（对齐 Android MapRouteActivity.kt 0xFF333333）
  static const Color jbcxSwapIcon = Color(0xFF333333);
}
