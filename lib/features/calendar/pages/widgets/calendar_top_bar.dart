// 日历页顶部栏 - 对齐 Android CalendarFragment.TopAppBar（行 367-390）
// 50dp 高 + 0xFF010C39 深蓝背景 + statusBarsPadding + "日历" 22sp White SemiBold 居中
// 注意：安卓 padding top 14dp + lineHeight 30sp，文字垂直居中
import 'package:flutter/material.dart';

class CalendarTopBar extends StatelessWidget {
  const CalendarTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 整个 widget 树都是常量，用 const Container 包裹
    return const ColoredBox(
      color: Color(0xFF010C39),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Center(
            // 对齐 Android padding top 14dp - 文字垂直偏下居中
            child: Padding(
              padding: EdgeInsets.only(top: 14),
              child: Text(
                '日历',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 22,
                  fontWeight: FontWeight.w600, // SemiBold
                  height: 30 / 22, // lineHeight 30sp
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
