import 'package:flutter/material.dart';

/// 统一二级页标题栏：左右操作位固定宽度，标题只在中间区域布局，避免互相遮挡。
/// 后续新增页面应复用此组件，而不是在 Stack 中将标题与图标独立绝对定位。
class StandardPageHeader extends StatelessWidget {
  final String title;
  final Widget leading;
  final Widget? trailing;
  final double height;
  final Color titleColor;

  const StandardPageHeader({
    super.key,
    required this.title,
    required this.leading,
    this.trailing,
    this.height = 72,
    this.titleColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Row(children: [
          SizedBox(width: 56, child: Center(child: leading)),
          Expanded(
            child: Center(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: titleColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w500)),
            ),
          ),
          SizedBox(width: 56, child: Center(child: trailing)),
        ]),
      );
}
