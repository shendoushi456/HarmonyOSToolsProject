import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo_models.dart';
import '../viewmodels/todo_clockin_state.dart';
import '../viewmodels/todo_clockin_view_model.dart';

/// 首页 UI 层。仅负责展示与收集用户输入，可替换为任意马甲视觉实现。
class TodoClockInPage extends ConsumerStatefulWidget {
  const TodoClockInPage({super.key});

  @override
  ConsumerState<TodoClockInPage> createState() => _TodoClockInPageState();
}

class _TodoClockInPageState extends ConsumerState<TodoClockInPage> {
  Offset _fabOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todoClockInViewModelProvider);
    final viewModel = ref.read(todoClockInViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                _SegmentedHeader(
                  tab: state.tab,
                  onChanged: viewModel.selectTab,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : state.tab == TodoClockInTab.todo
                          ? _TodoList(
                              state: state,
                              onEdit: (item) => _showTodoEditor(context, item),
                              onComplete: viewModel.completeTodo,
                              onDelete: (item) =>
                                  _confirmDeleteTodo(context, item),
                              onToggleCompleted:
                                  viewModel.toggleCompletedExpanded,
                            )
                          : _ClockInContent(
                              state: state,
                              viewModel: viewModel,
                              onDelete: (habit) =>
                                  _confirmDeleteHabit(context, habit),
                            ),
                ),
              ],
            ),
            Positioned(
              right: 20 + _fabOffset.dx,
              bottom: 24 + _fabOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _fabOffset += details.delta;
                    _fabOffset = Offset(
                      _fabOffset.dx.clamp(-220.0, 0.0).toDouble(),
                      _fabOffset.dy.clamp(-520.0, 0.0).toDouble(),
                    );
                  });
                },
                onPanEnd: (_) => setState(() {
                  _fabOffset =
                      Offset(_fabOffset.dx < -110 ? -220 : 0, _fabOffset.dy);
                }),
                child: FloatingActionButton(
                  elevation: 4,
                  backgroundColor: const Color(0xFF5D7CE6),
                  onPressed: () => state.tab == TodoClockInTab.todo
                      ? _showTodoEditor(context, null)
                      : _showHabitEditor(context),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTodoEditor(BuildContext context, TodoItem? original) async {
    final result = await showModalBottomSheet<_TodoFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TodoEditorSheet(original: original),
    );
    if (result == null || !mounted) return;
    await ref.read(todoClockInViewModelProvider.notifier).saveTodo(
          content: result.content,
          reminderAt: result.reminderAt,
          repeatType: result.repeatType,
          original: original,
        );
  }

  Future<void> _showHabitEditor(BuildContext context) async {
    final result = await showModalBottomSheet<_HabitFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HabitEditorSheet(),
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
        await _confirm(context, '删除待办', '确定要删除「${item.content}」吗？');
    if (accepted && mounted) {
      await ref.read(todoClockInViewModelProvider.notifier).deleteTodo(item);
    }
  }

  Future<void> _confirmDeleteHabit(
      BuildContext context, HabitItem habit) async {
    final accepted =
        await _confirm(context, '删除习惯', '确定要删除习惯「${habit.name}」吗？');
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

class _SegmentedHeader extends StatelessWidget {
  final TodoClockInTab tab;
  final ValueChanged<TodoClockInTab> onChanged;

  const _SegmentedHeader({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: const Color(0x66999999),
            borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _segment('待办', TodoClockInTab.todo),
          _segment('打卡', TodoClockInTab.clockIn),
        ]),
      );

  Widget _segment(String text, TodoClockInTab value) {
    final selected = tab == value;
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 16,
                color: selected ? const Color(0xFF5D7CE6) : Colors.white)),
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  final TodoClockInState state;
  final ValueChanged<TodoItem> onEdit;
  final ValueChanged<TodoItem> onComplete;
  final ValueChanged<TodoItem> onDelete;
  final VoidCallback onToggleCompleted;

  const _TodoList({
    required this.state,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
    required this.onToggleCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final active = state.todos
        .where((item) => item.status != TodoStatus.completed)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final completed = state.todos
        .where((item) => item.status == TodoStatus.completed)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (state.todos.isEmpty) {
      return const _EmptyState(
          label: '暂无待办事项', icon: Icons.assignment_outlined);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 96),
      children: [
        ...active.map((item) => _TodoCard(
            item: item,
            onTap: () => onEdit(item),
            onComplete: () => onComplete(item),
            onDelete: () => onDelete(item))),
        if (completed.isNotEmpty)
          _CompletedHeader(
              count: completed.length,
              expanded: state.completedExpanded,
              onTap: onToggleCompleted),
        if (state.completedExpanded)
          ...completed.map((item) => _TodoCard(
              item: item,
              onTap: () {},
              onComplete: () {},
              onDelete: () => onDelete(item))),
      ],
    );
  }
}

