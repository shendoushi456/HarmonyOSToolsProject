// WiFi 原生通道封装 - 对接 ohos/entry/src/main/ets/plugins/WifiPlugin.ets
// MethodChannel('qingman.wifi/native') + EventChannel('qingman.wifi/scan_events')
import 'dart:async';
import 'package:flutter/services.dart';
import '../../features/wifi/models/wifi_dto.dart';

/// WiFi 原生能力通道,单例
class WifiNativeChannel {
  WifiNativeChannel._();
  static final WifiNativeChannel instance = WifiNativeChannel._();

  static const MethodChannel _method = MethodChannel('qingman.wifi/native');
  static const EventChannel _events = EventChannel('qingman.wifi/scan_events');

  /// 当前 wifi 连接信息(对齐 Android WifiManager.getConnectionInfo)
  Future<WifiLinkedInfoDTO?> getLinkedInfo() async {
    final result = await _method.invokeMethod<Map>('getLinkedInfo');
    if (result == null) return null;
    return WifiLinkedInfoDTO.fromMap(result);
  }

  /// 附近 wifi 扫描结果(对齐 Android WifiManager.getScanResults)
  /// 鸿蒙三方应用无法主动 startScan, 返回系统最近一次扫描缓存
  Future<List<WifiScanInfoDTO>> getScanInfoList() async {
    final list = await _method.invokeMethod<List>('getScanInfoList') ?? [];
    return list.map((e) => WifiScanInfoDTO.fromMap(e as Map)).toList();
  }

  /// wifi 是否已开启(对齐 Android WifiManager.isWifiEnabled)
  Future<bool> isWifiActive() async =>
      (await _method.invokeMethod<bool>('isWifiActive')) ?? false;

  /// 请求读取 Wi-Fi 列表所需的位置权限。
  /// HarmonyOS 会在未授权时脱敏 SSID 或拒绝读取扫描缓存。
  Future<bool> requestWifiPermissions() async =>
      (await _method.invokeMethod<bool>('requestWifiPermissions')) ?? false;

  /// 总接收字节数(对齐 Android TrafficStats.getTotalRxBytes)
  Future<int> getAllRxBytes() async =>
      (await _method.invokeMethod<int>('getAllRxBytes')) ?? 0;

  /// 总发送字节数(对齐 Android TrafficStats.getTotalTxBytes)
  Future<int> getAllTxBytes() async =>
      (await _method.invokeMethod<int>('getAllTxBytes')) ?? 0;

  /// 网络类型(对齐 Android ConnectivityManager 网络判断)
  /// 返回 'wifi' / 'mobile' / 'none'
  Future<String> getNetworkType() async =>
      (await _method.invokeMethod<String>('getNetworkType')) ?? 'none';

  /// 运营商名(对齐 Android TelephonyManager.getNetworkOperatorName)
  Future<String> getOperatorName() async =>
      (await _method.invokeMethod<String>('getOperatorName')) ?? '';

  /// 尝试跳转系统 Wi-Fi 设置页。
  /// 返回 false 表示当前系统未对三方应用开放该入口，应引导用户手动前往设置。
  Future<bool> openWifiSettings() async =>
      (await _method.invokeMethod<bool>('openWifiSettings')) ?? false;

  /// wifi 扫描完成事件流(对齐 Android WIFI_SCAN_RESULTS_AVAILABLE_ACTION 广播)
  /// 系统周期性扫描完成后触发,客户端据此刷新 getScanInfoList
  Stream<dynamic> get onScanFinishedStream => _events.receiveBroadcastStream();
}
