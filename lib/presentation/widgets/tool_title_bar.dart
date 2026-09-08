import 'package:flutter/material.dart';

/// toolbox_c 通用工具标题栏 —— 对应 calculatorlibrary title_bar_tool.xml：
/// 背景 #9FDE6E（teal_700）、高 55dp、返回键 iv_back（左 15dp）、
/// 居中标题 18sp 白色。
class ToolTitleBar extends StatelessWidget {
  const ToolTitleBar({
    super.key,
    required this.title,
    this.showTitle = true,
    this.onBack,
    this.height = 55,
  });

  final String title;

  /// SPuActivity 中 shipu_title 为 GONE，仅显示返回键。
  final bool showTitle;
  final VoidCallback? onBack;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: const Color(0xFF9FDE6E),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showTitle)
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                child: Image.asset(
                  'assets/images/recipes_tools/iv_back.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