class _TodoCard extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _TodoCard(
      {required this.item,
      required this.onTap,
      required this.onComplete,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final completed = item.status == TodoStatus.completed;
    final expired = item.status == TodoStatus.expired;
    final color = completed
        ? const Color(0xFF9FA4AD)
        : expired
            ? const Color(0xFFD14C4C)
            : const Color(0xFF222222);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: completed ? null : onTap,
          onLongPress: onDelete,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(children: [
              InkResponse(
                onTap: onComplete,
                radius: 20,
                child: Icon(
                    completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: completed
                        ? const Color(0xFF5D7CE6)
                        : const Color(0xFF9AA0A8)),
              ),
              const SizedBox(width: 9),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(item.content,
                        style: TextStyle(
                            fontSize: 15,
                            color: color,
                            decoration:
                                completed ? TextDecoration.lineThrough : null)),
                    if (item.reminderAt != null) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.alarm_outlined, size: 12, color: color),
                        const SizedBox(width: 3),
                        Text(_todoReminderText(item),
                            style: TextStyle(fontSize: 10, color: color)),
                      ]),
                    ],
                  ])),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ClockInContent extends StatelessWidget {
  final TodoClockInState state;
  final TodoClockInViewModel viewModel;
  final ValueChanged<HabitItem> onDelete;

  const _ClockInContent(
      {required this.state, required this.viewModel, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final active = state.habits
        .where((habit) => viewModel.isHabitActiveOn(habit, state.selectedDate))
        .toList();
    final entries = <_HabitEntry>[];
    for (final habit in active) {
      final times =
          habit.clockInTimes.isEmpty ? const [''] : habit.clockInTimes;
      entries.addAll(times.map((time) =>
          _HabitEntry(habit, time, viewModel.isClocked(habit, time))));
    }
    final pending = entries.where((entry) => !entry.clocked).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final done = entries.where((entry) => entry.clocked).toList()
      ..sort((a, b) => b.habit.createdAt.compareTo(a.habit.createdAt));
    return Column(children: [
      _WeekCalendar(
          selectedDate: state.selectedDate, onSelect: viewModel.selectDate),
      const SizedBox(height: 8),
      Expanded(
        child: entries.isEmpty
            ? const _EmptyState(
                label: '暂无打卡记录', icon: Icons.event_available_outlined)
            : ListView(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 96),
                children: [
                    ...pending.map((entry) => _HabitCard(
                        entry: entry,
                        onClock: () =>
                            viewModel.clockIn(entry.habit, entry.time),
                        onDelete: () => onDelete(entry.habit))),
                    if (done.isNotEmpty)
                      _CompletedHeader(
                          count: done.length,
                          expanded: state.completedExpanded,
                          onTap: viewModel.toggleCompletedExpanded,
                          date: state.selectedDate),
                    if (state.completedExpanded)
                      ...done.map((entry) => _HabitCard(
                          entry: entry,
                          onClock: () {},
                          onDelete: () => onDelete(entry.habit))),
                  ]),
      ),
    ]);
  }
}

class _HabitEntry {
  final HabitItem habit;
  final String time;
  final bool clocked;
  const _HabitEntry(this.habit, this.time, this.clocked);
}

class _HabitCard extends StatelessWidget {
  final _HabitEntry entry;
  final VoidCallback onClock;
  final VoidCallback onDelete;
  const _HabitCard(
      {required this.entry, required this.onClock, required this.onDelete});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onLongPress: onDelete,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(children: [
                InkResponse(
                    onTap: onClock,
                    radius: 20,
                    child: Icon(
                        entry.clocked
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: entry.clocked
                            ? const Color(0xFF5D7CE6)
                            : const Color(0xFF9AA0A8))),
                const SizedBox(width: 9),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(entry.habit.name,
                          style: TextStyle(
                              fontSize: 15,
                              color: entry.clocked
                                  ? const Color(0xFF9FA4AD)
                                  : const Color(0xFF222222),
                              decoration: entry.clocked
                                  ? TextDecoration.lineThrough
                                  : null)),
                      if (entry.time.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(children: [
                              Icon(Icons.alarm_outlined,
                                  size: 12,
                                  color: entry.clocked
                                      ? const Color(0xFF9FA4AD)
                                      : const Color(0xFF555555)),
                              const SizedBox(width: 3),
                              Text(entry.time,
                                  style: const TextStyle(fontSize: 10))
                            ])),
                    ])),
              ]),
            ),
          ),
        ),
      );
}

