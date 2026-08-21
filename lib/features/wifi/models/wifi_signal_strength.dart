// WiFi 信号强度枚举 - 对齐 Android WifiManager.calculateSignalLevel 5 级
// 对齐 ClearLib MWifiListBean.SignalStrength + item_my_wifi_list 图标
// 安卓 5 级图标: disabled/low/med/high/excellent(安卓拼写 excelent)
enum WifiSignalStrength {
  disabled,  // 0 级
  low,       // 1 级
  medium,    // 2 级
  high,      // 3 级
  excellent, // 4 级
  ;

  /// 根据 RSSI 计算 signal level
  /// 阈值对齐安卓常见 5 级分档: -100/-85/-70/-55
  factory WifiSignalStrength.fromRssi(int rssi) {
    if (rssi <= -100) return WifiSignalStrength.disabled;
    if (rssi <= -85) return WifiSignalStrength.low;
    if (rssi <= -70) return WifiSignalStrength.medium;
    if (rssi <= -55) return WifiSignalStrength.high;
    return WifiSignalStrength.excellent;
  }

  /// 索引值 0-4,用于查表选图标
  int get level => index;
}
