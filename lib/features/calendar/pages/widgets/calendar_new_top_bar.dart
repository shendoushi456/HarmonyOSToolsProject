// 日历顶部栏 - 对齐 Android NearbyFragment.TopStatusBar
// Box fillMaxWidth + Box(verticalGradient #73C3EB→#73C3EB, statusBarsPadding, height 50dp) + Text "日历" 22sp SemiBold White center
import 'package:flutter/material.dart';

class CalendarNewTopBar extends StatelessWidget {
  const CalendarNewTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        // 对齐 Android Brush.verticalGradient(#73C3EB→#73C3EB) - 实为单色
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF73C3EB), Color(0xFF73C3EB)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: const Center(
            // 对齐 Android Text("日历", 22sp SemiBold White, center)
            child: Text(
              '日历',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
