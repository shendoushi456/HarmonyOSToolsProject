// RouteItem 卡片 - 对齐 LifeFragment.kt:770-818 的 RouteItem Composable
// 结构: Surface(圆角15 + 白底 + clickable) + Row(padding h6 v12 + centerVertical) + 图标30dp + 间距12 + 文字12sp #1E1E1E
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';

/// 单个工具入口卡片(图标+文字横排,圆角白色背景)
///
/// 对齐 Android LifeFragment.kt:770-818 RouteItem
class RouteItem extends StatelessWidget {
  const RouteItem({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.label,
    required this.onTap,
  });

  /// 图标资源路径(assets/images/xxx.png)
  final String icon;

  /// 图标背景色(对齐 LifeFragment 各卡片的 iconBackgroundColor)
  final Color iconBackgroundColor;

  /// 卡片标签文字
  final String label;

  /// 点击回调
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Row(
            children: [
              // 图标 30dp(对齐 LifeFragment.kt:798-803)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(
                  icon,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              // 标签文字(对齐 LifeFragment.kt:808-815)
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.toolsCardText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 笔记本卡片(大图入口) - 对齐 LifeFragment.kt:544-554 Notebook Composable
/// 高 225dp, 宽填满, 点击跳记事本列表页
class NotebookCard extends StatelessWidget {
  const NotebookCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        AppAssets.notebookCard,
        width: double.infinity,
        height: 225,
        fit: BoxFit.fill,
      ),
    );
  }
}
