import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../weather/models/city_bean.dart';
import '../../weather/repositories/city_repository.dart';
import '../../weather/viewmodels/weather_view_model.dart';
import '../models/todo_models.dart';
import '../viewmodels/todo_clockin_state.dart';
import '../viewmodels/todo_clockin_view_model.dart';

/// 待办打卡首页 UI。
///
/// 对齐 Android TodoClockinFragment 当前激活的 Nxtx 风格：
/// 顶部天气栏、每日一句、待办/打卡 Tab、横向日历、卡片列表。
/// 业务逻辑全部下沉到 [TodoClockInViewModel]，本文件只负责展示与事件收集。
class TodoClockInPage extends ConsumerStatefulWidget {
  const TodoClockInPage({super.key});

  @override
  ConsumerState<TodoClockInPage> createState() => _TodoClockInPageState();
}

class _TodoClockInPageState extends ConsumerState<TodoClockInPage>
    with WidgetsBindingObserver {
  final _cityRepository = CityRepository();
  bool _cityLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCityAndWeather();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 对齐 Android onResume：回到前台时刷新天气数据。
    if (state == AppLifecycleState.resumed) {
      _loadCityAndWeather();
    }
  }

  Future<void> _loadCityAndWeather() async {
    final cities = await _cityRepository.loadCities();
    final city = cities.isNotEmpty ? cities.first : CityBean.defaultCity();
    if (!mounted) return;
    setState(() => _cityLoading = false);
    await ref.read(weatherViewModelProvider.notifier).loadData(city);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todoClockInViewModelProvider);
    final viewModel = ref.read(todoClockInViewModelProvider.notifier);
    final weatherState = ref.watch(weatherViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFD8EFFF),
      body: SafeArea(
        child: state.loading || _cityLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    _NxtxHomeTitle(
                      cityName: weatherState.cityName,
                      tempMin: weatherState.today?.tempMin ?? '--',
                      tempMax: weatherState.today?.tempMax ?? '--',
                      weatherText: weatherState.today?.textDay ?? '',
                      onCityTap: () => _openCitySelect(context),
                      onWeatherTap: () => _loadCityAndWeather(),
                    ),
                    const SizedBox(height: 12),
                    const _NxtxDailyQuote(),
                    const SizedBox(height: 12),
                    _NxtxModeTabs(
                      tab: state.tab,
                      onChanged: viewModel.selectTab,
                    ),
                    if (state.tab == TodoClockInTab.clockIn)
                      _NxtxHabitLazyCalendar(
                        selectedDate: state.selectedDate,
                        onSelect: viewModel.selectDate,
                      ),
                    _NxtxHomeContent(
                      state: state,
                      viewModel: viewModel,
                      onAdd: () => _showAddDialog(context, state.tab),
                      onEditTodo: (todo) => _showTodoEditor(context, todo),
                      onDeleteTodo: (todo) => _confirmDeleteTodo(context, todo),
                      onCompleteTodo: viewModel.completeTodo,
                      onClockIn: (entry) =>
                          viewModel.clockIn(entry.habit, entry.time),
                      onDeleteHabit: (habit) =>
                          _confirmDeleteHabit(context, habit),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _openCitySelect(BuildContext context) async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed == true && mounted) {
      await _loadCityAndWeather();
    }
  }

  void _showAddDialog(BuildContext context, TodoClockInTab tab) {
    if (tab == TodoClockInTab.todo) {
      _showTodoEditor(context, null);
    } else {
      _showHabitEditor(context);
    }
  }

  Future<void> _showTodoEditor(BuildContext context, TodoItem? original) async {
    final result = await showDialog<_TodoFormResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _TodoEditorDialog(original: original),
    );
    if (result == null || !mounted) return;
    final viewModel = ref.read(todoClockInViewModelProvider.notifier);
    await viewModel.saveTodo(
      content: result.content,
      reminderAt: result.reminderAt,
      repeatType: result.repeatType,
      original: original,
    );
    // 对齐 Android：新建待办后定位到它所属日期，使列表立即显示该条记录。
    if (original == null && result.reminderAt != null && mounted) {
      viewModel.selectDate(result.reminderAt!);
    }
  }

  Future<void> _showHabitEditor(BuildContext context) async {
    final result = await showDialog<_HabitFormResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _HabitEditorDialog(),
    );
    if (result == null || !mounted) return;
    await ref.read(todoClockInViewModelProvider.notifier).addHabit(
          name: result.name,
          scheduleType: result.scheduleType,
          clockInTimes: result.times,
          startDate: result.startDate,
          endDate: result.endDate,
          selectedWeekdays: result.selectedWeekdays,
        );
  }

  Future<void> _confirmDeleteTodo(BuildContext context, TodoItem item) async {
    final accepted =
        await _confirm(context, '删除待办', '确定要删除待办 "${item.content}" 吗？');
    if (accepted && mounted) {
      await ref.read(todoClockInViewModelProvider.notifier).deleteTodo(item);
    }
  }

  Future<void> _confirmDeleteHabit(
      BuildContext context, HabitItem habit) async {
    final accepted =
        await _confirm(context, '删除习惯', '确定要删除习惯 "${habit.name}" 吗？');
    if (accepted && mounted) {
      await ref.read(todoClockInViewModelProvider.notifier).deleteHabit(habit);
    }
  }

  Future<bool> _confirm(
          BuildContext context, String title, String content) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除')),
          ],
        ),
      ) ??
      false;
}

