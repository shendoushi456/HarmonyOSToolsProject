import 'package:flutter/material.dart';

/// 应用颜色常量
///
/// 保真还原安卓工程 Compose 代码中硬编码的 `Color(0xFF......)` 值，
/// 集中管理便于后续马甲包 UI 替换。
class AppColors {
  AppColors._();

  // 文本翻译首页
  /// 页面背景浅蓝（Box 背景）
  static const Color pageBackground = Color(0xFFF0FEFF);

  /// 标题栏背景蓝 / 输入卡片边框
  static const Color primaryBlue = Color(0xFF28C7FF);

  /// 卡片白色背景
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// 输入文字深色
  static const Color inputText = Color(0xFF2C2C2C);

  /// 占位提示文字灰 / 违规提示
  static const Color hintText = Color(0xFF616161);

  /// 字数统计灰
  static const Color counterGray = Color(0xFF999999);

  /// 字数超限红
  static const Color counterOverLimit = Color(0xFFFF6B6B);

  /// 语言选择器背景浅蓝
  static const Color languageSelectorBackground = Color(0xFFD3F3FE);

  /// 翻译按钮渐变起点（黄）
  static const Color buttonGradientStart = Color(0xFFF9BD03);

  /// 翻译按钮渐变终点（橙）
  static const Color buttonGradientEnd = Color(0xFFFF890A);

  /// Loading 状态按钮灰
  static const Color buttonLoadingGray = Color(0xFF909090);

  /// Loading 进度条蓝
  static const Color loadingIndicator = Color(0xFF15B0FC);

  /// Loading 遮罩黑色（alpha 0.3）
  static const Color loadingOverlay = Color(0x4D000000);

  // 翻译详情页
  /// 详情页文本区背景
  static const Color detailSectionBackground = Color(0xFFE4F3FA);

  /// 详情页文字深色
  static const Color detailText = Color(0xFF333333);

  // 语言选择页
  /// 语言选择页背景
  static const Color langSwitchBackground = Color(0xFFF3F6FE);

  /// 语言选择页主题橙
  static const Color langSwitchPrimary = Color(0xFFFD6F33);

  /// 语言选择页文字深色
  static const Color langSwitchText = Color(0xFF1E1E1E);

  /// 语言选择页未选中文字
  static const Color langSwitchUnselected = Color(0xFF424242);

  /// 搜索框文字
  static const Color searchText = Color(0xFF171715);

  /// 搜索框占位
  static const Color searchHint = Color(0xFF565656);
}
