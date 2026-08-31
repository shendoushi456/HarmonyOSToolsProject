// 日历页主体 - 对齐 Android CalendarFragment.LifeComposableContent（行 72-133）
// Scaffold 0xFF010C39 + SafeArea + Column[CalendarTopBar, Expanded(SingleChildScrollView(Column[CalendarSection, HealthLifestyleBox]))]
// 整体滑动 - 对齐 Android Column.verticalScroll(rememberScrollState())
import 'package:flutter/material.dart';
import 'widgets/calendar_top_bar.dart';
import 'widgets/calendar_section.dart';
import 'widgets/health_lifestyle_box.dart';

class CalendarFragment extends StatelessWidget {
  const CalendarFragment({super.key});

  @override
  Widget build(BuildContext context) {
    // 整个 widget 树都是常量，用 const Scaffold 包裹（const 上下文内构造自动 const）
    return const Scaffold(
      // 对齐 Android Box(background = Color(0xFF010C39)) 深蓝背景
      backgroundColor: Color(0xFF010C39),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 顶栏 - 对齐 Android Scaffold(topBar = { TopAppBar() })
            CalendarTopBar(),
            // 内容区 - 对齐 Android Box → Column(verticalScroll)
            // 整体滑动：SingleChildScrollView（对齐安卓 Column.verticalScroll）
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 日历部分 - 对齐 Android CalendarSection()
                    CalendarSection(),
                    // 健康生活方式卡 - 对齐 Android 行 92-125 的 Box
                    HealthLifestyleBox(),
                    // 底部留白
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
