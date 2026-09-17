// 通知栏实时网速常驻通知插件 - 对齐 Android NetworkSpeedService/NetworkSpeedNotification(简化版)
// 鸿蒙无 RemoteViews 自定义布局, 采用文本通知每 5 秒更新下载/上传/信号
// 每日 WiFi/移动用量对齐安卓语义(querySummaryForDevice 当日 0 点起 Rx):
// 用 statistics.getIfaceRxBytes('wlan0')/getCellularRxBytes() 的"当日 0 点快照差值"还原,
// 快照持久化到 preferences,跨日自动重置(重启计数器归零属近似,安卓 NetworkStatsManager 系统级持久)
// 对应 Dart 端 lib/core/network/notify_speed_channel.dart
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodChannel,
  MethodCall,
  MethodResult,
  Log,
} from '@ohos/flutter_ohos';
import notificationManager from '@ohos.notificationManager';
import wifiManager from '@ohos.wifi';
import statistics from '@ohos.net.statistics';
import dataPreferences from '@ohos.data.preferences';
import commonEventManager from '@ohos.commonEventManager';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';

const TAG = 'NotifySpeedPlugin';
const METHOD_CHANNEL = 'toolbox.notify.speed/native';
const NOTIFY_ID = 1001;
const PREF_NAME = 'daily_usage_prefs';
const PREF_KEY_DAY = 'usage_day';
const PREF_KEY_BASE_WIFI = 'usage_base_wifi_rx';
const PREF_KEY_BASE_CELL = 'usage_base_cell_rx';

/**
 * 常驻通知实时网速插件(简化版)
 * startSpeedNotify 后按 interval 毫秒轮询流量字节差值并更新文本通知,
 * 按 show_daily_wifi_usage/show_daily_data_usage 开关追加每日用量文本
 */
export default class NotifySpeedPlugin implements FlutterPlugin {
  private methodChannel: MethodChannel | null = null;
  private context: common.UIAbilityContext | null = null;
  private timerId: number = -1;
  private lastRxBytes: number = 0;
  private lastTxBytes: number = 0;
  private intervalMs: number = 5000;
  // 每日用量开关(对齐 StoredPreferencesValue show_daily_wifi_usage/show_daily_data_usage)
  private showDailyWifi: boolean = false;
  private showDailyMobile: boolean = false;
  // 锁屏通知开关(对齐 notification_on_lock_screen):
  // 开=灭屏后通知继续显示在锁屏;关=灭屏即隐藏通知(对齐安卓 VISIBILITY_PUBLIC/SECRET + ScreenReceiver)
  private showOnLockScreen: boolean = false;
  private screenOff: boolean = false;
  private screenSubscriber: commonEventManager.CommonEventSubscriber | null = null;
  // 当日 0 点快照(开机以来的接口累计字节,跨日重置)
  private dayKey: string = '';
  private baseWifiRx: number = -1;
  private baseCellRx: number = -1;

  constructor(context?: common.UIAbilityContext) {
    this.context = context ?? null;
  }

