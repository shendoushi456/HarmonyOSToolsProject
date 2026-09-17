// 常驻通知实时网速通道封装 - 对接 ohos/entry/src/main/ets/plugins/NotifySpeedPlugin.ets
// 对齐 Android NetworkSpeedService/NetworkSpeedNotification(鸿蒙简化版文本通知)
import 'package:flutter/services.dart';

/// 常驻通知网速通道,单例
class NotifySpeedChannel {
  NotifySpeedChannel._();
  static final NotifySpeedChannel instance = NotifySpeedChannel._();

  static const MethodChannel _method =
      MethodChannel('toolbox.notify.speed/native');

  /// 请求通知授权(对齐 Android 13+ POST_NOTIFICATIONS 首次弹框)
  Future<bool> requestNotificationPermission() async =>
      (await _method.invokeMethod<bool>('requestNotificationPermission')) ??
      false;

  /// 启动常驻通知(对齐 Android startForegroundService)
  /// [intervalMs] 刷新间隔,默认 5000ms 对齐安卓 NetworkSpeedService
  /// [showDailyWifi]/[showDailyMobile] 每日用量开关(对齐 show_daily_wifi_usage/
  /// show_daily_data_usage,控制通知文本是否追加"WiFi x"/"流量 y")
  /// [showOnLockScreen] 锁屏通知开关(对齐 notification_on_lock_screen:
  /// 开=灭屏后通知继续显示在锁屏;关=灭屏即隐藏通知)
  Future<void> startSpeedNotify({
    int intervalMs = 5000,
    bool showDailyWifi = false,
    bool showDailyMobile = false,
    bool showOnLockScreen = false,
  }) async =>
      _method.invokeMethod<void>('startSpeedNotify', <String, dynamic>{
        'intervalMs': intervalMs,
        'showDailyWifi': showDailyWifi,
        'showDailyMobile': showDailyMobile,
        'showOnLockScreen': showOnLockScreen,
      });

  /// 停止常驻通知(对齐 Android stopService)
  Future<void> stopSpeedNotify() async =>
      _method.invokeMethod<void>('stopSpeedNotify');

  /// 更新每日用量显示配置(对齐安卓改开关即重启 Service 刷新通知)
  Future<void> updateDailyConfig({
    required bool showDailyWifi,
    required bool showDailyMobile,
  }) async =>
      _method.invokeMethod<void>('updateDailyConfig', <String, dynamic>{
        'showDailyWifi': showDailyWifi,
        'showDailyMobile': showDailyMobile,
      });

  /// 更新锁屏通知配置(对齐安卓锁屏开关切换后重建通知)
  Future<void> updateLockScreenConfig({required bool showOnLockScreen}) async =>
      _method.invokeMethod<void>('updateLockScreenConfig', <String, dynamic>{
        'showOnLockScreen': showOnLockScreen,
      });
}
