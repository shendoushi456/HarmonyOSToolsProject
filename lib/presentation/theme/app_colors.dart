import 'package:flutter/material.dart';

/// 品牌色常量
///
/// 对应 Android 项目主色调，集中管理便于马甲包改色。
abstract final class AppColors {
  /// 主绿（顶栏背景、主按钮）—— 0xFF0FC093
  static const primary = Color(0xFF0FC093);

  /// 违章查询主卡片背景 —— 0xFF39D6AE
  static const violationCardBg = Color(0xFF39D6AE);

  /// 首页背景灰 —— 0xFFF8F8F8
  static const pageBg = Color(0xFFF8F8F8);

  /// 子页面背景灰 —— 0xFFF5F5F5
  static const subPageBg = Color(0xFFF5F5F5);

  /// 主文字色 —— 0xFF404040
  static const primaryText = Color(0xFF404040);

  /// 次文字色 —— 0xFF777777
  static const secondaryText = Color(0xFF777777);

  /// 错误/提示红 —— 0xFFFF6B6B
  static const errorRed = Color(0xFFFF6B6B);

  /// 指示灯说明橙 —— 0xFFFF9945
  static const indicatorOrange = Color(0xFFFF9945);

  /// 驾照扣分 Tab 未选中文字 —— 0xFF5E5E5E
  static const tabUnselected = Color(0xFF5E5E5E);

  /// Markdown 页顶栏蓝（还原原 Android Bug 行为）—— 0xFF4692F5
  static const markdownBlue = Color(0xFF4692F5);

  // 5 圆图标背景色（对应 CarFragment.kt:431-452）
  static const circleIcon1 = Color(0xFF44DCB5); // 交通标志
  static const circleIcon2 = Color(0xFFF9C264); // 交警手势
  static const circleIcon3 = Color(0xFF689EFC); // 道路信号
  static const circleIcon4 = Color(0xFFAFBCFF); // 硬件图解
  static const circleIcon5 = Color(0xFFFFB4AF); // 科二技巧
}
