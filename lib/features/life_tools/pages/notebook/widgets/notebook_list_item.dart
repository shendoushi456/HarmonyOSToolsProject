// 记事本列表项 - 对齐 Android notebook_item_layout.xml
// LinearLayout(vertical, paddingLeft 12dp) + 内容(2行省略) + 时间(#7b68ee)
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/notebook_bean.dart';

class NotebookListItem extends StatelessWidget {
  const NotebookListItem({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  final NotebookBean note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 内容(对齐 item_content, maxLines 2, ellipsize end)
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                height: 1.2,
                color: AppColors.qmtqText,
              ),
            ),
            const SizedBox(height: 5),
            // 时间(对齐 item_time, #7b68ee)
            Text(
              note.notebookTime,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.notepadSubText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
