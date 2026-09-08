import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 原生 ReminderAgent 点击通知时携带的业务定位信息。
/// 当前仅用于进入待办打卡页；[itemId] 和 [timePoint] 留给后续的列表定位/高亮。
@immutable
class ReminderLaunch {
  final String reminderType;
  final int itemId;
  final int targetTab;
  final String? timePoint;

  const ReminderLaunch({
    required this.reminderType,
    required this.itemId,
    required this.targetTab,
    this.timePoint,
  });

  factory ReminderLaunch.fromMap(Map<Object?, Object?> values) {
    final itemId = int.tryParse('${values['itemId'] ?? ''}');
    final reminderType = '${values['reminderType'] ?? ''}';
    if (itemId == null || (reminderType != 'todo' && reminderType != 'habit')) {
      throw const FormatException('无效的提醒跳转参数');
    }
    return ReminderLaunch(
      reminderType: reminderType,
      itemId: itemId,
      targetTab: int.tryParse('${values['targetTab'] ?? 0}') ?? 0,
      timePoint: values['timePoint']?.toString(),
    );
  }
}

/// 将原生冷启动缓存和热启动回调收敛为一个待处理事件。
/// 不在这里做路由，确保隐私协议仍由 SplashPage 正常处理。
class ReminderLaunchCoordinator {
  ReminderLaunchCoordinator._();

  static final instance = ReminderLaunchCoordinator._();
  static const _channel = MethodChannel('com.p.a_b/toolbox_reminder');

  final ValueNotifier<int> _signal = ValueNotifier<int>(0);
  ReminderLaunch? _pending;
  bool _initialized = false;

  ValueListenable<int> get signal => _signal;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_onNativeCall);
    final values = await _channel.invokeMapMethod<Object?, Object?>(
      'getInitialReminderLaunch',
    );
    if (values != null) {
      _accept(values);
    }
  }

  Future<Object?> _onNativeCall(MethodCall call) async {
    if (call.method != 'onReminderLaunch') return null;
    final values = call.arguments;
    if (values is Map) {
      _accept(Map<Object?, Object?>.from(values));
    }
    return null;
  }

  void _accept(Map<Object?, Object?> values) {
    try {
      _pending = ReminderLaunch.fromMap(values);
      _notify();
    } on FormatException {
      // 非提醒启动参数不应影响正常启动。
    }
  }

  ReminderLaunch? takePending() {
    final launch = _pending;
    _pending = null;
    return launch;
  }

  /// 隐私协议同意后由 SplashPage 调用，继续派发此前保留的冷启动事件。
  void notifyPrivacyAccepted() => _notify();

  void _notify() => _signal.value++;
}
