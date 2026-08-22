// 旅行清单项 - 对齐 Android TravelChecklistScreen.kt:228-256 ChecklistItemRow
// Row(clickable + padding start 10 top/bottom 8 + 复选框14dp + 间距8 + 文字14sp #303030)
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/checklist_item.dart';

class ChecklistItemRow extends StatelessWidget {
  const ChecklistItemRow({
    super.key,
    required this.item,
    required this.onToggle,
  });

  final ChecklistItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
        child: Row(
          children: [
            // 复选框 14dp(对齐 checkedColor Black, uncheckedColor #777777, checkmarkColor White)
            SizedBox(
              width: 14,
              height: 14,
              child: Checkbox(
                value: item.isChecked,
                onChanged: (_) => onToggle(),
                activeColor: Colors.black,
                checkColor: Colors.white,
                side: const BorderSide(color: Color(0xFF777777), width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.text,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.toolsSectionTitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