// ==================== 顶部天气栏 ====================

class _NxtxHomeTitle extends StatelessWidget {
  final String cityName;
  final String tempMin;
  final String tempMax;
  final String weatherText;
  final VoidCallback onCityTap;
  final VoidCallback onWeatherTap;

  const _NxtxHomeTitle({
    required this.cityName,
    required this.tempMin,
    required this.tempMax,
    required this.weatherText,
    required this.onCityTap,
    required this.onWeatherTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              '全能宝具库',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF2575DB),
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onCityTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppAssets.nxtxWeatherLocation,
                        width: 14, height: 14),
                    const SizedBox(width: 4),
                    Text(
                      cityName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2575DB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onWeatherTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$tempMin°～$tempMax°',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2575DB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset(
                      _weatherIconAsset(weatherText),
                      width: 24,
                      height: 24,
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

  String _weatherIconAsset(String textDay) {
    final text = textDay.toLowerCase();
    if (text.contains('雷') || text.contains('电')) {
      return AppAssets.weatherSmallThunderstorm;
    }
    if (text.contains('雨') || text.contains('阵雨') || text.contains('雪')) {
      return AppAssets.weatherSmallRain;
    }
    if (text.contains('云') || text.contains('阴')) {
      return AppAssets.weatherSmallCloudy;
    }
    return AppAssets.weatherSmallSunny;
  }
}

// ==================== 每日一句 ====================

class _NxtxDailyQuote extends StatelessWidget {
  const _NxtxDailyQuote();

  static const _quotes = [
    '每一个不曾起舞的日子，都是对生命的辜负。',
    '生活不是等待风暴过去，而是学会在雨中跳舞。',
    '种一棵树最好的时间是十年前，其次是现在。',
    '愿你眼中总有光芒，愿你活成想要的模样。',
    '不积跬步，无以至千里；不积小流，无以成江海。',
  ];

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[DateTime.now().day % _quotes.length];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 136,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.nxtxHomeQuoteBackground),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        quote,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))
          ],
        ),
      ),
    );
  }
}

// ==================== 待办/打卡 Tab ====================

class _NxtxModeTabs extends StatelessWidget {
  final TodoClockInTab tab;
  final ValueChanged<TodoClockInTab> onChanged;

