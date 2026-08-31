// WeatherFragment 月历 - 对齐 tools_fr_weather.xml 的 com.haibin.calendarview.CalendarView
// 自绘纯色版(不用 PNG 背景),色板严格对齐 haibin 属性:
//   week_text_color #727272 / current_month_text_color #404040 / other_month_text_color #e1e1e1
//   selected_theme_color #3364F8(选中圆底) / selected_text_color #fff
//   今天标记"今" #FF6B6B(还原 addMarkedDates 设计意图, 方法虽未被调用但用户确认还原设计)
// 范围 2004-2030, 越界禁用由外部按钮处理。农历用 LunarUtil.lunarLabel。
import 'package:flutter/material.dart';
import '../../../../core/utils/lunar_util.dart';

class WeatherCalendar extends StatelessWidget {
  /// 当前显示的月份(仅取 year + month)
  final DateTime displayMonth;

  /// 选中的日期
  final DateTime selectedDate;

  /// 选中日期回调
  final void Function(DateTime date) onSelectDate;

  const WeatherCalendar({
    super.key,
    required this.displayMonth,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(displayMonth.year, displayMonth.month, 1);
    // Dart weekday: Mon=1..Sun=7, 转为 Mon-first 0-based offset
    final offset = first.weekday - 1;
    final start = first.subtract(Duration(days: offset));
    // haibin CalendarView 默认 6 行
    final dates = List.generate(6 * 7, (i) => start.add(Duration(days: i)));

    return Column(
      children: [
        // 周列头 一~日 #727272
        Row(
          children: const ['一', '二', '三', '四', '五', '六', '日']
              .map((w) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Center(
                        child: Text(
                          w,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF727272),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        // 6 行日期
        for (int r = 0; r < 6; r++)
          Row(
            children: dates
                .skip(r * 7)
                .take(7)
                .map((d) => Expanded(child: _cell(d)))
                .toList(),
          ),
      ],
    );
  }

  Widget _cell(DateTime d) {
    final today = DateTime.now();
    final isToday = d.year == today.year &&
        d.month == today.month &&
        d.day == today.day;
    final isSelected = d.year == selectedDate.year &&
        d.month == selectedDate.month &&
        d.day == selectedDate.day;
    final inMonth =
        d.year == displayMonth.year && d.month == displayMonth.month;

    // 主数字色: 非本月 #e1e1e1; 今天 #FF6B6B; 当月 #404040
    Color numColor;
    if (!inMonth) {
      numColor = const Color(0xFFe1e1e1);
    } else if (isToday) {
      numColor = const Color(0xFFFF6B6B);
    } else {
      numColor = const Color(0xFF404040);
    }

    // 农历/标记文字: 今天显示"今"红; 其他显示农历
    final subLabel = isToday ? '今' : LunarUtil.lunarLabel(d);
    final Color subColor = isToday
        ? const Color(0xFFFF6B6B)
        : (inMonth ? const Color(0xFF404040) : const Color(0xFFe1e1e1));

    return GestureDetector(
      onTap: () => onSelectDate(d),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 46,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 选中态: 圆底 #3364F8 + 白字
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: isSelected
                  ? const BoxDecoration(
                      color: Color(0xFF3364F8),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                '${d.day}',
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? Colors.white
                      : (isToday
                          ? const Color(0xFFFF6B6B)
                          : numColor),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: TextStyle(fontSize: 9, color: subColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
