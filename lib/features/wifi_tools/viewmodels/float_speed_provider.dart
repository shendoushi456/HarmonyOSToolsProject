// 浮窗(应用内悬浮网速)开关状态 - 对齐 Android FloatingWindow Service 运行态
// 开关状态存 SP(floating_switch),对齐 StoredPreferencesValue
// 浮层本体见 ../widgets/wifi_speed_overlay.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/prefs_storage.dart';

final floatSpeedProvider =
    NotifierProvider<FloatSpeedNotifier, bool>(FloatSpeedNotifier.new);

class FloatSpeedNotifier extends Notifier<bool> {
  static const String _spKey = 'floating_switch'; // 对齐 StoredPreferencesValue

  @override
  bool build() {
    // 防御: SP 未就绪时不抛异常(避免 build 期红屏),按未开启处理
    try {
      return PrefsStorage.getBool(_spKey);
    } catch (_) {
      return false;
    }
  }

  Future<void> setShowing(bool value) async {
    await PrefsStorage.setBool(_spKey, value);
    state = value;
  }
}

/// 浮窗内容配置 - 对齐 Android 浮窗设置区三开关
/// (StoredPreferencesValue: total_vis=显示总速度 / down_vis=每日WiFi数据 /
///  up_vis=每日移动数据,控制悬浮窗浮层显示哪些行)
class FloatWindowConfig {
  final bool showTotal; // 对齐 total_vis(显示总速度)
  final bool showDailyWifi; // 对齐 down_vis(每日WiFi数据,原工程文案 Bug 已按需求更名)
  final bool showDailyMobile; // 对齐 up_vis(每日移动数据)

  const FloatWindowConfig({
    this.showTotal = false,
    this.showDailyWifi = false,
    this.showDailyMobile = false,
  });
}

final floatWindowConfigProvider =
    NotifierProvider<FloatWindowConfigNotifier, FloatWindowConfig>(
        FloatWindowConfigNotifier.new);

class FloatWindowConfigNotifier extends Notifier<FloatWindowConfig> {
  static const String _kTotal = 'total_vis';
  static const String _kDown = 'down_vis'; // 每日WiFi数据
  static const String _kUp = 'up_vis'; // 每日移动数据

  @override
  FloatWindowConfig build() {
    // 防御: SP 未就绪按全关处理(避免 build 期红屏)
    try {
      return FloatWindowConfig(
        showTotal: PrefsStorage.getBool(_kTotal),
        showDailyWifi: PrefsStorage.getBool(_kDown),
        showDailyMobile: PrefsStorage.getBool(_kUp),
      );
    } catch (_) {
      return const FloatWindowConfig();
    }
  }

  Future<void> setShowTotal(bool value) async {
    await PrefsStorage.setBool(_kTotal, value);
    state = FloatWindowConfig(
      showTotal: value,
      showDailyWifi: state.showDailyWifi,
      showDailyMobile: state.showDailyMobile,
    );
  }

  Future<void> setDailyWifi(bool value) async {
    await PrefsStorage.setBool(_kDown, value);
    state = FloatWindowConfig(
      showTotal: state.showTotal,
      showDailyWifi: value,
      showDailyMobile: state.showDailyMobile,
    );
  }

  Future<void> setDailyMobile(bool value) async {
    await PrefsStorage.setBool(_kUp, value);
    state = FloatWindowConfig(
      showTotal: state.showTotal,
      showDailyWifi: state.showDailyWifi,
      showDailyMobile: value,
    );
  }
}
