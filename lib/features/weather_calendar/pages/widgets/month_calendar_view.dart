// 月历组件 - 对齐 tools_fr_weather.xml 中 haibin CalendarView 默认月视图
// 属性对照: week_background #FFFFFF / week_text_color #404040
//          current_month_text_color #404040 / current_month_lunar_text_color #404040
//          selected_theme_color #3364F8 / selected_text_color #fff / selected_lunar_text_color #fff
//          month_view_show_mode mode_only_current(非本月格空白) / min_year 2004(默认 max 2099)
// 注: riliWeekView 类在安卓源码中不存在 → 运行时回退库默认周栏"日一二三四五六";
//     安卓从未调用 setSchemeDate → "假"角标不出现, 无需节日数据。
// 安卓 fragment 未挂任何日历监听 → 组件自含翻月/选中交互(对齐 CalendarView 默认行为)。
import 'package:flutter/material.dart';
import '../../../../core/utils/lunar_util.dart';

/// 对齐 app:min_year="2004", max 默认 2099
const int _kMinYear = 2004;
const int _kMaxYear = 2099;

/// 周栏高 / 日格高(haibin 默认月视图布局)
const double _kWeekBarHeight = 36;
const double _kCellHeight = 48;

class MonthCalendarView extends StatefulWidget {
  const MonthCalendarView({super.key});

  @override
  State<MonthCalendarView> createState() => _MonthCalendarViewState();
}

class _MonthCalendarViewState extends State<MonthCalendarView> {
  late final PageController _controller;
  DateTime? _selectedDate;

  static int _monthIndex(DateTime m) =>
      (m.year - _kMinYear) * 12 + (m.month - 1);

  static DateTime _monthOf(int index) =>
      DateTime(_kMinYear + index ~/ 12, index % 12 + 1, 1);

  @override
  void initState() {
    super.initState();
    // 初始定位当前月, 默认选中今天(对齐 CalendarView 默认选中当天)
    _controller = PageController(initialPage: _monthIndex(DateTime.now()));
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekBar(),
        SizedBox(
          height: _kCellHeight * 6,
          child: PageView.builder(
            controller: _controller,
            itemCount: (_kMaxYear - _kMinYear + 1) * 12,
            itemBuilder: (context, index) =>
                _MonthGrid(month: _monthOf(index), selectedDate: _selectedDate,
              onSelect: (date) => setState(() => _selectedDate = date)),
          ),
        ),
      ],
    );
  }

  /// 周栏 - haibin 默认中文周起始周日: 日一二三四五六, 12sp #404040 白底
  Widget _buildWeekBar() {
    const labels = ['日', '一', '二', '三', '四', '五', '六'];
    return SizedBox(
      height: _kWeekBarHeight,
      child: Row(
        children: [
          for (final label in labels)
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF404040)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 单月网格 - 6 行 × 7 列, mode_only_current(非本月格空白)
class _MonthGrid extends StatelessWidget {
  final DateTime month;

  /// 当前选中日期(跨月保留, 对齐 CalendarView)
  final DateTime? selectedDate;

  final void Function(DateTime date)? onSelect;

  const _MonthGrid({required this.month, this.selectedDate, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    // 周日=0 起始的前置空位数
    final leading = first.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final today = DateTime.now();

    return Column(
      children: [
        for (var row = 0; row < 6; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(child: _buildCell(
                  leading, row * 7 + col, daysInMonth, today)),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(int leading, int index, int daysInMonth, DateTime today) {
    // mode_only_current: 本月之外的格子不渲染
    if (index < leading || index >= leading + daysInMonth) {
      return const SizedBox(height: _kCellHeight);
    }
    final date =
        DateTime(month.year, month.month, index - leading + 1);
    final isSelected = selectedDate != null &&
        selectedDate!.year == date.year &&
        selectedDate!.month == date.month &&
        selectedDate!.day == date.day;
    final isToday = today.year == date.year &&
        today.month == date.month &&
        today.day == date.day;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelect?.call(date),
      child: Container(
        height: _kCellHeight,
        // 选中: #3364F8 圆形背景 + 日/农历白字(对齐 selected_theme_color + *_text_color #fff)
        decoration: isSelected
            ? const BoxDecoration(
                color: Color(0xFF3364F8), shape: BoxShape.circle)
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                // 今日: #3364F8(haibin 默认 today 文字用主题色); 其余 #404040
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : isToday
                        ? const Color(0xFF3364F8)
                        : const Color(0xFF404040),
              ),
            ),
            Text(
              LunarUtil.lunarLabel(date),
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF404040),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
