// WiFi 列表状态 - 不可变,对齐 Android ClearLib HomeWifiListViewModel 的 LiveData
import 'package:flutter/foundation.dart';
import '../models/wifi_scan_result.dart';

@immutable
class WifiListState {
  /// 附近 wifi 列表(已去重 + 按 signal level 排序)
  final List<WifiScanResult> wifiList;

  /// 是否正在扫描/刷新缓存
  final bool isScanning;

  /// 上次扫描刷新时间
  final DateTime? lastScanTime;

  /// 错误信息
  final String? error;

  const WifiListState({
    this.wifiList = const [],
    this.isScanning = false,
    this.lastScanTime,
    this.error,
  });

  WifiListState copyWith({
    List<WifiScanResult>? wifiList,
    bool? isScanning,
    DateTime? lastScanTime,
    String? error,
    bool clearError = false,
  }) {
    return WifiListState(
      wifiList: wifiList ?? this.wifiList,
      isScanning: isScanning ?? this.isScanning,
      lastScanTime: lastScanTime ?? this.lastScanTime,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
