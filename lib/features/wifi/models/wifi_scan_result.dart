// WiFi 扫描结果领域 Model - 对齐 ohos wifiManager.WifiScanInfo
// 对齐 Android ScanResult + MWifiListBean(列表项展示数据)
import 'package:flutter/foundation.dart';
import 'wifi_signal_strength.dart';

@immutable
class WifiScanResult {
  final String ssid;
  final String bssid;
  final int rssi;
  final WifiSignalStrength signalLevel;
  final bool isSecured;
  final bool isConnected;

  const WifiScanResult({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.signalLevel,
    required this.isSecured,
    required this.isConnected,
  });
}
