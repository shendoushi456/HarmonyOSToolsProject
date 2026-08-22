// 旅行清单分组标题 - 对齐 Android TravelChecklistScreen.kt:198-224 SectionHeader + ListHeader
// SectionHeader: Row(标题12sp bold #303030 + Spacer + "completedCount/totalCount" 12sp #737373)
// ListHeader: Row(Spacer weight1 + "completed/total" 12sp #737373 + Spacer8 + "只看未完成" 12sp bold #4C4C4C + Switch scale 0.5)
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// 普通分组标题 - 对齐 SectionHeader.kt:198-224
class ChecklistSectionHeader extends StatelessWidget {
  const ChecklistSectionHeader({
    super.key,
    required this.title,
    required this.completedCount,
    required this.totalCount,
  });

  final String title;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.toolsSectionTitle,
            ),
          ),
          const Spacer(),
          Text(
            '$completedCount/$totalCount',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.toolsSectionCount,
            ),
          ),
        ],
      ),
    );
  }
}

/// 第一组的总计数 + "只看未完成" Switch - 对齐 ListHeader.kt:148-194
class ChecklistListHeader extends StatelessWidget {
  const ChecklistListHeader({
    super.key,
    required this.completed,
    required this.total,
    required this.showOnlyIncomplete,
    required this.onToggle,
  });

  final int completed;
  final int total;
  final bool showOnlyIncomplete;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Text(
          '$completed/$total',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.toolsSectionCount,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '只看未完成',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: showOnlyIncomplete
                ? const Color(0xFF4C4C4C)
                : const Color(0xFF9E9E9E),
          ),
        ),
        // Switch scale 0.5(对齐 Compose Switch scale 0.5)
        Transform.scale(
          scale: 0.5,
          child: Switch(
            value: showOnlyIncomplete,
            onChanged: onToggle,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
