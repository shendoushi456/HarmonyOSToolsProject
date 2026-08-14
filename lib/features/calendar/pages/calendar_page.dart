// 日历页面 - 预留入口(对齐 Android CalendarFragment,本期仅占位)
import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '敬请期待',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF999999),
          ),
        ),
      ),
    );
  }
}
