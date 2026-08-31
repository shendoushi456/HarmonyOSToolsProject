// 日历卡 - 对齐 Android CalendarFragment.CalendarSection（行 460-485）
// Container margin start20 top20 end20 bottom10 + padding v10 + bg 0xFF333D60 + RoundedCorner 6 →
//   Column → CalendarDarkGrid（年月+占位分割线+周栏+6×7网格+月份切换手势）
import 'package:flutter/material.dart';
import 'calendar_dark_grid.dart';

class CalendarSection extends StatelessWidget {
  const CalendarSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(padding start20 top20 end20 bottom10 + padding v10, bg 0xFF333D60, RoundedCorner 6)
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10), // 对齐 padding vertical 10dp
      decoration: BoxDecoration(
        color: const Color(0xFF333D60), // 对齐 bg 0xFF333D60
        borderRadius: BorderRadius.circular(6), // 对齐 RoundedCorner 6dp
      ),
      child: const CalendarDarkGrid(),
    );
  }
}
