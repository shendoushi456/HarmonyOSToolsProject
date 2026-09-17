// toolbox_c WiFi 列表 ViewModel - 对齐 Android WiFiListActivity 的 WifiReceiver+sortScaResult
// 鸿蒙无法主动 startScan: 拉系统缓存 + 订阅扫描完成事件被动刷新
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/wifi_native_channel.dart';
import '../utils/wifi_box_support.dart';

@immutable
class WifiBoxListState {
  /// 去重+排序后的列表(对齐 noSameName + Collections.sort)
  final List<WifiBoxEntry> entries;
  final bool isScanning;

  const WifiBoxListState({
    this.entries = const [],
    this.isScanning = false,
  });
}

class WifiBoxListViewModel extends Notifier<WifiBoxListState> {
  final WifiNativeChannel _channel = WifiNativeChannel.instance;
  StreamSubscription<dynamic>? _scanSub;
  bool _emptyConfirmed = false;

  @override
  WifiBoxListState build() {
    // 对齐安卓 onResume 注册 WifiReceiver: 订阅扫描完成事件
    _scanSub = _channel.onScanFinishedStream.listen((_) => refreshCache());
    Future.microtask(_init);
    ref.onDispose(() {
      _scanSub?.cancel();
      _scanSub = null;
    });
    return const WifiBoxListState();
  }

  Future<void> _init() async {
    // 对齐安卓收到广播后隐藏空态: 首次拉到数据后空态不再出现
    await refreshCache();
  }

  /// 拉取系统扫描缓存并按安卓规则整理
  Future<void> refreshCache() async {
    try {
      state = state.copyWith(isScanning: true);
      final dtoList = await _channel.getScanInfoList();
      final entries = dtoList
          .map((dto) => WifiBoxEntry(
                ssid: dto.ssid,
                bssid: dto.bssid,
                rssi: dto.rssi,
                frequency: dto.frequency,
                capabilities: dto.capabilities,
              ))
          .toList();
      final deduped = WifiBoxSupport.noSameName(entries);
      deduped.sort(WifiBoxSupport.compare);
      if (deduped.isNotEmpty) _emptyConfirmed = true;
      state = WifiBoxListState(entries: deduped);
    } catch (_) {
      // 对齐安卓 try-catch 静默
      state = state.copyWith(isScanning: false);
    }
  }

  /// 空态是否仍显示(对齐 animation_view: 收到扫描结果后 GONE 且不再恢复)
  bool get showEmpty => !_emptyConfirmed;
}

/// toolbox_c WiFi 列表 Provider
final wifiBoxListProvider =
    NotifierProvider<WifiBoxListViewModel, WifiBoxListState>(
        WifiBoxListViewModel.new);

extension _Copy on WifiBoxListState {
  WifiBoxListState copyWith({List<WifiBoxEntry>? entries, bool? isScanning}) {
    return WifiBoxListState(
      entries: entries ?? this.entries,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}
