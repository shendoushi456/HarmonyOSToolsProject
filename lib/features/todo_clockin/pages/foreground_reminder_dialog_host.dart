import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../router/app_router.dart';
import '../models/todo_models.dart';
import '../services/foreground_reminder_coordinator.dart';
import '../viewmodels/todo_clockin_state.dart';
import '../viewmodels/todo_clockin_view_model.dart';

/// 全局前台提醒宿主：应用显示时到点弹窗，后台时由 ReminderAgent 显示系统状态栏提醒。
class ForegroundReminderDialogHost extends ConsumerStatefulWidget {
  final Widget child;
  const ForegroundReminderDialogHost({super.key, required this.child});

  @override
  ConsumerState<ForegroundReminderDialogHost> createState() =>
      _ForegroundReminderDialogHostState();
}

class _ForegroundReminderDialogHostState
    extends ConsumerState<ForegroundReminderDialogHost>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _isForeground = true;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _evaluate());
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) {
      _evaluate();
    }
  }

  void _evaluate([TodoClockInState? snapshot]) {
    if (!_isForeground) {
      return;
    }
    final TodoClockInState source =
        snapshot ?? ref.read(todoClockInViewModelProvider);
    ref
        .read(foregroundReminderCoordinatorProvider.notifier)
        .evaluate(source, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TodoClockInState>(
        todoClockInViewModelProvider, (previous, next) => _evaluate(next));
    ref.listen<ForegroundReminderState>(foregroundReminderCoordinatorProvider,
        (previous, next) {
      if (_isForeground && !_showing && next.current != null) {
        _showPrompt(next.current!);
      }
    });
    return widget.child;
  }

  Future<void> _showPrompt(ForegroundReminderPrompt prompt) async {
    final dialogContext = appNavigatorKey.currentContext;
    if (dialogContext == null || !mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _showing) {
          return;
        }
        final pending = ref.read(foregroundReminderCoordinatorProvider).current;
        if (pending != null) {
          _showPrompt(pending);
        }
      });
      return;
    }
    _showing = true;
    final action = await showDialog<_ReminderAction>(
        context: dialogContext,
        barrierDismissible: false,
        builder: (context) => _ReminderDialog(prompt: prompt));
    if (!mounted) {
      return;
    }
    if (action == _ReminderAction.complete) {
      await _completePrompt(prompt);
    }
    if (mounted) {
      _showing = false;
      ref.read(foregroundReminderCoordinatorProvider.notifier).dismissCurrent();
    }
  }

  Future<void> _completePrompt(ForegroundReminderPrompt prompt) async {
    final viewModel = ref.read(todoClockInViewModelProvider.notifier);
    final state = ref.read(todoClockInViewModelProvider);
    if (prompt.kind == ForegroundReminderKind.todo) {
      final todo = state.todos
          .cast<TodoItem?>()
          .firstWhere((item) => item?.id == prompt.itemId, orElse: () => null);
      if (todo != null) {
        await viewModel.completeTodo(todo);
      }
      return;
    }
    final habit = state.habits
        .cast<HabitItem?>()
        .firstWhere((item) => item?.id == prompt.itemId, orElse: () => null);
    if (habit != null && prompt.timePoint != null) {
      await viewModel.clockInForDate(habit, prompt.timePoint!, prompt.dueAt);
    }
  }
}

enum _ReminderAction { complete, later }

class _ReminderDialog extends StatelessWidget {
  final ForegroundReminderPrompt prompt;
  const _ReminderDialog({required this.prompt});

  @override
  Widget build(BuildContext context) {
    final isTodo = prompt.kind == ForegroundReminderKind.todo;
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(isTodo ? Icons.assignment_turned_in_outlined : Icons.task_alt,
              color: const Color(0xFF5D7CE6)),
          const SizedBox(width: 8),
          Text(isTodo ? '待办提醒' : '打卡提醒')
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(prompt.title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          if (prompt.timePoint != null) ...[
            const SizedBox(height: 10),
            Text('提醒时间：${prompt.timePoint}',
                style: const TextStyle(color: Color(0xFF737A80)))
          ]
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, _ReminderAction.later),
              child: const Text('稍后处理')),
          FilledButton(
              onPressed: () => Navigator.pop(context, _ReminderAction.complete),
              child: Text(isTodo ? '完成' : '打卡'))
        ]);
  }
}