class _CompletedHeader extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onTap;
  final DateTime? date;
  const _CompletedHeader(
      {required this.count,
      required this.expanded,
      required this.onTap,
      this.date});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(children: [
            Text(
                '${date == null ? '' : '${date!.month}月${date!.day}日 '}已完成 ($count)',
                style: const TextStyle(color: Color(0xFF8B919B), fontSize: 16)),
            const SizedBox(width: 4),
            Icon(
                expanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 18,
                color: const Color(0xFF8B919B)),
          ]),
        ),
      );
}

class _WeekCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;
  const _WeekCalendar({required this.selectedDate, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final monday =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
          children: List.generate(7, (index) {
        final date = monday.add(Duration(days: index));
        final selected = _sameDay(date, selectedDate);
        return Expanded(
            child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onSelect(date),
          child: Column(children: [
            Text('周${labels[index]}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF8B919B))),
            const SizedBox(height: 7),
            Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color:
                        selected ? const Color(0xFF5D7CE6) : Colors.transparent,
                    shape: BoxShape.circle),
                child: Text('${date.day}',
                    style: TextStyle(
                        color:
                            selected ? Colors.white : const Color(0xFF252525),
                        fontSize: 15))),
          ]),
        ));
      })),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  final IconData icon;
  const _EmptyState({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 90, color: const Color(0xFFD1D6DE)),
        const SizedBox(height: 10),
        Text(label,
            style: const TextStyle(fontSize: 18, color: Color(0xFF444444)))
      ]));
}

class _TodoFormResult {
  final String content;
  final DateTime? reminderAt;
  final TodoRepeatType repeatType;
  const _TodoFormResult(this.content, this.reminderAt, this.repeatType);
}

class _TodoEditorSheet extends StatefulWidget {
  final TodoItem? original;
  const _TodoEditorSheet({required this.original});
  @override
  State<_TodoEditorSheet> createState() => _TodoEditorSheetState();
}

class _TodoEditorSheetState extends State<_TodoEditorSheet> {
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
  Widget build(BuildContext context) => _SheetFrame(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Text(widget.original == null ? '添加待办' : '编辑待办',
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: '添加待办……', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            if (_reminderAt != null)
              _ReminderChip(
                  reminderAt: _reminderAt!,
                  repeatType: _repeatType,
                  onDelete: () => setState(() {
                        _reminderAt = null;
                        _repeatType = TodoRepeatType.none;
                      })),
            if (_reminderAt == null)
              OutlinedButton.icon(
                  onPressed: _pickReminder,
                  icon: const Icon(Icons.alarm),
                  label: const Text('设置提醒')),
            if (_reminderAt != null)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: DropdownButtonFormField<TodoRepeatType>(
                      value: _repeatType,
                      items: TodoRepeatType.values
                          .map((type) => DropdownMenuItem(
                              value: type, child: Text(_repeatName(type))))
                          .toList(),
                      onChanged: (value) => setState(
                          () => _repeatType = value ?? TodoRepeatType.none),
                      decoration: const InputDecoration(
                          labelText: '重复方式', border: OutlineInputBorder()))),
            const SizedBox(height: 18),
            Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        Navigator.pop(
                            context,
                            _TodoFormResult(
                                _controller.text, _reminderAt, _repeatType));
                      }
                    },
                    child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: Text('完成')))),
          ]));
  Future<void> _pickReminder() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _reminderAt ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100));
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now()));
    if (time != null) {
      setState(() => _reminderAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute));
    }
  }
}

class _ReminderChip extends StatelessWidget {
  final DateTime reminderAt;
  final TodoRepeatType repeatType;
  final VoidCallback onDelete;
  const _ReminderChip(
      {required this.reminderAt,
      required this.repeatType,
      required this.onDelete});
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.alarm_outlined, size: 14),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text(
                          '${_formatDateTime(reminderAt)}${_repeatSuffix(repeatType)}',
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis))
                ]))),
        IconButton(onPressed: onDelete, icon: const Icon(Icons.close, size: 18))
      ]);
}

