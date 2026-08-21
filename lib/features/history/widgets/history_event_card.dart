// 历史事件卡片 - 对齐 Android item_day.xml + Recyclerview1Adapter
// 白底 + 1dp 灰色描边 + 0 elevation, 无图时隐藏图片(对齐 Android setVisibility(GONE))
// 图片 96dp 高 fitCenter(对齐 Android ImageView scaleType=fitCenter)
// time 14sp Bold 黑色(对齐 textColor=editTextColor=工具箱模块覆盖为 #FF000000)
// name 14sp 黑色 maxLines 3 ellipsize end, marginTop 2dp
import 'package:flutter/material.dart';
import '../models/history_event.dart';

class HistoryEventCard extends StatelessWidget {
  /// 事件数据
  final HistoryEvent event;

  /// 点击卡片回调 - 对齐 Android cardview1.setOnClickListener → CopyDialog
  final VoidCallback? onTap;

  const HistoryEventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // 对齐 Android MaterialCardView: 白底 + 1dp 灰色描边 + 0 elevation
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFBDBDBD), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片 96dp 高 fitCenter - 对齐 Android ImageView height=96dp scaleType=fitCenter
            // 无图时隐藏(对齐 Android setVisibility(GONE))
            if (event.img.isNotEmpty)
              SizedBox(
                height: 96,
                width: double.infinity,
                child: Image.network(
                  event.img,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              )
            else
              const SizedBox.shrink(), // 对齐 setVisibility(GONE)
            // 内容区 padding 12dp - 对齐 Android LinearLayout padding=12dp
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // time 14sp Bold 黑色
                  Text(
                    event.time,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // name 14sp 黑色 maxLines 3 ellipsize end, marginTop 2dp
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      event.name,
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
