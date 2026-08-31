// 历史今天列表项 - 渲染 HistoryEvent(time + name)
import 'package:flutter/material.dart';
import '../../../calendar/models/history_event.dart';

class HistoryTodayListItem extends StatelessWidget {
  final HistoryEvent event;
  final VoidCallback? onTap;

  const HistoryTodayListItem({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 年份
            SizedBox(
              width: 56,
              child: Text(
                event.time == '今日' ? '今日' : '${event.time}年',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3364F8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 事件标题
            Expanded(
              child: Text(
                event.name,
                style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.4),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFBFBFBF)),
          ],
        ),
      ),
    );
  }
}
