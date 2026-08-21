// WiFi 列表 ViewModel - 对齐 Android ClearLib NewWifiListViewModel + HomeWifiListViewModel
// 数据流: 系统扫描完成事件(onScanFinishedStream) → getScanResults(去重+排序) → state.wifiList
// 鸿蒙三方应用无法主动 startScan, 进入页面调一次缓存 + 订阅事件被动刷新
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/wifi_repository.dart';
import 'wifi_list_state.dart';

class WifiListViewModel extends Notifier<WifiListState> {
  final WifiRepository _repository = WifiRepository();
  StreamSubscription<dynamic>? _scanSub;

  @override
  WifiListState build() {
    // 进入页面立即调一次 getScanResults 拿系统缓存
    Future.microtask(refreshCache);
    // 订阅系统扫描完成事件,被动刷新(对齐安卓 WIFI_SCAN_RESULTS_AVAILABLE_ACTION 广播)
    _scanSub = _repository.onScanFinishedStream.listen((_) {
      refreshCache();
    });
    ref.onDispose(() {
      _scanSub?.cancel();
      _scanSub = null;
    });
    return const WifiListState(isScanning: true);
  }

  /// 刷新缓存: 调 getScanInfoList 拿系统最近扫描结果
  /// 鸿蒙无法主动 startScan, 这是唯一的刷新方式
  Future<void> refreshCache() async {
    state = state.copyWith(isScanning: true, clearError: true);
    try {
      // 先获取当前连接 bssid,用于标记列表项 isConnected
      final conn = await _repository.getCurrentConnection();
      final connectedBssid = conn?.bssid ?? '';
      final list = await _repository.getScanResults(
        connectedBssid: connectedBssid,
      );
      state = state.copyWith(
        wifiList: list,
        isScanning: false,
        lastScanTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: e.toString(),
      );
    }
  }
}

/// WiFi 列表 ViewModel Provider
final wifiListViewModelProvider =
    NotifierProvider<WifiListViewModel, WifiListState>(WifiListViewModel.new);
