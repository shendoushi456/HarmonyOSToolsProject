// TodoClockinFragment Flutter 迁移版 - 待办打卡页(替换原绘画页 Tab[1])
// 对齐 Android toolsbox_moduel/toolsbox/ui/todoclockin/TodoClockinFragment.kt
// 按需求移除顶部天气渐变头部；待办/打卡双 Tab，数据层复用自建仓储
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../repositories/clock_in_repository.dart';
import '../repositories/todo_repository.dart';
import '../services/reminder_scheduler.dart';
import '../services/reminder_launch_coordinator.dart';
import '../utils/clockin_date_utils.dart';
import '../utils/clockin_toast.dart';
import '../models/todo_clockin_entities.dart';
import '../widgets/todo_edit_dialog.dart';
import 'reminder_launch_host.dart';
import 'add_clock_in_page.dart';

// 颜色常量(对齐 Fragment 顶部定义)
const _kPrimaryColor = Color(0xFFFC4956);
const _kUnselectedCalBg = Color(0xFFFFF0F1);
const _kHeaderDateBg = Color(0x99FFFFFF);
const _kTabBg = Color(0xFFF3F3F3);
const _kTextMain = Color(0xFF1E1E1E);
const _kTextTertiary = Color(0xFF656565);
const _kTextHint = Color(0xFFABABAB);
const _kTextGray = Color(0xFF838383);
const _kColorExpired = Color(0xFFD11A1A);
const _kArrowColor = Color(0xFFA2A2A2);

/// 习惯展示项(对齐 HabitDisplayItem)
class HabitDisplayItem {
  const HabitDisplayItem({
    required this.habit,
    required this.timePoint,
    required this.isClocked,
  });

  final HabitEntity habit;
  final String timePoint;
  final bool isClocked;
}

class TodoClockinPage extends ConsumerStatefulWidget {
  const TodoClockinPage({super.key});

  @override
  ConsumerState<TodoClockinPage> createState() => _TodoClockinPageState();
}

class _TodoClockinPageState extends ConsumerState<TodoClockinPage> {
  static const int _tabTodo = 0;
  static const int _tabClockIn = 1;

  final TodoRepository _todoRepository = TodoRepository();
  final ClockInRepository _clockInRepository = ClockInRepository();
  static const OhosReminderScheduler _scheduler = OhosReminderScheduler();

