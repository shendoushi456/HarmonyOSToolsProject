// 日历页主体 - 对齐 Android NearbyFragment.ScreenContent
// Box 0xFFF5F8FC + TopStatusBar + Stack(蓝色渐变 250dp 背景 + Column.verticalScroll)
//   LifeTipsRow + CalendarSection + Spacer + PressureManagementBox
import 'package:flutter/material.dart';
import '../models/chinese_calendar_bean.dart';
import 'widgets/calendar_new_top_bar.dart';
import 'widgets/life_tips_row.dart';
import 'widgets/calendar_section.dart';
import 'widgets/pressure_management_box.dart';

class CalendarNewChildPage extends StatelessWidget {
  /// 显示的月份（该月第一天）
  final DateTime displayMonth;

  /// 当前选中日期
  final DateTime selectedDate;

  /// 黄历数据 - 对齐 Android calendarInfo
  final ChineseCalendarBean? almanac;

  /// 上一月回调
  final VoidCallback onPreviousMonth;

  /// 下一月回调
  final VoidCallback onNextMonth;

  /// 选中日期回调
  final void Function(DateTime) onSelectDate;

  const CalendarNewChildPage({
    super.key,
    required this.displayMonth,
    required this.selectedDate,
    this.almanac,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: Column(
        children: [
          // 顶部栏 - 对齐 Android Scaffold.topBar { TopStatusBar() }
          const CalendarNewTopBar(),
          // 内容区 - 对齐 Android Box { Box(蓝色渐变 250dp) + Column(verticalScroll) }
          Expanded(
            child: Stack(
              children: [
                // 蓝色渐变背景 250dp - 对齐 Android Box(verticalGradient #73C3EB→#73C3EB, height 250dp)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 250,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF73C3EB),
                          Color(0xFF73C3EB),
                        ],
                      ),
                    ),
                  ),
                ),
                // 滚动内容 - 对齐 Android Column(verticalScroll, padding top status bar)
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 生活小窍门 Row - 对齐 Android Row(padding 30dp)
                        const LifeTipsRow(),
                        // 日历区域 - 对齐 Android CalendarSection()
                        CalendarSection(
                          displayMonth: displayMonth,
                          selectedDate: selectedDate,
                          almanac: almanac,
                          onPreviousMonth: onPreviousMonth,
                          onNextMonth: onNextMonth,
                          onSelectDate: onSelectDate,
                        ),
                        // 对齐 Android Spacer(width 30dp) + Spacer(height 19dp)
                        const SizedBox(height: 19),
                        // 压力管理卡片 - 对齐 Android PressureManagementBox()
                        const PressureManagementBox(),
                        // 对齐 Android Spacer(height 19dp)
                        const SizedBox(height: 19),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
