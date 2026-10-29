// 在 Flutter 根部接收原生提醒点击。协议未同意时保留事件，不越过 SplashPage。
// 移植自提交 04d34a5b（糖压管家宝 添加系统提醒），适配本分支无 viewmodel 的结构：
// 仅记录最近一次启动目标，由 TodoClockinPage 读取并切换到对应 Tab。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs_storage.dart';
import '../../../router/app_router.dart';
import '../../../router/route_names.dart';
import '../../home/viewmodels/home_tab_view_model.dart';
import '../services/reminder_launch_coordinator.dart';

/// 最近一次从系统通知进入应用的目标，供待办打卡页定位对应 Tab。
final latestReminderLaunchProvider =
    StateProvider<ReminderLaunch?>((ref) => null);

/// 在 Flutter 根部接收原生提醒点击。
class ReminderLaunchHost extends ConsumerStatefulWidget {
  final Widget child;
  const ReminderLaunchHost({super.key, required this.child});

  @override
  ConsumerState<ReminderLaunchHost> createState() =>
      _ReminderLaunchHostState();
}

class _ReminderLaunchHostState extends ConsumerState<ReminderLaunchHost> {
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = _dispatchIfReady;
    ReminderLaunchCoordinator.instance.signal.addListener(_listener);
    ReminderLaunchCoordinator.instance.initialize().catchError((_) {
      // 原生通道不存在时保持普通启动，不影响非鸿蒙平台调试。
    });
  }

  @override
  void dispose() {
    ReminderLaunchCoordinator.instance.signal.removeListener(_listener);
    super.dispose();
  }

  void _dispatchIfReady() {
    if (!mounted || !PrefsStorage.loadIsAgressment()) return;
    final launch = ReminderLaunchCoordinator.instance.takePending();
    if (launch == null) return;
    appRouter.go(RoutePaths.weather);
    ref.read(homeTabIndexProvider.notifier).state = launch.targetTab;
    ref.read(latestReminderLaunchProvider.notifier).state = launch;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
