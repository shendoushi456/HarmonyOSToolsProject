// WiFi 鸿蒙原生插件 - 对齐 Android WifiManager/TrafficStats/ConnectivityManager/TelephonyManager
// 实现 FlutterPlugin 接口, 暴露 8 个 MethodChannel 方法 + 1 个 EventChannel(扫描完成事件)
// 对应 Dart 端 lib/core/network/wifi_native_channel.dart
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodChannel,
  MethodCall,
  MethodResult,
  EventChannel,
  EventSink,
  Log,
} from '@ohos/flutter_ohos';
import wifiManager from '@ohos.wifi';
import abilityAccessCtrl, { PermissionRequestResult, Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import statistics from '@ohos.net.statistics';
import connection from '@ohos.net.connection';
import radio from '@ohos.telephony.radio';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';

const TAG = 'WifiPlugin';
const METHOD_CHANNEL = 'qingman.wifi/native';
const EVENT_CHANNEL = 'qingman.wifi/scan_events';
const WIFI_LOCATION_PERMISSIONS: Permissions[] = [
  'ohos.permission.APPROXIMATELY_LOCATION',
  'ohos.permission.LOCATION',
];

// ArkTS 严格模式要求对象字面量对应显式 interface(arkts-no-untyped-obj-literals)
// 跳转系统 wifi 设置页的 Want 参数(隐式 action 方式)
interface WifiSettingsActionWant {
  action: string;
}

/**
 * WiFi 原生插件
 * 鸿蒙三方应用无法主动 startScan, 只能调 getScanInfos() 拿系统缓存或订阅 wifiScanStateChange 事件
 */
export default class WifiPlugin implements FlutterPlugin {
  private methodChannel: MethodChannel | null = null;
  private eventChannel: EventChannel | null = null;
  private context: common.Context | null = null;
  private eventSink: EventSink | null = null;
  private readonly uiContext: common.UIAbilityContext | null;

  constructor(context?: common.UIAbilityContext) {
    this.uiContext = context ?? null;
  }

  getUniqueClassName(): string {
    return 'WifiPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext();
    const messenger = binding.getBinaryMessenger();

    // MethodChannel - 处理 Dart 端方法调用
    this.methodChannel = new MethodChannel(messenger, METHOD_CHANNEL);
    this.methodChannel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        this.handleMethodCall(call, result);
      },
    });

    // EventChannel - 转发 wifiManager.on('wifiScanStateChange') 事件
    this.eventChannel = new EventChannel(messenger, EVENT_CHANNEL);
    this.eventChannel.setStreamHandler({
      onListen: (_args: ESObject, events: EventSink): void => {
        this.startScanListening(events);
      },
      onCancel: (_args: ESObject): void => {
        this.stopScanListening();
      },
    });
  }

  onDetachedFromEngine(_binding: FlutterPluginBinding): void {
    this.stopScanListening();
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
    this.eventChannel = null;
    this.context = null;
  }

  // ====== MethodChannel 方法分发 ======
  private async handleMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'getLinkedInfo':
          result.success(await this.getLinkedInfo());
          break;
        case 'getScanInfoList':
          result.success(await this.getScanInfoList());
          break;
        case 'isWifiActive':
          result.success(this.isWifiActive());
          break;
        case 'requestWifiPermissions':
          result.success(await this.requestWifiPermissions());
          break;
        case 'getAllRxBytes':
          result.success(await this.getAllRxBytes());
          break;
        case 'getAllTxBytes':
          result.success(await this.getAllTxBytes());
          break;
        case 'getNetworkType':
          result.success(await this.getNetworkType());
          break;
        case 'getOperatorName':
          result.success(await this.getOperatorName());
          break;
        case 'openWifiSettings':
          result.success(await this.openWifiSettings());
          break;
        default:
          result.notImplemented();
      }
    } catch (e) {
      const errMsg = (e as Error)?.message ?? String(e);
      Log.e(TAG, `handleMethodCall ${call.method} error: ${errMsg}`);
      result.error('WIFI_ERROR', errMsg, null);
    }
  }

  // ====== 当前 wifi 连接信息 - 对齐 Android WifiManager.getConnectionInfo ======
  // 注意: ohos WifiLinkedInfo 无 securityType 字段(只有 WifiScanInfo 有), 这里不返回该字段
  private async getLinkedInfo(): Promise<Record<string, Object> | null> {
    try {
      const info = await wifiManager.getLinkedInfo();
      if (!info) return null;
      const result: Record<string, Object> = {
        'ssid': info.ssid ?? '',
        'bssid': info.bssid ?? '',
        'rssi': info.rssi ?? 0,
        'band': info.band ?? 0,
        'frequency': info.frequency ?? 0,
        'linkSpeed': info.linkSpeed ?? 0,
        'isHidden': info.isHidden ?? false,
        'connState': info.connState ?? 0,
      };
      return result;
    } catch (e) {
      Log.e(TAG, `getLinkedInfo error: ${(e as Error)?.message ?? String(e)}`);
      return null;
    }
  }

  // ====== 附近 wifi 扫描结果 - 对齐 Android WifiManager.getScanResults ======
  // 鸿蒙三方应用无法主动 startScan, 这里返回系统最近一次扫描的缓存
  // API 名为 getScanInfos(非 getScanInfoList)
  private async getScanInfoList(): Promise<Array<Record<string, Object>>> {
    try {
      const list: Array<wifiManager.WifiScanInfo> = await wifiManager.getScanInfos();
      if (!list || list.length === 0) return [];
      const result: Array<Record<string, Object>> = [];
      for (const item of list) {
        const entry: Record<string, Object> = {
          'ssid': item.ssid ?? '',
          'bssid': item.bssid ?? '',
          'capabilities': item.capabilities ?? '',
          'securityType': item.securityType ?? 0,
          'rssi': item.rssi ?? 0,
          'band': item.band ?? 0,
          'frequency': item.frequency ?? 0,
          'channelWidth': item.channelWidth ?? 0,
          'timestamp': item.timestamp ?? 0,
        };
        result.push(entry);
      }
      return result;
    } catch (e) {
      Log.e(TAG, `getScanInfoList error: ${(e as Error)?.message ?? String(e)}`);
      return [];
    }
  }

  // ====== wifi 是否开启 - 对齐 Android WifiManager.isWifiEnabled ======
  private isWifiActive(): boolean {
    try {
      return wifiManager.isWifiActive();
    } catch (e) {
      Log.e(TAG, `isWifiActive error: ${(e as Error)?.message ?? String(e)}`);
      return false;
    }
  }

  // ====== 运行时授权 - 对齐 Android 10+ 读取 Wi-Fi 时需要的位置权限 ======
  private async requestWifiPermissions(): Promise<boolean> {
    if (this.uiContext === null) {
      throw new Error('无法获取 UIAbility 上下文以请求 Wi-Fi 权限');
    }
    const manager = abilityAccessCtrl.createAtManager();
    const bundleInfo = await bundleManager.getBundleInfoForSelf(
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION,
    );
    const accessTokenId = bundleInfo.appInfo.accessTokenId;
    // 近似位置已经足够读取附近 Wi-Fi；精确位置是可选增强项。
    let locationGranted = false;
    for (const permission of WIFI_LOCATION_PERMISSIONS) {
      const grant = await manager.checkAccessToken(accessTokenId, permission);
      if (grant === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        locationGranted = true;
      }
    }
    if (locationGranted) return true;

    const response: PermissionRequestResult = await manager.requestPermissionsFromUser(
      this.uiContext,
      WIFI_LOCATION_PERMISSIONS,
    );
    return response.authResults.some((result: number) => result === 0);
  }

  // ====== 总接收字节数 - 对齐 Android TrafficStats.getTotalRxBytes ======
  private async getAllRxBytes(): Promise<number> {
    try {
      return await statistics.getAllRxBytes();
    } catch (e) {
      Log.e(TAG, `getAllRxBytes error: ${(e as Error)?.message ?? String(e)}`);
      return 0;
    }
  }

  // ====== 总发送字节数 - 对齐 Android TrafficStats.getTotalTxBytes ======
  private async getAllTxBytes(): Promise<number> {
    try {
      return await statistics.getAllTxBytes();
    } catch (e) {
      Log.e(TAG, `getAllTxBytes error: ${(e as Error)?.message ?? String(e)}`);
      return 0;
    }
  }

  // ====== 网络类型 - 对齐 Android ConnectivityManager.getActiveNetworkInfo.getTypeName ======
  // 返回 'wifi' / 'mobile' / 'none'
  private async getNetworkType(): Promise<string> {
    try {
      if (!connection.hasDefaultNet()) return 'none';
      const netHandle = await connection.getDefaultNet();
      if (!netHandle) return 'none';
      const capabilities = await connection.getNetCapabilities(netHandle);
      const bearers = capabilities?.bearerTypes ?? [];
      if (bearers.includes(connection.NetBearType.BEARER_WIFI)) {
        return 'wifi';
      }
      if (bearers.includes(connection.NetBearType.BEARER_CELLULAR)) {
        return 'mobile';
      }
      return 'none';
    } catch (e) {
      Log.e(TAG, `getNetworkType error: ${(e as Error)?.message ?? String(e)}`);
      return 'none';
    }
  }

  // ====== 运营商名 - 对齐 Android TelephonyManager.getNetworkOperatorName ======
  private async getOperatorName(): Promise<string> {
    try {
      return await radio.getOperatorName(0);
    } catch (e) {
      Log.e(TAG, `getOperatorName error: ${(e as Error)?.message ?? String(e)}`);
      return '';
    }
  }

  // ====== 跳转系统 wifi 设置页 ======
  /**
   * 打开系统无线设置。
   *
   * 1) 优先显式 Want 直跳华为设置应用的 WLAN 页:
   *    uri 必须是 'wifi_entry'(设置应用的可路由页面标识)。
   *    若误用 'wifi' 等未注册标识, 设置应用被拉起后路由失败会显示白屏;
   *    公开 action 'ohos.settings.wireless' 在 HarmonyOS NEXT 真机上则
   *    无 Ability 响应, startAbility 匹配失败会弹系统 toast"暂无可用打开方式"。
   * 2) 回退隐式 action 方式, 仅保留给部分可解析该 action 的系统版本。
   */
  private async openWifiSettings(): Promise<boolean> {
    if (this.uiContext === null) {
      Log.e(TAG, 'openWifiSettings skipped: UIAbility context is unavailable');
      return false;
    }
    // 1) 显式 Want: 设置应用包名/入口 + uri 定位 WLAN 页
    const explicitWant: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'wifi_entry',
    };
    try {
      await this.uiContext.startAbility(explicitWant);
      return true;
    } catch (e) {
      Log.w(TAG, `openWifiSettings explicit want failed: ${(e as Error)?.message ?? String(e)}`);
    }
    // 2) 回退: 隐式 action 方式
    const want: WifiSettingsActionWant = { action: 'ohos.settings.wireless' };
    try {
      await this.uiContext.startAbility(want);
      return true;
    } catch (e) {
      const message = (e as Error)?.message ?? String(e);
      Log.w(TAG, `openWifiSettings is unavailable on this device: ${message}`);
      return false;
    }
  }

  // ====== EventChannel: 订阅系统扫描完成事件 ======
  // 直接转发 state(number) 给 Dart 端,避免无类型对象字面量
  private startScanListening(events: EventSink): void {
    this.eventSink = events;
    try {
      wifiManager.on('wifiScanStateChange', (state: number) => {
        try {
          this.eventSink?.success(state);
        } catch (e) {
          Log.e(TAG, `scanStateChange sink error: ${(e as Error)?.message ?? String(e)}`);
        }
      });
    } catch (e) {
      Log.e(TAG, `startScanListening error: ${(e as Error)?.message ?? String(e)}`);
    }
  }

  private stopScanListening(): void {
    try {
      wifiManager.off('wifiScanStateChange');
    } catch (e) {
      // 忽略未注册的回调清理异常
    }
    this.eventSink = null;
  }
}
