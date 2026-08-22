import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// PDF 工具网格项 - 对齐 MenuFragment.kt:678-714 GridToolItem
/// 图片在上(76dp)，标题在下(12sp)，无背景
class MenuGridItem extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const MenuGridItem({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            image,
            width: 76,
            height: 76,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.menuSectionTitle,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