class _HabitFormResult {
  final String name;
  final String scheduleType;
  final List<String> times;
  final DateTime startDate;
  final DateTime? endDate;
  final List<int> selectedWeekdays;
  const _HabitFormResult(this.name, this.scheduleType, this.times,
      this.startDate, this.endDate, this.selectedWeekdays);
}

class _HabitEditorSheet extends StatefulWidget {
  const _HabitEditorSheet();
  @override
  State<_HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends State<_HabitEditorSheet> {
  final _name = TextEditingController();
  final _time = TextEditingController();
  String _schedule = '每天';
  DateTime _start = DateTime.now();
  DateTime? _end;
  final List<String> _times = [];
  final Set<int> _weekdays = {};
  @override
  void dispose() {
    _name.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _SheetFrame(
          child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
            const Text('添加打卡习惯',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            TextField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: '习惯名称',
                    hintText: '例如：早起',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                value: _schedule,
                decoration: const InputDecoration(
                    labelText: '重复方式', border: OutlineInputBorder()),
                items: const ['每天', '周一至周五', '周六至周日', '指定星期']
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _schedule = value ?? '每天')),
            if (_schedule == '指定星期')
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                      spacing: 4,
                      children: List.generate(7, (index) {
                        final day = index + 1;
                        return FilterChip(
                            label: Text('周${[
                              '一',
                              '二',
                              '三',
                              '四',
                              '五',
                              '六',
                              '日'
                            ][index]}'),
                            selected: _weekdays.contains(day),
                            onSelected: (selected) => setState(() => selected
                                ? _weekdays.add(day)
                                : _weekdays.remove(day)));
                      }))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: _pickStart,
                      child: Text('开始：${_formatDate(_start)}'))),
              const SizedBox(width: 8),
              Expanded(
                  child: OutlinedButton(
                      onPressed: _pickEnd,
                      child: Text(
                          _end == null ? '结束：无' : '结束：${_formatDate(_end!)}')))
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: _time,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                          hintText: '打卡时间，如 08:00',
                          border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              FilledButton(onPressed: _addTime, child: const Text('添加'))
            ]),
            if (_times.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                      spacing: 6,
                      children: _times
                          .map((time) => InputChip(
                              label: Text(time),
                              onDeleted: () =>
                                  setState(() => _times.remove(time))))
                          .toList())),
            const SizedBox(height: 18),
            Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                    onPressed: () {
                      if (_name.text.trim().isNotEmpty) {
                        Navigator.pop(
                            context,
                            _HabitFormResult(_name.text, _schedule, _times,
                                _start, _end, _weekdays.toList()));
                      }
                    },
                    child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: Text('完成')))),
          ])));
  Future<void> _pickStart() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _start,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100));
    if (date != null) {
      setState(() {
        _start = date;
        if (_end != null && _end!.isBefore(date)) {
          _end = null;
        }
      });
    }
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _end ?? _start.add(const Duration(days: 1)),
        firstDate: _start,
        lastDate: DateTime(2100));
    if (date != null) {
      setState(() => _end = date);
    }
  }

  void _addTime() {
    final value = _time.text.trim();
    if (RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value) &&
        !_times.contains(value)) {
      setState(() {
        _times.add(value.padLeft(5, '0'));
        _times.sort();
        _time.clear();
      });
    }
  }
}

class _SheetFrame extends StatelessWidget {
  final Widget child;
  const _SheetFrame({required this.child});
  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: Padding(padding: const EdgeInsets.all(20), child: child)));
}

String _todoReminderText(TodoItem item) =>
    '${_formatDateTime(item.reminderAt!)}${_repeatSuffix(item.repeatType)}${item.status == TodoStatus.expired ? ' - 已过期' : ''}';
String _formatDateTime(DateTime value) =>
    '${_formatDate(value)} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
String _formatDate(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
String _repeatSuffix(TodoRepeatType type) => type == TodoRepeatType.weekday
    ? ' - 周一至周五'
    : type == TodoRepeatType.weekend
        ? ' - 周六至周日'
        : type == TodoRepeatType.everyDay
            ? ' - 每天'
            : '';
String _repeatName(TodoRepeatType type) => type == TodoRepeatType.none
    ? '不重复'
    : type == TodoRepeatType.everyDay
        ? '每天'
        : type == TodoRepeatType.weekday
            ? '周一至周五'
            : '周六至周日';
bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