  getUniqueClassName(): string {
    return 'NotifySpeedPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    const messenger = binding.getBinaryMessenger();
    this.methodChannel = new MethodChannel(messenger, METHOD_CHANNEL);
    this.methodChannel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        this.handleMethodCall(call, result);
      },
    });
  }

  onDetachedFromEngine(_binding: FlutterPluginBinding): void {
    this.stopSpeedNotify();
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  private async handleMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'requestNotificationPermission':
          result.success(await this.requestNotificationPermission());
          break;
        case 'startSpeedNotify':
          this.startSpeedNotify(call);
          result.success(true);
          break;
        case 'stopSpeedNotify':
          this.stopSpeedNotify();
          result.success(true);
          break;
        case 'updateDailyConfig': {
          // 设置页开关实时下发(对齐安卓改开关即重启 Service 刷新通知)
          this.showDailyWifi = call.argument('showDailyWifi') as boolean ?? false;
          this.showDailyMobile = call.argument('showDailyMobile') as boolean ?? false;
          result.success(true);
          break;
        }
        case 'updateLockScreenConfig': {
          // 锁屏通知开关实时下发(对齐安卓 StartNotifyIndicatorService 重建通知)
          this.showOnLockScreen = call.argument('showOnLockScreen') as boolean ?? false;
          if (this.timerId >= 0) {
            this.updateNotification();
          }
          result.success(true);
          break;
        }
        default:
          result.notImplemented();
      }
    } catch (e) {
      const errMsg = (e as Error)?.message ?? String(e);
      Log.e(TAG, `handleMethodCall ${call.method} error: ${errMsg}`);
      result.error('NOTIFY_SPEED_ERROR', errMsg, null);
    }
  }

  // ====== 请求通知授权(对齐 Android 13+ POST_NOTIFICATIONS 首次弹框) ======
  private async requestNotificationPermission(): Promise<boolean> {
    try {
      // 已开启则直接返回 true
      const enabled = await notificationManager.isNotificationEnabled();
      if (enabled) return true;
      // 无参 Promise 重载: 弹出系统"允许通知"对话框
      await notificationManager.requestEnableNotification();
      return await notificationManager.isNotificationEnabled();
    } catch (e) {
      Log.e(TAG, `requestNotificationPermission error: ${(e as Error)?.message ?? String(e)}`);
      return false;
    }
  }

  // ====== 启动常驻通知(对齐 Android startForegroundService) ======
  private startSpeedNotify(call: MethodCall): void {
    const interval = call.argument('intervalMs') as number ?? 5000;
    this.intervalMs = interval > 0 ? interval : 5000;
    this.showDailyWifi = call.argument('showDailyWifi') as boolean ?? false;
    this.showDailyMobile = call.argument('showDailyMobile') as boolean ?? false;
    this.showOnLockScreen = call.argument('showOnLockScreen') as boolean ?? false;
    if (this.timerId >= 0) return; // 已在运行,不重复启动
    this.lastRxBytes = 0;
    this.lastTxBytes = 0;
    this.screenOff = false;
    this.registerScreenEvents();
    this.timerId = setInterval((): void => {
      this.updateNotification();
    }, this.intervalMs);
    // 立即出一条通知,不等第一个周期
    this.updateNotification();
  }

  // ====== 停止常驻通知(对齐 Android stopService) ======
  private stopSpeedNotify(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.unregisterScreenEvents();
    this.screenOff = false;
    try {
      notificationManager.cancel(NOTIFY_ID);
    } catch (e) {
      Log.e(TAG, `cancel notification error: ${(e as Error)?.message ?? String(e)}`);
    }
  }

  // ====== 亮/灭屏事件 - 对齐安卓 ScreenReceiver(SCREEN_OFF/ON/USER_PRESENT) ======
  // 灭屏且锁屏通知关 → 隐藏通知(并暂停发布);亮屏/解锁 → 恢复显示
  private registerScreenEvents(): void {
    if (this.screenSubscriber !== null) return;
    try {
      const sub = commonEventManager.createSubscriberSync({
        events: [
          commonEventManager.Support.COMMON_EVENT_SCREEN_OFF,
          commonEventManager.Support.COMMON_EVENT_SCREEN_ON,
          commonEventManager.Support.COMMON_EVENT_USER_PRESENT,
        ],
      });
      commonEventManager.subscribe(sub, (err: BusinessError,
          data: commonEventManager.CommonEventData): void => {
        if (err || data === undefined) return;
        const event = data.event ?? '';
        if (event === commonEventManager.Support.COMMON_EVENT_SCREEN_OFF) {
          this.screenOff = true;
          if (!this.showOnLockScreen) {
            // 对齐安卓: 锁屏通知关时灭屏即隐藏通知
            notificationManager.cancel(NOTIFY_ID);
          }
        } else if (event === commonEventManager.Support.COMMON_EVENT_SCREEN_ON
          || event === commonEventManager.Support.COMMON_EVENT_USER_PRESENT) {
          this.screenOff = false;
          if (this.timerId >= 0) {
            this.updateNotification(); // 对齐安卓 RestartNotifying
          }
        }
      });
      this.screenSubscriber = sub;
    } catch (e) {
      Log.e(TAG, `registerScreenEvents error: ${(e as Error)?.message ?? String(e)}`);
    }
  }

  private unregisterScreenEvents(): void {
    const sub = this.screenSubscriber;
    this.screenSubscriber = null;
    if (sub === null) return;
    try {
      commonEventManager.unsubscribe(sub);
    } catch (e) {
      Log.e(TAG, `unregisterScreenEvents error: ${(e as Error)?.message ?? String(e)}`);
    }
  }

  // ====== 每日用量 - 对齐 GetAllRxBytesWiFi/Mobile(当日 0 点起 Rx 字节) ======
  // 快照持久化: 当日首次运行记下 wlan0/cellular 当前累计值,跨日重置
  private async dailyUsageTexts(): Promise<string[]> {
    const texts: string[] = ['', ''];
    if (!this.showDailyWifi && !this.showDailyMobile) return texts;
    try {
      if (this.context === null) return texts;
      const prefs =
          await dataPreferences.getPreferences(this.context, { name: PREF_NAME });
      const now = new Date();
      const today = `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`;
      const wlanNow = await statistics.getIfaceRxBytes('wlan0').catch((): number => 0);
      const cellNow = await statistics.getCellularRxBytes().catch((): number => 0);

      if (this.dayKey !== today || this.baseWifiRx < 0 || this.baseCellRx < 0) {
        // 新的一天(或插件进程首次运行): 从持久化恢复或重建快照
        const savedDay = await prefs.get(PREF_KEY_DAY, '') as string;
        if (savedDay === today) {
          this.baseWifiRx = await prefs.get(PREF_KEY_BASE_WIFI, 0) as number;
          this.baseCellRx = await prefs.get(PREF_KEY_BASE_CELL, 0) as number;
        } else {
          this.baseWifiRx = wlanNow;
          this.baseCellRx = cellNow;
          await prefs.put(PREF_KEY_DAY, today);
          await prefs.put(PREF_KEY_BASE_WIFI, wlanNow);
          await prefs.put(PREF_KEY_BASE_CELL, cellNow);
          await prefs.flush();
        }
        this.dayKey = today;
      }

      // 计数器在重启后归零,快照比当前值大时按 0 处理(对齐 GetUsageInString value<1 → -----)
      const wifiRx = Math.max(0, wlanNow - this.baseWifiRx);
      const cellRx = Math.max(0, cellNow - this.baseCellRx);
      if (this.showDailyWifi) {
        texts[0] = ` | WiFi ${this.formatUsage(wifiRx)}`;
      }
      if (this.showDailyMobile) {
        texts[1] = ` | 流量 ${this.formatUsage(cellRx)}`;
      }
    } catch (e) {
      Log.e(TAG, `dailyUsageTexts error: ${(e as Error)?.message ?? String(e)}`);
    }
    return texts;
  }

  // ====== 每 tick 更新通知文本 - 对齐 NetworkSpeedNotification 每 5000ms 刷新 ======
  private async updateNotification(): Promise<void> {
    try {
      // 灭屏且锁屏通知关 → 不再发布(对齐安卓 PauseNotifying+隐藏)
      if (this.screenOff && !this.showOnLockScreen) return;
      const rx = await statistics.getAllRxBytes();
      const tx = await statistics.getAllTxBytes();
      let downSpeed = 0;
      let upSpeed = 0;
      if (this.lastRxBytes > 0) {
        downSpeed = (rx - this.lastRxBytes) * 1000 / this.intervalMs; // 字节/秒
        upSpeed = (tx - this.lastTxBytes) * 1000 / this.intervalMs;
      }
      this.lastRxBytes = rx;
      this.lastTxBytes = tx;

      // 信号强度百分比 - 对齐 Android calculateSignalLevel(rssi, 101)
      let signalPercent = 0;
      let ssid = '';
      try {
        const info = await wifiManager.getLinkedInfo();
        if (info && info.rssi !== 0) {
          signalPercent = Math.max(0, Math.min(100, (info.rssi + 100) * 100 / 50));
          ssid = info.ssid ?? '';
        }
      } catch (e) {
        // 未连 wifi 时忽略
      }

      // 每日用量(对齐安卓通知里的 WiFi/移动 胶囊文本)
      const daily = await this.dailyUsageTexts();

      const request: notificationManager.NotificationRequest = {
        id: NOTIFY_ID,
        isOngoing: true, // 常驻通知,对齐 Android 前台服务通知
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '实时网速监测中',
            text: `下载 ${this.formatSpeed(downSpeed)} | 上传 ${this.formatSpeed(upSpeed)} | 信号 ${Math.round(signalPercent)}%${ssid.length > 0 ? ' | ' + ssid : ''}${daily[0]}${daily[1]}`,
            additionalText: '',
          },
        },
      };
      await notificationManager.publish(request);
    } catch (e) {
      Log.e(TAG, `updateNotification error: ${(e as Error)?.message ?? String(e)}`);
    }
  }

  // ====== 速度格式化 - 对齐 NetworkSpeedHelper 单位阶梯 B/KB/MB/GB ======
  private formatSpeed(bytesPerSecond: number): string {
    if (bytesPerSecond < 1024) {
      return `${bytesPerSecond.toFixed(0)}B/s`;
    } else if (bytesPerSecond < 1024 * 1024) {
      return `${(bytesPerSecond / 1024).toFixed(2)}KB/s`;
    } else if (bytesPerSecond < 1024 * 1024 * 1024) {
      return `${(bytesPerSecond / 1024 / 1024).toFixed(2)}MB/s`;
    }
    return `${(bytesPerSecond / 1024 / 1024 / 1024).toFixed(2)}GB/s`;
  }

  // ====== 用量格式化 - 对齐 GetUsageInString(TB/GB/MB/KB/B, #,##0.#) ======
  private formatUsage(bytes: number): string {
    const T = 1024.0 * 1024 * 1024 * 1024;
    const G = 1024.0 * 1024 * 1024;
    const M = 1024.0 * 1024;
    const K = 1024.0;
    if (bytes < 1) return '-----';
    if (bytes >= T) return `${(bytes / T).toFixed(1)} TB`;
    if (bytes >= G) return `${(bytes / G).toFixed(1)} GB`;
    if (bytes >= M) return `${(bytes / M).toFixed(1)} MB`;
    if (bytes >= K) return `${(bytes / K).toFixed(1)} KB`;
    return `${bytes.toFixed(0)} B`;
  }
}
