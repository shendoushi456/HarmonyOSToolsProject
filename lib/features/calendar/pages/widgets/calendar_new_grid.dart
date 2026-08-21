// 自绘日历网格 - 对齐 Android haibin CalendarView + riliMonthView
// 周标题(日一二三四五六) + 6×7 日期网格
// 每个 cell: 日期 14sp + 农历 10sp #666666/红色(节日) + 选中圆圈 #337EFF(Bug,不是 layout 的 #73C3EB)
// 天气图标不绘制(还原 Bug: mPlaceholderIcon 初始化被注释为 null)
import 'package:flutter/material.dart';
import '../../../../core/utils/lunar_util.dart';

class CalendarNewGrid extends StatelessWidget {
  /// 显示的月份（该月第一天）
  final DateTime displayMonth;

  /// 当前选中日期
  final DateTime selectedDate;

  /// 选中日期回调 - 对齐 Android setOnCalendarSelectListener
  final void Function(DateTime) onSelectDate;

  const CalendarNewGrid({
    super.key,
    required this.displayMonth,
    required this.selectedDate,
    required this.onSelectDate,
  });

  /// 周标题 - 对齐 Android CalendarView 默认周日开头
  static const _weekHeaders = ['日', '一', '二', '三', '四', '五', '六'];

  @override
  Widget build(BuildContext context) {
    final dates = _generateDates(displayMonth);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Column(
      children: [
        // 周标题行 - 对齐 Android week_background #FFF5F8FC, week_text_color #111
        Container(
          color: const Color(0xFFF5F8FC),
          child: Row(
            children: _weekHeaders.map((w) {
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      w,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // 6×7 日期网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.85, // 每个 cell 略高于宽
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            return _buildDateCell(dates[index], today);
          },
        ),
      ],
    );
  }

  /// 生成 42 个日期（6行7列，周日开头）
  /// 含上月末尾 + 当月全部 + 下月开头
  List<DateTime> _generateDates(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // 周日=0, 周一=1, ..., 周六=6
    final firstWeekday = firstOfMonth.weekday % 7; // DateTime.weekday: Monday=1..Sunday=7，转 Sunday=0
    final startDate = firstOfMonth.subtract(Duration(days: firstWeekday));
    return List.generate(42, (i) => startDate.add(Duration(days: i)));
  }

  /// 单个日期 cell - 对齐 Android riliMonthView.onDrawText
  Widget _buildDateCell(DateTime date, DateTime today) {
    final isSelected = date == selectedDate;
    final isToday = date == today;
    final isCurrentMonth =
        date.year == displayMonth.year && date.month == displayMonth.month;
    final lunarLabel = LunarUtil.lunarLabel(date);
    final isFestival = _isFestivalOrSpecialDay(date);

    // 日期文字颜色 - 对齐 Android current_month_text_color #333333, other_month #e1e1e1
    Color dateColor;
    if (isSelected) {
      dateColor = Colors.white; // selected_text_color #fff
    } else if (!isCurrentMonth) {
      dateColor = const Color(0xFFe1e1e1); // other_month_text_color
    } else {
      dateColor = const Color(0xFF333333); // current_month_text_color
    }

    // 农历文字颜色 - 对齐 Android mLunarTextPaint #666666, mSchemeLunarPaint 红色(节日)
    Color lunarColor;
    if (isSelected) {
      lunarColor = Colors.white; // selected_lunar_text_color #fff
    } else if (isFestival) {
      lunarColor = Colors.red; // 节日农历红色
    } else {
      lunarColor = const Color(0xFF666666); // 普通农历 #666666
    }

    return GestureDetector(
      onTap: () => onSelectDate(date),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 选中圆圈 - 对齐 Android riliMonthView.onDrawSelected
          // Bug 保真: riliMonthView line 57 硬编码 #337EFF(不是 layout 的 #FF73C3EB)
          if (isSelected)
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF337EFF),
                shape: BoxShape.circle,
              ),
            ),
          // 日期 + 农历 - 对齐 Android onDrawText(drawDateText + drawLunarText)
          // 日期垂直位置 mItemHeight*0.25, 农历 mItemHeight*0.50
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 日期文字 14sp - 对齐 Android alignAllTextPaint textSize 14dp
              Text(
                date.day.toString(),
                style: TextStyle(
                  color: dateColor,
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              // 农历文字 10sp - 对齐 Android mLunarTextSize 10dp
              Text(
                lunarLabel,
                style: TextStyle(
                  color: lunarColor,
                  fontSize: 10,
                ),
              ),
              // 天气图标位置(mItemHeight*0.75) - 还原 Bug: 不绘制(mPlaceholderIcon 为 null)
            ],
          ),
        ],
      ),
    );
  }

  /// 节日/特殊日期判断 - 对齐 Android riliMonthView.isFestivalOrSpecialDay
  /// 检查农历文字是否包含特定关键词
  /// 注意: Android 用 calendar.getLunar()(haibin 内置节日表),鸿蒙端用 Lunar.toString()
  /// 简化: 检查农历日名是否包含"初一/十五"或节日关键词
  bool _isFestivalOrSpecialDay(DateTime date) {
    final lunar = Lunar.fromDateTime(date).toString(); // 如"二月初一"
    return lunar.contains('除夕') ||
        lunar.contains('春节') ||
        lunar.contains('元宵') ||
        lunar.contains('端午') ||
        lunar.contains('中秋') ||
        lunar.contains('重阳') ||
        lunar.contains('冬至') ||
        lunar.contains('腊八') ||
        lunar.contains('初一') ||
        lunar.contains('十五');
  }
}
