// WiFi 连接信息领域 Model - 对齐 ohos wifiManager.WifiLinkedInfo
// 对齐 Android WifiInfo (ssid/bssid/rssi/securityType/frequency/linkSpeed)
import 'package:flutter/foundation.dart';

@immutable
class WifiInfo {
  final String ssid;
  final String bssid;
  final int rssi;
  final int securityType;
  final int frequency;
  final int linkSpeed;
  final bool isConnected;

  const WifiInfo({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.securityType,
    required this.frequency,
    required this.linkSpeed,
    required this.isConnected,
  });

  /// 是否为未知 SSID(鸿蒙 API 12+ 无位置权限时返回 "<unknown ssid>")
  bool get isUnknownSsid => ssid.isEmpty || ssid == '<unknown ssid>';
}
