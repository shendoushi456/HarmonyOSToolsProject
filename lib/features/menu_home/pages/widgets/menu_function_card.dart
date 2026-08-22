import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// 常用工具纵向卡片 - 对齐 MenuFragment.kt:532-607 FunctionCard
/// 左侧图标 38dp + 中间 label/label2 + 右侧箭头 16dp，白底圆角 5dp + 阴影
class MenuFunctionCard extends StatelessWidget {
  final String icon;
  final Color iconBackgroundColor;
  final String label;
  final String label2;
  final VoidCallback onTap;

  const MenuFunctionCard({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.label,
    required this.label2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.menuCardBg,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.menuCardShadow,
              blurRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Image.asset(
                  icon,
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.menuSectionTitle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label2,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.menuCardSubtitle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.menuCardSubtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
