// 深色日历网格 - 对齐 Android CalendarScreenWithDirectInflation（行 502-553）+ riliMonthView + custom_calendar_layout.xml
// State: _displayMonth/_selectedDate/_currentYearMonth
// Column:
//   Text(_currentYearMonth, 16sp 白 w500, padding b15 l20 t20)
//   Container 1dp 高占位分割线（保真"带圆角的文本"Bug）
//   Container 周栏（bg 0xFF333D60 + 7 个 Expanded(Center(Text 周文字, 12sp 白)))
//   GridView.builder(shrinkWrap, NeverScrollable, 7列, 42项, _buildDateCell)
//   外包 GestureDetector(onHorizontalDragEnd 左滑下月/右滑上月)
// 保真：
//   - 选中圆圈 #FFA572（XML selected_theme_color，不是旧 calendar_new_grid 的 #337EFF 错误保真）
//   - 文字全白（current_month/other_month/current_day/selected 全 white）
//   - 周栏 #333D60 + 周文字白
//   - 月份格式不一致 Bug：_getCurrentYearMonth 补零"yyyy年MM月"，_formatYearMonth 不补零"${y}年${m}月"
//   - min_year=2004（切换校验）
import 'package:flutter/material.dart';
import '../../../../core/utils/lunar_util.dart';

class CalendarDarkGrid extends StatefulWidget {
  const CalendarDarkGrid({super.key});

  @override
  State<CalendarDarkGrid> createState() => _CalendarDarkGridState();
}

class _CalendarDarkGridState extends State<CalendarDarkGrid> {
  /// 当前显示月份（该月第一天）- 对齐 Android haibin CalendarView 当前月份
  DateTime _displayMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  /// 当前选中日期 - 对齐 Android setOnCalendarSelectListener
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// 年月文本 - 对齐 Android currentYearMonth state
  /// 保真：初始用 _getCurrentYearMonth() 补零 "yyyy年MM月"
  late String _currentYearMonth = _getCurrentYearMonth();

  /// 周标题 - 对齐 Android CalendarView 默认周日开头
  static const _weekHeaders = ['日', '一', '二', '三', '四', '五', '六'];

  /// 获取当前年月 - 对齐 Android getCurrentYearMonth()
  /// 保真：用 "yyyy年MM月" 格式，month 补零（对齐 DateTimeFormatter.ofPattern("yyyy年MM月")）
  String _getCurrentYearMonth() {
    final now = DateTime.now();
    return '${now.year}年${now.month.toString().padLeft(2, '0')}月';
  }

  /// 格式化年月 - 对齐 Android formatYearMonth(year, month)
  /// 保真 Bug：用 "${year}年${month}月" 格式，month 不补零（与 _getCurrentYearMonth 格式不一致，原项目 Bug）
  String _formatYearMonth(int year, int month) {
    return '$year年$month月';
  }

  /// 上一月 - 对齐 Android haibin 滑动切换月份
  void _previousMonth() {
    // 保真：min_year=2004，2004年1月不能再往前
    if (_displayMonth.year == 2004 && _displayMonth.month == 1) return;
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
      _currentYearMonth = _formatYearMonth(_displayMonth.year, _displayMonth.month);
    });
  }

  /// 下一月 - 对齐 Android haibin 滑动切换月份
  void _nextMonth() {
    // haibin 默认 max_year=2099，此处不强制限制上限
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
      _currentYearMonth = _formatYearMonth(_displayMonth.year, _displayMonth.month);
    });
  }

  /// 选中日期 - 对齐 Android setOnCalendarSelectListener
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      // 跨月选中：若选中日期不在当前显示月，同步切月 - 对齐 haibin 行为
      if (date.year != _displayMonth.year || date.month != _displayMonth.month) {
        _displayMonth = DateTime(date.year, date.month, 1);
        _currentYearMonth = _formatYearMonth(date.year, date.month);
      }
    });
  }

  /// 生成 42 个日期（6行7列，周日开头）
  /// 含上月末尾 + 当月全部 + 下月开头 - 对齐 haibin 6×7 网格
  List<DateTime> _generateDates(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // 周日=0, 周一=1, ..., 周六=6
    final firstWeekday = firstOfMonth.weekday % 7; // DateTime.weekday: Monday=1..Sunday=7，转 Sunday=0
    final startDate = firstOfMonth.subtract(Duration(days: firstWeekday));
    return List.generate(42, (i) => startDate.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final dates = _generateDates(_displayMonth);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return GestureDetector(
      // 对齐 Android haibin 滑动切换月份
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -100) {
          // 向左滑 → 下一月
          _nextMonth();
        } else if (velocity > 100) {
          // 向右滑 → 上一月
          _previousMonth();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // 年月文本 - 对齐 Android 行 511-517
          // Text(currentYearMonth, 16sp White Medium, padding bottom15 start20 top20)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 20, top: 20),
              child: Text(
                _currentYearMonth,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // 占位分割线 - 对齐 Android 行 519-529
          // 保真 Bug: 安卓用 Text("带圆角的文本") 设 height 1dp + LightGray + RoundedCorner 16 当分割线
          // 鸿蒙用 Container 1dp 高模拟（Text 文字无法撑 1dp 高）
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            decoration: BoxDecoration(
              color: const Color(0xFFBDBDBD), // LightGray
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // 周栏 - 对齐 XML week_background #333D60 + week_text_color white
          Container(
            color: const Color(0xFF333D60),
            child: Row(
              children: _weekHeaders
                  .map((w) => Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              w,
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // 6×7 日期网格 - 对齐 riliMonthView
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemCount: 42,
            itemBuilder: (context, index) => _buildDateCell(dates[index], today),
          ),
        ],
      ),
    );
  }

  /// 单个日期 cell - 对齐 Android riliMonthView.onDrawText（行 54-75）
  Widget _buildDateCell(DateTime date, DateTime today) {
    final isSelected = date == _selectedDate;
    final isToday = date == today;
    final lunarLabel = LunarUtil.lunarLabel(date);

    // 文字颜色 - 对齐 XML: current_month/other_month/current_day/selected 全 white
    // 保真：安卓所有文字色都是 white（current_month_text_color=white, other_month_text_color=#ffffff, current_day_text_color=white, selected_text_color=#fff）
    const dateColor = Color(0xFFFFFFFF);
    const lunarColor = Color(0xFFFFFFFF);

    return GestureDetector(
      onTap: () => _selectDate(date),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 选中圆圈 - 对齐 Android riliMonthView.onDrawSelected + XML selected_theme_color #FFA572
          // 注意：不是旧 calendar_new_grid 的 #337EFF（那是错误保真，实际 XML 是 #FFA572）
          if (isSelected)
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFFFA572),
                shape: BoxShape.circle,
              ),
            ),
          // 日期 + 农历 - 对齐 Android onDrawText(drawDateText + drawLunarText)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 日期文字 14sp - 对齐 Android alignAllTextPaint textSize 14dp
              // 今日加粗 - 对齐 Android mCurDayTextPaint
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
                style: const TextStyle(
                  color: lunarColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