  int _currentTab = _tabTodo;
  List<TodoEntity> _todos = [];
  List<HabitDisplayItem> _unclockedHabits = [];
  List<HabitDisplayItem> _clockedHabits = [];
  DateTime _selectedDate = DateTime.now();
  bool _isCompletedTodoExpanded = true;
  bool _isClockedHabitExpanded = true;
  ReminderLaunch? _lastHandledLaunch;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _todoRepository.ensureInitialized();
    await _collectTodos();
    if (_currentTab == _tabClockIn) {
      await _collectHabits();
    }
    // 已保存的历史数据在通知关闭时仍可正常进入应用；同步失败不应阻塞页面。
    try {
      await _scheduler.restore(
        todos: _todos,
        habits: await _clockInRepository.getAllHabits(),
      );
    } catch (_) {}
  }

  // ============================ 数据加载 ============================

  /// 收集待办数据(对齐 collectTodos + TodoTabContent 过滤)
  Future<void> _collectTodos() async {
    final todos = await _todoRepository.getAllTodos();
    if (mounted) setState(() => _todos = todos);
  }

  /// 按选中日期收集习惯数据并分组(对齐 collectHabits + buildHabitDisplayItems)
  Future<void> _collectHabits() async {
    final dateStr = formatYMD(_selectedDate);
    final allHabits = await _clockInRepository.getAllHabits();
    final clockedMap = <int, List<String>>{};
    for (final habit in allHabits) {
      clockedMap[habit.id] =
          await _clockInRepository.getClockedTimePoints(habit.id, dateStr);
    }
    final valid = allHabits
        .where((habit) => _isHabitValidForDate(habit, dateStr))
        .toList();
    final groups = _buildHabitDisplayItems(valid, clockedMap);
    if (mounted) {
      setState(() {
        _unclockedHabits = groups[0];
        _clockedHabits = groups[1];
      });
    }
  }

  /// 构建习惯展示项(未打卡 / 已打卡两组)
  List<List<HabitDisplayItem>> _buildHabitDisplayItems(
    List<HabitEntity> habits,
    Map<int, List<String>> clockedMap,
  ) {
    final unclocked = <HabitDisplayItem>[];
    final clocked = <HabitDisplayItem>[];
    for (final habit in habits) {
      final clockedPoints = clockedMap[habit.id] ?? <String>[];
      final timePoints = _parseTimePoints(habit.clockInTimes);
      if (timePoints.isEmpty) {
        final item = HabitDisplayItem(
            habit: habit,
            timePoint: '',
            isClocked: clockedPoints.isNotEmpty);
        if (item.isClocked) {
          clocked.add(item);
        } else {
          unclocked.add(item);
        }
      } else {
        for (final tp in timePoints) {
          final item = HabitDisplayItem(
              habit: habit,
              timePoint: tp,
              isClocked: clockedPoints.contains(tp));
          if (item.isClocked) {
            clocked.add(item);
          } else {
            unclocked.add(item);
          }
        }
      }
    }
    unclocked.sort((a, b) => a.timePoint.compareTo(b.timePoint));
    clocked.sort((a, b) => b.habit.createdAt.compareTo(a.habit.createdAt));
    return [unclocked, clocked];
  }

  /// 解析打卡时间点(逗号分隔，去空，排序)
  List<String> _parseTimePoints(String? clockInTimes) {
    if (clockInTimes == null || clockInTimes.isEmpty) return [];
    return clockInTimes
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList()
      ..sort();
  }

  /// 检查习惯在指定日期是否有效(对齐 isHabitValidForDate)
  bool _isHabitValidForDate(HabitEntity habit, String dateString) {
    if (dateString.compareTo(habit.startDate) < 0) return false;
    final endDate = habit.endDate;
    if (endDate != null && dateString.compareTo(endDate) > 0) return false;
    switch (habit.scheduleType) {
      case '每天':
        return true;
      case '工作日':
      case '周一至周五':
        return _isWeekday(dateString);
      case '周末':
      case '周六至周日':
        return _isWeekend(dateString);
      case '每周特定日期':
        return _isSelectedWeekDay(habit, dateString);
      default:
        return true;
    }
  }

  bool _isWeekday(String dateString) {
    final date = parseYMD(dateString);
    if (date == null) return false;
    return date.weekday >= DateTime.monday &&
        date.weekday <= DateTime.friday;
  }

  bool _isWeekend(String dateString) {
    final date = parseYMD(dateString);
    if (date == null) return false;
    return date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
  }

  bool _isSelectedWeekDay(HabitEntity habit, String dateString) {
    final selected = habit.selectedWeekDays;
    if (selected == null || selected.isEmpty) return false;
    final date = parseYMD(dateString);
    if (date == null) return false;
    const dayMap = {
      DateTime.monday: '一',
      DateTime.tuesday: '二',
      DateTime.wednesday: '三',
      DateTime.thursday: '四',
      DateTime.friday: '五',
      DateTime.saturday: '六',
      DateTime.sunday: '日',
    };
    final chineseDay = dayMap[date.weekday];
    if (chineseDay == null) return false;
    return selected.contains(chineseDay);
  }

  /// 格式化待办时间显示文本(对齐 formatTodoTime)
  String _formatTodoTime(TodoEntity todo) {
    if (todo.reminderTime.isEmpty) return '';
    String repeatText;
    switch (todo.repeatType) {
      case 1:
        repeatText = '每天';
        break;
      case 2:
        repeatText = '周一至周五';
        break;
      case 3:
        repeatText = '周六至周日';
        break;
      default:
        repeatText = '不重复';
    }
    if (todo.status == TodoEntity.statusExpired) {
      return '${todo.reminderTime}  已过期';
    }
    return '${todo.reminderTime}  $repeatText';
  }

  // ============================ 业务操作 ============================

  /// 底部添加入口(对齐 showAddToast)
  Future<void> _onAddEntry() async {
    if (_currentTab == _tabTodo) {
      final result = await showTodoEditDialog(context);
      if (result == true) await _collectTodos();
    } else {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const AddClockInPage()));
      // 从添加习惯页返回后刷新打卡数据
      await _collectHabits();
    }
  }

  /// 勾选圆圈点击后取消/重排系统提醒(对齐提交 04d34a5 的 toggle 逻辑)
  Future<void> _syncReminderAfterToggle(
      TodoEntity todo, String newStatus) async {
    try {
      if (newStatus == TodoEntity.statusCompleted) {
        await _scheduler.cancelTodo(todo.id);
      } else if (newStatus == TodoEntity.statusPending &&
          todo.reminderTime.isNotEmpty) {
        await _scheduler
            .scheduleTodo(todo.copyWith(status: newStatus));
      } else if (todo.reminderTime.isNotEmpty) {
        await _scheduler.cancelTodo(todo.id);
      }
    } catch (_) {
      // 状态已更新，提醒同步失败不阻塞列表刷新。
    }
  }

  /// 切换待办完成状态(对齐 toggleTodoComplete)
  Future<void> _toggleTodoComplete(TodoEntity todo) async {
    String newStatus;
    if (todo.status == TodoEntity.statusCompleted) {
      final parsed = parseReminderTime(todo.reminderTime);
      final isExpired =
          parsed != null ? isDateTimeExpired(parsed) : false;
      newStatus = isExpired ? TodoEntity.statusExpired : TodoEntity.statusPending;
    } else {
      newStatus = TodoEntity.statusCompleted;
    }
    final success =
        await _todoRepository.updateTodoStatus(todo.id, newStatus);
    if (!mounted) return;
    if (success) {
      showClockinToast(
          context,
          newStatus == TodoEntity.statusCompleted
              ? '标记为完成'
              : '取消完成');
      await _syncReminderAfterToggle(todo, newStatus);
    } else {
      showClockinToast(context, '操作失败');
    }
    await _collectTodos();
  }

  /// 打卡习惯(对齐 clockInHabit)
  Future<void> _clockInHabit(HabitEntity habit, String timePoint) async {
    final selectedDateStr = formatYMD(_selectedDate);

    final alreadyClocked = await _clockInRepository.isTimePointClocked(
        habit.id, selectedDateStr, timePoint);
    if (alreadyClocked) {
      if (mounted) showClockinToast(context, '该时间点已经打卡过了');
      return;
    }

    if (selectedDateStr.compareTo(habit.startDate) < 0) {
      if (mounted) showClockinToast(context, '习惯还未开始');
      return;
    }

    final endDate = habit.endDate;
    if (endDate != null && selectedDateStr.compareTo(endDate) > 0) {
      if (mounted) showClockinToast(context, '习惯已结束');
      return;
    }

    final success =
        await _clockInRepository.clockIn(habit.id, selectedDateStr, timePoint);
    if (!mounted) return;
    if (success) {
      showClockinToast(context, '打卡成功！时间：$timePoint');
    } else {
      showClockinToast(context, '打卡失败');
    }
    await _collectHabits();
  }

  // ============================ UI ============================

  @override
  Widget build(BuildContext context) {
    // 从系统通知点击进入时，按提醒类型切换到对应 Tab
    final launch = ref.watch(latestReminderLaunchProvider);
    if (launch != null && !identical(launch, _lastHandledLaunch)) {
      _lastHandledLaunch = launch;
      final tab =
          launch.reminderType == 'habit' ? _tabClockIn : _tabTodo;
      if (_currentTab != tab) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _currentTab != tab) {
            setState(() => _currentTab = tab);
          }
        });
      }
    }
    return Scaffold(
      backgroundColor: AppColors.homeBg,
      body: SafeArea(
        bottom: false,
        child: _currentTab == _tabTodo
            ? _buildTodoTabContent()
            : _buildClockInTabContent(),
      ),
    );
  }

  /// 待办 tab 内容(对齐 TodoTabContent)
  Widget _buildTodoTabContent() {
    final pending = _todos
        .where((e) =>
            e.status == TodoEntity.statusPending ||
            e.status == TodoEntity.statusExpired)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final completed = _todos
        .where((e) => e.status == TodoEntity.statusCompleted)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      children: [
        _buildTabSelector(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            children: [
              if (pending.isEmpty && completed.isEmpty)
                _buildEmptyTip('暂无待办事项'),
              for (final todo in pending)
                _buildTodoItem(todo, isCompleted: false),
              if (completed.isNotEmpty) ...[
                _buildGroupHeader(
                  title: '已完成 (${completed.length})',
                  isExpanded: _isCompletedTodoExpanded,
                  onToggle: () => setState(
                      () => _isCompletedTodoExpanded =
                          !_isCompletedTodoExpanded),
                ),
                if (_isCompletedTodoExpanded)
                  for (final todo in completed)
                    _buildTodoItem(todo, isCompleted: true),
              ],
            ],
          ),
        ),
        _buildAddEntryText('添加待办'),
      ],
    );
  }

  /// 打卡 tab 内容(对齐 ClockInTabContent)：日期框 + 一周日历 + Tab + 习惯列表
  Widget _buildClockInTabContent() {
    return Column(
      children: [
        _buildDateAndWeekCalendar(),
        _buildTabSelector(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            children: [
              if (_unclockedHabits.isEmpty && _clockedHabits.isEmpty)
                _buildEmptyTip('今日无打卡'),
              for (final item in _unclockedHabits)
                _buildHabitItem(item, isClocked: false),
              if (_clockedHabits.isNotEmpty) ...[
                _buildGroupHeader(
                  title: '已完成 (${_clockedHabits.length})',
                  isExpanded: _isClockedHabitExpanded,
                  onToggle: () => setState(
                      () => _isClockedHabitExpanded =
                          !_isClockedHabitExpanded),
                ),
                if (_isClockedHabitExpanded)
                  for (final item in _clockedHabits)
                    _buildHabitItem(item, isClocked: true),
              ],
            ],
          ),
        ),
        _buildAddEntryText('添加打卡'),
      ],
    );
  }

  /// 日期框 + 一周七日条(对齐 DateAndWeekCalendar)
  Widget _buildDateAndWeekCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // 日期显示框(无点击)
          Container(
            height: 38,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: _kHeaderDateBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_selectedDate.year}年${_selectedDate.month}月',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _kTextMain,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _buildWeekBar(),
        ],
      ),
    );
  }

  /// 一周七日横排条(对齐 WeekBar：周一起始，周一为 previousOrSame)
  Widget _buildWeekBar() {
    final monday =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays =
        List.generate(7, (i) => monday.add(Duration(days: i)));
    const labels = ['一', '二', '三', '四', '五', '六', '日'];

    return Row(
      children: [
        for (var i = 0; i < weekDays.length; i++) ...[
          if (i > 0) const SizedBox(width: 7),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _selectedDate = weekDays[i]);
                _collectHabits();
              },
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: weekDays[i] == _selectedDate
                      ? _kPrimaryColor
                      : _kUnselectedCalBg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 12,
                        color: weekDays[i] == _selectedDate
                            ? Colors.white
                            : _kPrimaryColor,
                      ),
                    ),
                    Text(
                      '${weekDays[i].day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: weekDays[i] == _selectedDate
                            ? Colors.white
                            : _kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 待办 / 打卡 切换容器(对齐 TabSelector)
  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          width: 260,
          height: 36,
          decoration: BoxDecoration(
            color: _kTabBg,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              // 选中段背景
              Positioned(
                left: _currentTab == _tabTodo ? 0 : 130,
                top: 0,
                bottom: 0,
                width: 130,
                child: Container(
                  decoration: BoxDecoration(
                    color: _kPrimaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildTabItem('待办', _tabTodo),
                  _buildTabItem('打卡', _tabClockIn),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int tab) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_currentTab == tab) return;
          setState(() => _currentTab = tab);
          if (tab == _tabClockIn) _collectHabits();
        },
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _currentTab == tab ? Colors.white : _kTextTertiary,
            ),
          ),
        ),
      ),
    );
  }

  /// 待办列表项(对齐 TodoItem)
  Widget _buildTodoItem(TodoEntity todo, {required bool isCompleted}) {
    final textColor = isCompleted
        ? _kTextHint
        : todo.status == TodoEntity.statusExpired
            ? _kColorExpired
            : _kTextMain;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (todo.status == TodoEntity.statusCompleted) {
          if (mounted) showClockinToast(context, '已完成的待办事项不能编辑');
          return;
        }
        final result = await showTodoEditDialog(context, todo: todo);
        if (result == true) await _collectTodos();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(minHeight: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCheckCircle(
              checked: isCompleted,
              onTap: () => _toggleTodoComplete(todo),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (todo.reminderTime.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTodoTime(todo),
                      style: TextStyle(
                        fontSize: 10,
                        color: isCompleted ? _kTextHint : _kTextGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 习惯列表项(对齐 HabitItem)
  Widget _buildHabitItem(HabitDisplayItem item, {required bool isClocked}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 习惯详情预留(对齐 showHabitDetails 空实现)
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(minHeight: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCheckCircle(
              checked: isClocked,
              onTap: () => _clockInHabit(item.habit, item.timePoint),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.habit.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: isClocked ? _kTextHint : _kTextMain,
                      decoration: isClocked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (item.timePoint.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.timePoint,
                      style: TextStyle(
                        fontSize: 10,
                        color: isClocked ? _kTextHint : _kTextGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 勾选圆圈(对齐 CheckCircle)：未选中边框圆，选中填充圆 + 白勾
  Widget _buildCheckCircle(
      {required bool checked, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 10,
        height: 10,
        child: checked
            ? Container(
                decoration: const BoxDecoration(
                  color: _kPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    size: 8, color: Colors.white),
              )
            : Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 0.7, color: _kTextMain),
                ),
              ),
      ),
    );
  }

  /// 分组标题"已完成 (n)"(对齐 GroupHeader，可展开/收起)
  Widget _buildGroupHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 14, color: _kTextMain)),
            const Spacer(),
            Text(isExpanded ? '▾' : '▸',
                style: const TextStyle(
                    fontSize: 14, color: _kArrowColor)),
          ],
        ),
      ),
    );
  }

  /// 底部添加入口文字(对齐 AddEntryText)
  Widget _buildAddEntryText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onAddEntry,
          child: Text(
            text,
            style:
                const TextStyle(fontSize: 16, color: _kPrimaryColor),
          ),
        ),
      ),
    );
  }

  /// 空态提示(对齐 EmptyTip)
  Widget _buildEmptyTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Text(text,
            style:
                const TextStyle(fontSize: 16, color: _kTextTertiary)),
      ),
    );
  }
}
