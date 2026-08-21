// 自定义 FlowRow - 对齐 Android MapRouteActivity.kt 中的 FlowRow Layout
// Flutter 端用 Wrap 实现类似的自适应换行布局
import 'package:flutter/material.dart';

/// 自定义 FlowRow - 对齐 Android MapRouteActivity.FlowRow
/// 子项按主轴排列，超出宽度自动换行
class FlowRow extends StatelessWidget {
  const FlowRow({
    super.key,
    required this.children,
    this.horizontalSpacing = 0,
    this.verticalSpacing = 0,
    this.alignment = WrapAlignment.start,
  });

  /// 子组件列表
  final List<Widget> children;

  /// 水平间距 - 对齐 Android horizontalSpacing: Dp = 0.dp
  final double horizontalSpacing;

  /// 垂直间距 - 对齐 Android verticalSpacing: Dp = 0.dp
  final double verticalSpacing;

  /// 对齐方式
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: alignment,
      spacing: horizontalSpacing,
      runSpacing: verticalSpacing,
      children: children,
    );
  }
}
