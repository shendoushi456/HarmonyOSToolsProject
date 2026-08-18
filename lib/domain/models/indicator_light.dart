/// 指示灯数据模型
///
/// 对应 Android: toolCarLib/CarIndicatorLightActivity.kt:37-44
/// 原 Android 用 Int (R.mipmap) 引用图片，Dart 改为 String asset 路径。
/// textIconColor 用 int (ARGB) 存储，避免 domain 层依赖 flutter。
class IndicatorLight {
  final String name;
  final String description;
  final String iconAsset;
  final bool isTextIcon;
  final String textIcon;
  final int textIconColor; // ARGB，默认 0xFF0FC093

  const IndicatorLight({
    required this.name,
    required this.description,
    required this.iconAsset,
    this.isTextIcon = false,
    this.textIcon = '',
    this.textIconColor = 0xFF0FC093,
  });
}
