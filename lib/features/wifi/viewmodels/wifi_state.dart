// WiFi 状态 - 不可变,对齐 Android ToolsWifiHomeFragment 的可变状态
// 流量字段 UI 隐藏但保留(对齐安卓 mRunnable 计算逻辑,后续 UI 可启用)
import 'package:flutter/foundation.dart';

/// 网络类型枚举(对齐 Android ConnectivityManager 网络判断)
enum NetworkType { wifi, mobile, none }

@immutable
class WifiState {
  // ====== loading/error 三件套(对齐 weather_state 约定) ======
  final bool isLoading;
  final String? error;

  // ====== 网络连接信息(1 秒轮询更新) ======
  /// 当前 wifi SSID(WIFI 时)或 ''(非 WIFI)
  final String currentSsid;

  /// 移动网络运营商名(MOBILE 时)或 ''
  final String carrierName;

  /// 当前网络类型
  final NetworkType networkType;

  /// wifi 是否已开启
  final bool isWifiEnabled;

  /// SSID 是否因位置权限缺失返回 <unknown ssid>(UI 提示授权位置)
  final bool isSsidUnknown;
  final int currentRssi;

  // ====== 流量统计(1 秒差值,UI 隐藏但状态保留,对齐 mRunnable) ======
  final int uploadBytes;
  final int downloadBytes;
  final double uploadSpeed;
  final double downloadSpeed;
  final String uploadUnit;
  final String downloadUnit;

  // ====== 权限 ======
  final bool permissionRequired;

  const WifiState({
    this.isLoading = false,
    this.error,
    this.currentSsid = '',
    this.carrierName = '',
    this.networkType = NetworkType.none,
    this.isWifiEnabled = false,
    this.isSsidUnknown = false,
    this.currentRssi = -60,
    this.uploadBytes = 0,
    this.downloadBytes = 0,
    this.uploadSpeed = 0,
    this.downloadSpeed = 0,
    this.uploadUnit = 'bytes',
    this.downloadUnit = 'bytes',
    this.permissionRequired = false,
  });

  WifiState copyWith({
    bool? isLoading,
    String? error,
    String? currentSsid,
    String? carrierName,
    NetworkType? networkType,
    bool? isWifiEnabled,
    bool? isSsidUnknown,
    int? currentRssi,
    int? uploadBytes,
    int? downloadBytes,
    double? uploadSpeed,
    double? downloadSpeed,
    String? uploadUnit,
    String? downloadUnit,
    bool? permissionRequired,
    bool clearError = false,
  }) {
    return WifiState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentSsid: currentSsid ?? this.currentSsid,
      carrierName: carrierName ?? this.carrierName,
      networkType: networkType ?? this.networkType,
      isWifiEnabled: isWifiEnabled ?? this.isWifiEnabled,
      isSsidUnknown: isSsidUnknown ?? this.isSsidUnknown,
      currentRssi: currentRssi ?? this.currentRssi,
      uploadBytes: uploadBytes ?? this.uploadBytes,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadUnit: uploadUnit ?? this.uploadUnit,
      downloadUnit: downloadUnit ?? this.downloadUnit,
      permissionRequired: permissionRequired ?? this.permissionRequired,
    );
  }
}
