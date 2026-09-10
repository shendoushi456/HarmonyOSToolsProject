// QxCalendar 日历页 - 对齐 Android QxCalendarFragment/QxCalendarScreen/QxCalendarComponents
// 迁移自 toolbox_c toolsbox_moduel weather/calendar（Jetpack Compose UI）
// 月历卡（周条/月格切换+雨点标记）+ 我的待办卡 + 历史上的今天卡
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../home/pages/home_shell_page.dart';
import '../models/qx_calendar_models.dart';
import '../viewmodels/qx_calendar_view_model.dart';

/// 对齐 Android QxMainFontScale：标题与下方双卡字号整体缩放 0.82
const double _kQxMainFontScale = 0.82;

/// Compose verticalGradient endY=760px（xxhdpi 3x）≈ 253 逻辑像素处渐变结束
const double _kGradientEnd = 253.0;

class QxCalendarPage extends ConsumerStatefulWidget {
  const QxCalendarPage({super.key});

  @override
  ConsumerState<QxCalendarPage> createState() => _QxCalendarPageState();
}

class _QxCalendarPageState extends ConsumerState<QxCalendarPage>
    with WidgetsBindingObserver {
  /// 对齐 Android QxCalendarFragment.lastHistoryOpenAt 800ms 防抖
  int _lastHistoryOpenAt = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 对齐 Android Fragment.onResume：回到前台时刷新
    if (state == AppLifecycleState.resumed) {
      ref.read(qxCalendarViewModelProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qxCalendarViewModelProvider);

    // 对齐 Android ViewPager 中切回本 Fragment 触发 onResume（日历 Tab 当前为 index 1）
    ref.listen<int>(homeTabIndexProvider, (previous, next) {
      const calendarTabIndex = 1;
      if (previous != calendarTabIndex && next == calendarTabIndex) {
        ref.read(qxCalendarViewModelProvider.notifier).refresh();
      }
    });

    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final whiteStop =
              (_kGradientEnd / constraints.maxHeight).clamp(0.0, 1.0);
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: const [
                        Color(0xFF79C9FA),
                        Color(0xFFEAF7FF),
                        Colors.white,
                      ],
                      stops: [0.0, whiteStop, 1.0],
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: true,
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 128),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 对齐 QxMainFontScale { Text(title) }
                        MediaQuery(
                          data: mq.copyWith(
                            textScaler:
                                const TextScaler.linear(_kQxMainFontScale),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 42, bottom: 28),
                            child: Text(
                              state.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF202124),
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        _MonthCalendarCard(state: state),
                        const SizedBox(height: 28),
                        // 对齐 QxMainFontScale { TodoCard + HistoryTodayCard }
                        MediaQuery(
                          data: mq.copyWith(
                            textScaler:
                                const TextScaler.linear(_kQxMainFontScale),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _TodoCard(onAddTodo: _openTodo),
                              const SizedBox(height: 28),
                              _HistoryTodayCard(
                                events: state.historyEvents,
                                onEventClick: (event) {
                                  _showEventDetail(context, event);
                                },
                                onMoreHistory: () =>
                                    _openHistoryToday(state.selectedDate),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 对齐 Android QxCalendarFragment 跳转 QxTodoActivity，返回后 onResume 刷新
  Future<void> _openTodo() async {
    await context.push(RoutePaths.qxTodo);
    await ref.read(qxCalendarViewModelProvider.notifier).refresh();
  }

  /// 对齐 Android openHistoryToday：800ms 防抖 + 跳转，返回后 onResume 刷新
  Future<void> _openHistoryToday(String selectedDate) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastHistoryOpenAt < 800) return;
    _lastHistoryOpenAt = now;
    await context.push(RoutePaths.qxHistoryToday, extra: selectedDate);
    await ref.read(qxCalendarViewModelProvider.notifier).refresh();
  }

  void _showEventDetail(BuildContext context, QxHistoryEventUi event) {
    showDialog<void>(
      context: context,
      builder: (context) => QxHistoryEventDetailDialog(event: event),
    );
  }
}

/// 月份日历卡（对齐 Android MonthCalendarCard）
class _MonthCalendarCard extends ConsumerWidget {
  final QxCalendarUiState state;

  const _MonthCalendarCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(qxCalendarViewModelProvider.notifier);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头部：月份 + 农历 + 插图
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF70C7FB), Color(0xFF2097FF)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.monthText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.lunarText,
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  AppAssets.qxCalendarMonthHero,
                  width: 68,
                  height: 68,
                ),
              ],
            ),
          ),
          // 上/下月切换行
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MonthNavButton(
                  rotation: 180,
                  onTap: notifier.previousMonth,
                ),
                _MonthNavButton(
                  rotation: 0,
                  onTap: notifier.nextMonth,
                ),
              ],
            ),
          ),
          if (state.expanded)
            _MonthGrid(
              days: state.monthDays,
              onSelectDate: notifier.selectDate,
            )
          else
            _WeekStrip(
              days: state.days,
              onSelectDate: notifier.selectDate,
            ),
          // 展开/收起行
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: notifier.toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.expanded ? '收起' : '展开',
                    style: const TextStyle(
                      color: Color(0xFF70757A),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotatedBox(
                    quarterTurns: state.expanded ? -1 : 1,
                    child: Image.asset(
                      AppAssets.qxCalendarArrow,
                      width: 9,
                      height: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 月份切换按钮（对齐 Android MonthNavButton：44dp 圆形点击区 + 旋转箭头）
class _MonthNavButton extends StatelessWidget {
  final double rotation;
  final VoidCallback onTap;

  const _MonthNavButton({required this.rotation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Transform.rotate(
            angle: rotation * 3.1415926535897932 / 180,
            child: Image.asset(
              AppAssets.qxCalendarArrow,
              width: 9,
              height: 17,
            ),
          ),
        ),
      ),
    );
  }
}

/// 周条视图（对齐 Android WeekStrip）
class _WeekStrip extends StatelessWidget {
  final List<QxCalendarDayUi> days;
  final void Function(String) onSelectDate;

  const _WeekStrip({required this.days, required this.onSelectDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: Column(
                children: [
                  Text(
                    day.weekLabel,
                    style: const TextStyle(
                      color: Color(0xFF8B8F95),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _CalendarDateDotCell(
                    day: day,
                    circleSize: 48,
                    cellHeight: 62,
                    dotCenterY: 58,
                    dotSize: 8,
                    fontSize: 20,
                    lunarFontSize: 10,
                    onSelectDate: onSelectDate,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 月格视图（对齐 Android MonthGrid：周一开头 7 列，非当月留空）
class _MonthGrid extends StatelessWidget {
  final List<QxCalendarDayUi> days;
  final void Function(String) onSelectDate;

  const _MonthGrid({required this.days, required this.onSelectDate});

  @override
  Widget build(BuildContext context) {
    const weekLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    const monthCellHeight = 58.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Column(
        children: [
          Row(
            children: [
              for (final label in weekLabels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8B8F95),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (var weekStart = 0; weekStart < days.length; weekStart += 7)
            Padding(
              padding: EdgeInsets.only(
                  bottom: weekStart + 7 < days.length ? 4 : 0),
              child: Row(
                children: [
                  for (var i = weekStart;
                      i < weekStart + 7 && i < days.length;
                      i++)
                    if (days[i].inCurrentMonth)
                      Expanded(
                        child: _CalendarDateDotCell(
                          day: days[i],
                          circleSize: 38,
                          cellHeight: monthCellHeight,
                          dotCenterY: 51,
                          dotSize: 5,
                          fontSize: 18,
                          lunarFontSize: 8,
                          onSelectDate: onSelectDate,
                        ),
                      )
                    else
                      const Expanded(
                        child: SizedBox(height: monthCellHeight),
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 日期格子（对齐 Android CalendarDateDotCell：选中圆底 + 雨点圆点）
class _CalendarDateDotCell extends StatelessWidget {
  final QxCalendarDayUi day;
  final double circleSize;
  final double cellHeight;
  final double dotCenterY;
  final double dotSize;
  final double fontSize;
  final double lunarFontSize;
  final void Function(String) onSelectDate;

  const _CalendarDateDotCell({
    required this.day,
    required this.circleSize,
    required this.cellHeight,
    required this.dotCenterY,
    required this.dotSize,
    required this.fontSize,
    required this.lunarFontSize,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = day.isoDate.isNotEmpty && day.inCurrentMonth;
    return SizedBox(
      height: cellHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 雨点圆点（对齐 drawBehind：cell 宽度中心、dotCenterY 处）
          if (enabled && day.hasRain)
            Positioned(
              top: dotCenterY - dotSize / 2,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  color: Color(0xFF62BDF7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? () => onSelectDate(day.isoDate) : null,
            child: Container(
              width: circleSize,
              height: circleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    day.selected ? const Color(0xFF62BDF7) : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.day,
                    style: TextStyle(
                      color: day.selected
                          ? Colors.white
                          : const Color(0xFF30343A),
                      fontSize: fontSize,
                      height: 1.05,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (day.lunarDay.isNotEmpty)
                    Text(
                      day.lunarDay,
                      maxLines: 1,
                      style: TextStyle(
                        color: day.selected
                            ? Colors.white.withValues(alpha: 0.72)
                            : const Color(0xFF30343A).withValues(alpha: 0.52),
                        fontSize: lunarFontSize,
                        height: 1.05,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 我的待办事项卡（对齐 Android TodoCard）
class _TodoCard extends StatelessWidget {
  final VoidCallback onAddTodo;

  const _TodoCard({required this.onAddTodo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onAddTodo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFFFDDA8), Color(0xFFFFBF72)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '我的待办事项',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB159),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      '点击添加',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              AppAssets.qxCalendarTodoHero,
              width: 110,
              height: 110,
            ),
          ],
        ),
      ),
    );
  }
}

/// 历史上的今天卡（对齐 Android HistoryTodayCard：背景图 540dp 高 + 白色事件区）
class _HistoryTodayCard extends StatelessWidget {
  final List<QxHistoryEventUi> events;
  final void Function(QxHistoryEventUi) onEventClick;
  final VoidCallback onMoreHistory;

  const _HistoryTodayCard({
    required this.events,
    required this.onEventClick,
    required this.onMoreHistory,
  });

  @override
  Widget build(BuildContext context) {
    final visibleEvents = events.take(3).toList();
    return SizedBox(
      height: 540,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.qxCalendarHistoryBg,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(
            height: 126,
            child: Center(
              child: Text(
                '历史上的今天',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 168,
            bottom: 20,
            left: 30,
            right: 30,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 4, bottom: 6),
                    child: events.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无历史事件',
                              style: TextStyle(
                                color: Color(0xFF7B8086),
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < visibleEvents.length; i++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () =>
                                                onEventClick(visibleEvents[i]),
                                            child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  visibleEvents[i].title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.clip,
                                                  style: const TextStyle(
                                                    color: Color(0xFF202124),
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    height: 24 / 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  visibleEvents[i].year,
                                                  style: const TextStyle(
                                                    color: Color(0xFF7B8086),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (i != visibleEvents.length - 1)
                                        const Divider(
                                          color: Color(0xFFEDEDED),
                                          height: 1,
                                          thickness: 1,
                                        ),
                                    ],
                                  ),
                                  ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onMoreHistory,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '查看更多',
                            style: TextStyle(
                              color: Color(0xFF8B8F95),
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            AppAssets.qxCalendarArrow,
                            width: 9,
                            height: 17,
                          ),
                        ],
                      ),
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

/// 历史事件详情弹窗（对齐 Android HistoryEventDetailDialog）
class QxHistoryEventDetailDialog extends StatelessWidget {
  final QxHistoryEventUi event;

  const QxHistoryEventDetailDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        event.title,
        style: const TextStyle(
          color: Color(0xFF202124),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 420),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (event.year.isNotEmpty) ...[
                Text(
                  event.year,
                  style: const TextStyle(
                    color: Color(0xFF7B8086),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                event.description.isNotEmpty ? event.description : '暂无详情',
                style: const TextStyle(
                  color: Color(0xFF30343A),
                  fontSize: 15,
                  height: 22 / 15,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
