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
}
