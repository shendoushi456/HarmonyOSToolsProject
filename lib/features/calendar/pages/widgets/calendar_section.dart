// 日历区域 - 对齐 Android NearbyFragment.CalendarScreenWithDirectInflation + custom_calendar_layout.xml
// ShapeRelativeLayout(padding 12 20, radius 20): 年月 + 左右箭头
// + CalendarNewGrid(自绘日历网格)
// + Offstage(农历/宜忌 gone 区域,保真保留"设置不可见元素文字"行为)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/lunar_util.dart';
import '../../models/chinese_calendar_bean.dart';
import 'calendar_new_grid.dart';

class CalendarSection extends StatelessWidget {
  /// 显示的月份（该月第一天）
  final DateTime displayMonth;

  /// 当前选中日期
  final DateTime selectedDate;

  /// 黄历数据 - 对齐 Android calendarInfo (ChineseCalendarBean?)
  /// 用于设置宜忌文字到 gone 区域（保真保留行为）
  final ChineseCalendarBean? almanac;

  /// 上一月回调 - 对齐 Android rilileft.setOnClickListener { scrollToPre }
  final VoidCallback onPreviousMonth;

  /// 下一月回调 - 对齐 Android riliright.setOnClickListener { scrollToNext }
  final VoidCallback onNextMonth;

  /// 选中日期回调 - 对齐 Android setOnCalendarSelectListener
  final void Function(DateTime) onSelectDate;

  const CalendarSection({
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
    // 对齐 Android ShapeRelativeLayout(paddingH 12dp, paddingV 20dp, radius 20dp, centerVertical)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 年月导航行 - 对齐 Android title_calender_txt + rilileft + riliright
          _buildMonthNavigation(),
          const SizedBox(height: 12),
          // 自绘日历网格 - 对齐 Android CalendarView
          CalendarNewGrid(
            displayMonth: displayMonth,
            selectedDate: selectedDate,
            onSelectDate: onSelectDate,
          ),
          // 农历/宜忌区域 - 对齐 Android ShapeRelativeLayout(visibility=gone)
          // 保真保留"设置不可见元素文字"行为:用 Offstage 包裹(alway offstage)
          Offstage(
            offstage: true,
            child: _buildAlmanacArea(),
          ),
        ],
      ),
    );
  }

  /// 年月导航行 - 对齐 Android title_calender_txt + rilileft + riliright
  Widget _buildMonthNavigation() {
    // 对齐 Android title_calender_txt "${calendarYear}.${calendarMonth}" 16sp #FF273142
    final yearMonth = '${displayMonth.year}.${displayMonth.month}';
    return Row(
      children: [
        Text(
          yearMonth,
          style: const TextStyle(
            color: Color(0xFF273142),
            fontSize: 16,
          ),
        ),
        const Spacer(),
        // 左箭头(上一月) - 对齐 Android rilileft ic_arrow_left 15dp, marginRight 35dp
        GestureDetector(
          onTap: onPreviousMonth,
          behavior: HitTestBehavior.opaque,
          child: Image.asset(
            AppAssets.calendarArrowLeft,
            width: 15,
            height: 15,
          ),
        ),
        const SizedBox(width: 35), // marginRight 35dp
        // 右箭头(下一月) - 对齐 Android riliright ic_arrow_right 15dp
        GestureDetector(
          onTap: onNextMonth,
          behavior: HitTestBehavior.opaque,
          child: Image.asset(
            AppAssets.calendarArrowRight,
            width: 15,
            height: 15,
          ),
        ),
      ],
    );
  }

  /// 农历/宜忌 gone 区域 - 对齐 Android ShapeRelativeLayout(visibility=gone)
  /// 保真保留"设置不可见元素文字"行为
  /// nongli_info_1(农历日期) + title_calender_txt_2("{month}月{day}日") + 宜/忌 + 天气图标
  Widget _buildAlmanacArea() {
    // 对齐 Android Lunar(selectedCalendar).toString() - 农历日期字符串
    final lunarDate = Lunar.fromDateTime(selectedDate).toString();
    // 对齐 Android title_calender_txt_2.text = "${calendarMonth}月${calendarDay}日"
    final monthDay = '${selectedDate.month}月${selectedDate.day}日';
    // 对齐 Android nongli_info_3.text = bean.fitness ?: "无"
    final fitness = almanac?.fitness.isNotEmpty == true ? almanac!.fitness : '无';
    // 对齐 Android nongli_info_4.text = bean.taboo ?: "无"
    final taboo = almanac?.taboo.isNotEmpty == true ? almanac!.taboo : '无';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // nongli_info_1 - 农历日期 18sp #C76151
        Text(
          lunarDate,
          style: const TextStyle(
            color: Color(0xFFC76151),
            fontSize: 18,
          ),
        ),
        // title_calender_txt_2 - "{month}月{day}日" 12sp #999999
        Text(
          monthDay,
          style: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 12,
          ),
        ),
        // 宜 - ShapeTextView "宜"(radius 100dp, solid #61AEFA) + nongli_info_3 13sp #666666
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF61AEFA),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                '宜',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                fitness,
                style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
              ),
            ),
          ],
        ),
        // 忌 - ShapeTextView "忌"(radius 100dp, solid #696363) + nongli_info_4 13sp #666666
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF696363),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                '忌',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                taboo,
                style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
              ),
            ),
          ],
        ),
        // icon_calender_sun + text_calender_sun - 天气图标和条件(gone)
        // 保真: Android update 回调中设置,但区域 gone 不可见。此处简化不渲染
      ],
    );
  }
}
