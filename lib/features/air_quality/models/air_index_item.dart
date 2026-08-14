// 空气质量生活指数项 - 对齐 Android AirIndexItem + AirIconType
import 'package:flutter/foundation.dart';

/// 矢量图标类型 - 对齐 Android AirIconType(行 434)
enum AirIconType { clothing, transit, travel, sun }

@immutable
class AirIndexItem {
  /// 标题(如"紫外线指数")
  final String title;

  /// 数值(如"中等")
  final String value;

  /// 图片资源路径(非空时用图片,空时用 CustomPainter)
  final String? imageAsset;

  /// 矢量图标类型(当 imageAsset 为空时使用)
  final AirIconType iconType;

  const AirIndexItem({
    required this.title,
    required this.value,
    this.imageAsset,
    required this.iconType,
  });
}
