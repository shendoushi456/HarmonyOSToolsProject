import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 应用主题
///
/// 对应 Android 项目的视觉风格：绿色顶栏、白底卡片、灰色页面背景。
ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.pageBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      margin: EdgeInsets.zero,
    ),
  );
}
