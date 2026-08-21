// 畅行模块主题颜色 - 对齐 Android bus/utils/BusThemeColors.kt
// 转发到 core/constants/app_colors.dart 的 bus* 颜色常量
// 保留此类以维持与 Android 端 BusThemeColors.PRIMARY_COLOR 调用风格一致
import '../../../core/constants/app_colors.dart';

/// Bus 模块主题颜色配置 - 对齐 Android BusThemeColors
class BusThemeColors {
  BusThemeColors._();

  /// 主题颜色 - 对齐 Android PRIMARY_COLOR = Color(0xFF31C580)
  static const primaryColor = AppColors.busPrimary;

  /// 主颜色上的对比色 - 对齐 Android ON_PRIMARY_COLOR = Color.White
  static const onPrimaryColor = AppColors.busOnPrimary;
}
