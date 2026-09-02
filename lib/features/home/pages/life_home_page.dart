// toolbox_c LifeFragment 的 Flutter 迁移页面。
// 只负责该马甲 UI 与本地日历选择；节气/历史功能复用已有独立路由页面。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/lunar_util.dart';
import '../../../router/route_names.dart';

class LifeHomePage extends StatefulWidget {
  const LifeHomePage({super.key});

  @override
  State<LifeHomePage> createState() => _LifeHomePageState();
}

class _LifeHomePageState extends State<LifeHomePage> {
  late DateTime _displayMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D0E),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  '日历',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 30 / 20,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LifeCalendar(
                      displayMonth: _displayMonth,
                      selectedDate: _selectedDate,
                      onPreviousMonth: () => _changeMonth(-1),
                      onNextMonth: () => _changeMonth(1),
                      onSelectDate: _selectDate,
                    ),
                    const SizedBox(height: 30),
                    _LifeInfoSection(
                      icon: AppAssets.toolboxLifeSolarIcon,
                      iconSize: 20,
                      title: '节气信息',
                      cardBackground: AppAssets.toolboxLifeSolarCard,
                      cardAspectRatio: 1005 / 348,
                      description:
                          '二十四节气是中华民族的智慧结晶，反映了季节、气候、物候的变化规律。每个节气都蕴含着丰富的农耕文化和生活智慧，指导着人们顺应自然、合理安排生产生活。了解节气，传承中华优秀传统文化。',
                      textColor: const Color(0xFFCDCDCD),
                      verticalPadding: 16,
                      onTap: () => context.push(RoutePaths.solarTerms),
                    ),
                    const SizedBox(height: 30),
                    _LifeInfoSection(
                      icon: AppAssets.toolboxLifeHistoryIcon,
                      iconSize: 22,
                      title: '历史上的今天',
                      cardBackground: AppAssets.toolboxLifeHistoryCard,
                      cardAspectRatio: 1005 / 276,
                      description:
                          '历史上的今天记录着人类文明进程中的重要时刻。每一天都承载着独特的历史记忆，包括科技突破、政治变革、文化成就等值得铭记的事件。',
                      textColor: const Color(0xFF717171),
                      verticalPadding: 18,
                      onTap: () => context.push(RoutePaths.historyToday),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayMonth =
          DateTime(_displayMonth.year, _displayMonth.month + offset);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      if (date.year != _displayMonth.year ||
          date.month != _displayMonth.month) {
        _displayMonth = DateTime(date.year, date.month);
      }
    });
  }
}

class _LifeCalendar extends StatelessWidget {
  static const _weekdays = ['日', '一', '二', '三', '四', '五', '六'];

  final DateTime displayMonth;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  const _LifeCalendar({
    required this.displayMonth,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final dates = _monthDates(displayMonth);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return GestureDetector(
      // 源 CalendarView 的月份切换由内部滑动完成，标题和箭头在 XML 中为 gone。
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) {
          onNextMonth();
        } else if (velocity > 0) {
          onPreviousMonth();
        }
      },
      child: Column(
        children: [
          Row(
            children: _weekdays
                .map((label) => Expanded(
                      child: Center(
                        child: Text(label,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: .78,
            ),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isCurrentMonth = date.month == displayMonth.month;
              final isSelected = _sameDate(date, selectedDate);
              final isToday = _sameDate(date, today);
              return GestureDetector(
                onTap: () => onSelectDate(date),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isSelected)
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFF337EFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isCurrentMonth
                                    ? Colors.white
                                    : const Color(0xFFE1E1E1),
                            fontSize: 14,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LunarUtil.lunarLabel(date),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isCurrentMonth
                                    ? const Color(0xFFCDCDCD)
                                    : const Color(0xFF777777),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<DateTime> _monthDates(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final leadingDays = first.weekday % 7;
    final start = first.subtract(Duration(days: leadingDays));
    return List.generate(42, (index) => start.add(Duration(days: index)));
  }

  bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _LifeInfoSection extends StatelessWidget {
  final String icon;
  final double iconSize;
  final String title;
  final String cardBackground;
  final double cardAspectRatio;
  final String description;
  final Color textColor;
  final double verticalPadding;
  final VoidCallback onTap;

  const _LifeInfoSection({
    required this.icon,
    required this.iconSize,
    required this.title,
    required this.cardBackground,
    required this.cardAspectRatio,
    required this.description,
    required this.textColor,
    required this.verticalPadding,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(icon, width: iconSize, height: iconSize),
              const SizedBox(width: 4),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 25 / 18)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: cardAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(cardBackground, fit: BoxFit.fill),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: verticalPadding),
                    child: Center(
                      child: Text(description,
                          style: TextStyle(
                              color: textColor, fontSize: 12, height: 17 / 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