  const _NxtxModeTabs({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: '待办',
            selected: tab == TodoClockInTab.todo,
            onTap: () => onChanged(TodoClockInTab.todo),
          ),
          _ModeTab(
            label: '打卡',
            selected: tab == TodoClockInTab.clockIn,
            onTap: () => onChanged(TodoClockInTab.clockIn),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2575DB) : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : const Color(0xFF2575DB),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 横向日历 ====================

class _NxtxHabitLazyCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  const _NxtxHabitLazyCalendar({
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  State<_NxtxHabitLazyCalendar> createState() => _NxtxHabitLazyCalendarState();
}

class _NxtxHabitLazyCalendarState extends State<_NxtxHabitLazyCalendar> {
  static const _dayCount = 3651;
  static const _todayIndex = 1825;
  late final ScrollController _controller;
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _dates = List.generate(
      _dayCount,
      (index) => today.add(Duration(days: index - _todayIndex)),
    );
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    const itemWidth = 48.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final offset =
        (_todayIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    _controller.jumpTo(offset.clamp(0.0, _controller.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      height: 66,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final date = _dates[index];
          final selected = _sameDay(date, widget.selectedDate);
          return GestureDetector(
            onTap: () => widget.onSelect(date),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 48,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2575DB) : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '周${labels[date.weekday - 1]}',
                    style: TextStyle(
                      fontSize: 10,
                      color: selected ? Colors.white : const Color(0xFF8B919B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF252525),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== 内容区 ====================

class _NxtxHomeContent extends StatelessWidget {
  final TodoClockInState state;
  final TodoClockInViewModel viewModel;
  final VoidCallback onAdd;
  final ValueChanged<TodoItem> onEditTodo;
  final ValueChanged<TodoItem> onDeleteTodo;
  final ValueChanged<TodoItem> onCompleteTodo;
  final ValueChanged<HabitEntry> onClockIn;
  final ValueChanged<HabitItem> onDeleteHabit;

  const _NxtxHomeContent({
    required this.state,
    required this.viewModel,
    required this.onAdd,
    required this.onEditTodo,
    required this.onDeleteTodo,
    required this.onCompleteTodo,
    required this.onClockIn,
    required this.onDeleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (state.tab == TodoClockInTab.todo)
            _NxtxTodoList(
              todos: viewModel.todosForDate(state.selectedDate),
              completedExpanded: state.completedExpanded,
              onToggleExpanded: viewModel.toggleCompletedExpanded,
              onEdit: onEditTodo,
              onDelete: onDeleteTodo,
              onComplete: onCompleteTodo,
            )
          else
            _NxtxHabitList(
              entries: viewModel.habitEntriesForDate(state.selectedDate),
              onClockIn: onClockIn,
              onDelete: onDeleteHabit,
            ),
          const SizedBox(height: 12),
          _NxtxAddBar(onTap: onAdd, label: _addLabel),
        ],
      ),
    );
  }

  String get _addLabel => state.tab == TodoClockInTab.todo ? '添加待办' : '添加打卡';
}

// ==================== 待办列表 ====================

class _NxtxTodoList extends StatelessWidget {
  final List<TodoItem> todos;
  final bool completedExpanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<TodoItem> onEdit;
  final ValueChanged<TodoItem> onDelete;
  final ValueChanged<TodoItem> onComplete;

  const _NxtxTodoList({
    required this.todos,
    required this.completedExpanded,
    required this.onToggleExpanded,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final active = todos
        .where((item) => item.status != TodoStatus.completed)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final completed = todos
        .where((item) => item.status == TodoStatus.completed)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (todos.isEmpty) {
      return const SizedBox(
        height: 240,
        child: _EmptyState(label: '暂无待办事项'),
      );
    }

    return Column(
      children: [
        ...active.map((item) => _NxtxTodoRow(
              item: item,
              onTap: () => onEdit(item),
              onLongPress: () => onDelete(item),
              onComplete: () => onComplete(item),
            )),
        if (completed.isNotEmpty)
          _CompletedHeader(
            count: completed.length,
            expanded: completedExpanded,
            onTap: onToggleExpanded,
          ),
        if (completedExpanded)
          ...completed.map((item) => _NxtxTodoRow(
                item: item,
                onTap: () {},
                onLongPress: () => onDelete(item),
                onComplete: () {},
              )),
      ],
    );
  }
}

class _NxtxTodoRow extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onComplete;

  const _NxtxTodoRow({
    required this.item,
    required this.onTap,
    required this.onLongPress,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final completed = item.status == TodoStatus.completed;
    final expired = item.status == TodoStatus.expired;
    final hasReminder = item.reminderAt != null;
    final asset = completed
        ? AppAssets.nxtxHomeTodoCompletedCard
        : AppAssets.nxtxHomeTodoPendingCard;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 76,
      child: GestureDetector(
        onTap: completed ? null : onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(asset, fit: BoxFit.fill),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: completed ? null : onComplete,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completed
                            ? const Color(0xFF2575DB)
                            : Colors.transparent,
                        border: completed
                            ? null
                            : Border.all(
                                color: const Color(0xFF9AA0A8), width: 2),
                      ),
                      child: completed
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: completed
                                ? const Color(0xFF9FA4AD)
                                : expired
                                    ? const Color(0xFFD14C4C)
                                    : const Color(0xFF222222),
                            decoration:
                                completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (hasReminder) ...[
                          const SizedBox(height: 6),
                          Text(
                            _todoReminderText(item),
                            style: TextStyle(
                              fontSize: 11,
                              color: completed
                                  ? const Color(0xFF9FA4AD)
                                  : expired
                                      ? const Color(0xFFD14C4C)
                                      : const Color(0xFF737A80),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _todoReminderText(TodoItem item) {
    final at = item.reminderAt!;
    final dateTime =
        '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')} '
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    final suffix = _repeatSuffix(item.repeatType);
    if (item.status == TodoStatus.expired) {
      return '$dateTime$suffix - 已过期';
    }
    return '$dateTime$suffix';
  }

  String _repeatSuffix(TodoRepeatType type) {
    switch (type) {
      case TodoRepeatType.everyDay:
        return ' - 每天';
      case TodoRepeatType.weekday:
        return ' - 周一至周五';
      case TodoRepeatType.weekend:
        return ' - 周六至周日';
      default:
        return '';
    }
  }
}

// ==================== 打卡列表 ====================

class _NxtxHabitList extends StatelessWidget {
  final List<HabitEntry> entries;
  final ValueChanged<HabitEntry> onClockIn;
  final ValueChanged<HabitItem> onDelete;

  const _NxtxHabitList({
    required this.entries,
    required this.onClockIn,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox(
        height: 240,
        child: _EmptyState(label: '暂无打卡记录'),
      );
    }

    return Column(
      children: entries
          .map((entry) => _NxtxHabitRow(
                entry: entry,
                onTap: () => onClockIn(entry),
                onLongPress: () => onDelete(entry.habit),
              ))
          .toList(),
    );
  }
}

class _NxtxHabitRow extends StatelessWidget {
  final HabitEntry entry;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NxtxHabitRow({
    required this.entry,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final clocked = entry.clocked;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 76,
      child: GestureDetector(
        onTap: clocked ? null : onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(AppAssets.nxtxHomeClockCard, fit: BoxFit.fill),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Image.asset(
                    clocked
                        ? AppAssets.nxtxHomeClockChecked
                        : AppAssets.nxtxHomeClockUnchecked,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.habit.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: clocked
                                ? const Color(0xFF9FA4AD)
                                : const Color(0xFF222222),
                            decoration:
                                clocked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (entry.time.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            entry.time,
                            style: TextStyle(
                              fontSize: 11,
                              color: clocked
                                  ? const Color(0xFF9FA4AD)
                                  : const Color(0xFF737A80),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 公共组件 ====================

class _CompletedHeader extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  const _CompletedHeader({
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              Text(
                '已完成 ($count)',
                style: const TextStyle(
                  color: Color(0xFF8B919B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 18,
                color: const Color(0xFF8B919B),
              ),
            ],
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final String label;

  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 72, color: Color(0xFFB9C4D3)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF7A8595)),
            ),
          ],
        ),
      );
}

class _NxtxAddBar extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _NxtxAddBar({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 54,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.nxtxHomeAddBar),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}

// ==================== 待办编辑弹窗 ====================

class _TodoFormResult {
  final String content;
  final DateTime? reminderAt;
  final TodoRepeatType repeatType;

  const _TodoFormResult(this.content, this.reminderAt, this.repeatType);
}

class _TodoEditorDialog extends StatefulWidget {
  final TodoItem? original;

  const _TodoEditorDialog({required this.original});

  @override
  State<_TodoEditorDialog> createState() => _TodoEditorDialogState();
}

class _TodoEditorDialogState extends State<_TodoEditorDialog> {
  late final TextEditingController _controller;
  DateTime? _reminderAt;
  TodoRepeatType _repeatType = TodoRepeatType.none;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.original?.content ?? '');
    _reminderAt = widget.original?.reminderAt;
    _repeatType = widget.original?.repeatType ?? TodoRepeatType.none;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.original == null ? '添加待办' : '编辑待办',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '添加待办……',
                hintStyle: TextStyle(color: Color(0xFF9B9B9B)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),
            if (_reminderAt != null)
              _ReminderChip(
                reminderAt: _reminderAt!,
                repeatType: _repeatType,
                onDelete: () => setState(() {
                  _reminderAt = null;
                  _repeatType = TodoRepeatType.none;
                }),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_reminderAt == null)
                  _OutlinedActionChip(
                    icon: Icons.alarm,
                    label: '设置提醒',
                    onTap: _pickReminderScope,
                  ),
                const SizedBox(width: 10),
                _FilledActionChip(
                  label: '完成',
                  enabled: _reminderAt != null,
                  onTap: () {
                    if (_controller.text.trim().isNotEmpty) {
                      Navigator.pop(
                        context,
                        _TodoFormResult(
                          _controller.text,
                          _reminderAt,
                          _reminderAt == null
                              ? TodoRepeatType.none
                              : _repeatType,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReminderScope() async {
    final choice = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择待办日期'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('所选日期'),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              title: const Text('本周'),
              onTap: () => Navigator.pop(context, 1),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (!mounted) return;
    final now = DateTime.now();
    DateTime initialDate;
    if (choice == 1) {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: startOfWeek,
        lastDate: endOfWeek,
      );
      if (picked == null) return;
      initialDate = picked;
    } else {
      initialDate = now;
    }
    await _pickTime(initialDate);
  }

  Future<void> _pickTime(DateTime initialDate) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now()),
    );
    if (time != null) {
      setState(() {
        _reminderAt = DateTime(
          initialDate.year,
          initialDate.month,
          initialDate.day,
          time.hour,
          time.minute,
        );
      });
    }
  }
}

class _ReminderChip extends StatelessWidget {
  final DateTime reminderAt;
  final TodoRepeatType repeatType;
  final VoidCallback onDelete;

  const _ReminderChip({
    required this.reminderAt,
    required this.repeatType,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = reminderAt
        .isBefore(DateTime(now.year, now.month, now.day, now.hour, now.minute));
    final dateTime =
        '${reminderAt.year}-${reminderAt.month.toString().padLeft(2, '0')}-${reminderAt.day.toString().padLeft(2, '0')} '
        '${reminderAt.hour.toString().padLeft(2, '0')}:${reminderAt.minute.toString().padLeft(2, '0')}';
    final suffix = _repeatSuffix(repeatType);
    final display = isExpired ? '$dateTime$suffix - 已过期' : '$dateTime$suffix';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.alarm, size: 12, color: Color(0xFF1E1E1E)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              display,
              style: TextStyle(
                fontSize: 11,
                color: isExpired
                    ? const Color(0xFFD14C4C)
                    : const Color(0xFF1E1E1E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF9B9B9B)),
          ),
        ],
      ),
    );
  }

  String _repeatSuffix(TodoRepeatType type) {
    switch (type) {
      case TodoRepeatType.everyDay:
        return ' - 每天';
      case TodoRepeatType.weekday:
        return ' - 周一至周五';
      case TodoRepeatType.weekend:
        return ' - 周六至周日';
      default:
        return '';
    }
  }
}

// ==================== 打卡添加弹窗 ====================

class _HabitFormResult {
  final String name;
  final String scheduleType;
  final List<String> times;
  final DateTime startDate;
  final DateTime? endDate;
  final List<int> selectedWeekdays;

  const _HabitFormResult(
    this.name,
    this.scheduleType,
    this.times,
    this.startDate,
    this.endDate,
    this.selectedWeekdays,
  );
}

class _HabitEditorDialog extends StatefulWidget {
  const _HabitEditorDialog();

  @override
  State<_HabitEditorDialog> createState() => _HabitEditorDialogState();
}

class _HabitEditorDialogState extends State<_HabitEditorDialog> {
  final _name = TextEditingController();
  String _schedule = '每天';
  DateTime _start = DateTime.now();
  DateTime? _end;
  final List<String> _times = [];

  bool get _canSubmit => _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '新的习惯',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '给该习惯命名',
                style: TextStyle(fontSize: 15, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: '例：早起、锻炼等',
                  hintStyle: TextStyle(color: Color(0xFF9B9B9B)),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '定时',
                style: TextStyle(fontSize: 15, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 8),
              _SettingRow(
                label: _schedule,
                trailing: '更改',
                onTap: _showSchedulePicker,
              ),
              const SizedBox(height: 10),
              _SettingRow(
                label: _times.isEmpty ? '添加时间' : '添加时间（已添加 ${_times.length} 个）',
                trailing: '+',
                onTap: _addTime,
              ),
              if (_times.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    children: _times
                        .map((time) => Chip(
                              label: Text(time),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () =>
                                  setState(() => _times.remove(time)),
                            ))
                        .toList(),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                '持续时间',
                style: TextStyle(fontSize: 15, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 8),
              _SettingRow(
                label: '开始日期',
                trailing: _formatChineseDate(_start),
                onTap: _pickStart,
              ),
              const SizedBox(height: 10),
              _SettingRow(
                label: '结束日期',
                trailing: _end == null ? '无' : _formatChineseDate(_end!),
                onTap: _pickEnd,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 46,
                child: FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF3DCEE9),
                    disabledBackgroundColor: const Color(0xFFCACACA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                  child: const Text('保存', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSchedulePicker() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择周期'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ScheduleOption(label: '每天', selected: _schedule == '每天'),
            _ScheduleOption(label: '周一至周五', selected: _schedule == '周一至周五'),
            _ScheduleOption(label: '周六至周日', selected: _schedule == '周六至周日'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _schedule),
            child: const Text('完成'),
          ),
        ],
      ),
    );
    if (result != null) setState(() => _schedule = result);
  }

  Future<void> _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    if (!mounted) return;
    final value =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (_times.contains(value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该时间点已添加')),
      );
      return;
    }
    setState(() {
      _times.add(value);
      _times.sort();
    });
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    setState(() {
      _start = date;
      if (_end != null && !_end!.isAfter(_start)) {
        _end = null;
      }
    });
  }

  Future<void> _pickEnd() async {
    final choice = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('结束日期'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('无'),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              title: const Text('选择具体日期'),
              onTap: () => Navigator.pop(context, 1),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (!mounted) return;
    if (choice == 0) {
      setState(() => _end = null);
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: _end ?? _start.add(const Duration(days: 1)),
      firstDate: _start.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _end = date);
  }

  void _submit() {
    if (_name.text.trim().isEmpty) return;
    final weekdays = _schedule == '指定星期' ? <int>[] : const <int>[];
    Navigator.pop(
      context,
      _HabitFormResult(
        _name.text.trim(),
        _schedule,
        [..._times],
        _start,
        _end,
        weekdays,
      ),
    );
  }

  String _formatChineseDate(DateTime value) =>
      '${value.year}年${value.month.toString().padLeft(2, '0')}月${value.day.toString().padLeft(2, '0')}日';
}

class _ScheduleOption extends StatelessWidget {
  final String label;
  final bool selected;

  const _ScheduleOption({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(label),
        trailing:
            selected ? const Icon(Icons.check, color: Color(0xFF2575DB)) : null,
        onTap: () => Navigator.pop(context, label),
      );
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String trailing;
  final VoidCallback onTap;

  const _SettingRow({
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 15)),
              const Spacer(),
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2575DB),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: Color(0xFF999999)),
            ],
          ),
        ),
      );
}

class _OutlinedActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlinedActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D999999),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF1E1E1E)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF1E1E1E)),
              ),
            ],
          ),
        ),
      );
}

class _FilledActionChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _FilledActionChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFF10D0F7) : const Color(0xFFCACACA),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D999999),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      );
}

// ==================== 工具函数 ====================

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
