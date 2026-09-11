// 通用顶栏 - 对齐安卓 tallynotes/toolslibrary 各 Activity 顶栏
// 背景 #F0FFB8(对齐 activity_notepad.xml / activity_manage.xml / TravelChecklistScreen.kt:109-143)
// 结构:50dp 高 + statusBarsPadding + 左侧返回箭头 + 居中标题(22sp #4C4C4C Medium)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ToolTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ToolTopBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.backgroundColor,
  });

  /// 标题文字
  final String title;

  /// 是否显示返回按钮(默认 true)
  final bool showBack;

  /// 右侧动作按钮(如记账页"添加")
  final List<Widget>? actions;

  /// 顶栏背景色(默认 #F0FFB8)
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.toolsTopBarBg,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showBack)
                Positioned(
                  left: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: AppColors.toolsTitleText,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.toolsTitleText,
                ),
              ),
              if (actions != null && actions!.isNotEmpty)
                Positioned(
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
