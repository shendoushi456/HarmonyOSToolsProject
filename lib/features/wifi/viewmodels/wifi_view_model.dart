// WiFi ViewModel - 对齐 Android ToolsWifiHomeFragment 的两个 1 秒 Handler
// mRunnable(TrafficStats 流量轮询) + 网络状态轮询(调 ToolsMainActivity.getNetworkType/getCurrentSsid)
// 这是项目首例定时器: 用 Timer.periodic + ref.onDispose 管理生命周期
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/wifi_repository.dart';
import 'wifi_state.dart';

/// 流量速度格式化结果(对齐 Android DecimalFormat ##.## + 1024 进制)
class FormattedSpeed {
  final double value;
  final String unit;
  const FormattedSpeed(this.value, this.unit);
}

class WifiViewModel extends Notifier<WifiState> {
  final WifiRepository _repository = WifiRepository();
  Timer? _timer;
  int _lastRxBytes = 0;
  int _lastTxBytes = 0;
  bool _baselineReady = false;

  @override
  WifiState build() {
    // 启动 1 秒轮询(对齐安卓两个 Handler.postDelayed 1000ms)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _poll());
    // 初始化基线字节 + 首次拉取(用 microtask 解决 build 不能 await)
    Future.microtask(_init);
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    return const WifiState(isLoading: true);
  }

  /// 初始化基线流量字节 + 首次轮询(对齐安卓 onViewCreated 设置 mStartRX/mStartTX)
  Future<void> _init() async {
    try {
      final traffic = await _repository.getTrafficBytes();
      _lastRxBytes = traffic.rxBytes;
      _lastTxBytes = traffic.txBytes;
      _baselineReady = true;
      await _poll();
      state = state.copyWith(isLoading: false);
    } catch (_) {
      // 基线失败不阻塞 UI,后续轮询会重试
      state = state.copyWith(isLoading: false);
    }
  }

  /// 1 秒轮询: 拉取网络状态 + 流量差值(对齐 mRunnable + 网络状态 Runnable)
  Future<void> _poll() async {
    try {
      // 1. 网络类型
      final netTypeStr = await _repository.getNetworkType();
      final netType = _parseNetType(netTypeStr);

      // 2. 当前连接信息 + 运营商名
      String ssid = '';
      String carrier = '';
      bool wifiEnabled = false;
      bool ssidUnknown = false;
      if (netType == NetworkType.wifi) {
        wifiEnabled = await _repository.isWifiEnabled();
        final conn = await _repository.getCurrentConnection();
        ssid = conn?.ssid ?? '';
        // 鸿蒙 API 12+ 无位置权限时 SSID 返回 <unknown ssid>
        if (conn != null && conn.isUnknownSsid) {
          ssidUnknown = true;
          ssid = '已连接 Wi-Fi';
        }
      } else if (netType == NetworkType.mobile) {
        carrier = await _repository.getCarrierName();
      }

      // 3. 流量差值(对齐 mRunnable: totalRxBytes - mStartRX)
      final traffic = await _repository.getTrafficBytes();
      int rxDiff = 0;
      int txDiff = 0;
      if (_baselineReady) {
        rxDiff = traffic.rxBytes - _lastRxBytes;
        txDiff = traffic.txBytes - _lastTxBytes;
        if (rxDiff < 0) rxDiff = 0;
        if (txDiff < 0) txDiff = 0;
      }
      _lastRxBytes = traffic.rxBytes;
      _lastTxBytes = traffic.txBytes;
      _baselineReady = true;

      // 4. 单位换算(对齐 DecimalFormat ##.## + 1024 进制)
      final up = _formatBytes(txDiff);
      final down = _formatBytes(rxDiff);

      state = state.copyWith(
        currentSsid: ssid,
        carrierName: carrier,
        networkType: netType,
        isWifiEnabled: wifiEnabled,
        isSsidUnknown: ssidUnknown,
        uploadBytes: txDiff,
        downloadBytes: rxDiff,
        uploadSpeed: up.value,
        uploadUnit: up.unit,
        downloadSpeed: down.value,
        downloadUnit: down.unit,
        clearError: true,
      );
    } catch (_) {
      // 静默错误,避免每秒刷屏(对齐安卓 try-catch Log.e)
    }
  }

  /// 详情卡点击触发权限二次校验(对齐 checkAndRequestWifiPermissions)
  /// 阶段 5 接入 permission_handler 完整实现
  Future<void> checkAndRequestPermissions() async {
    // TODO 阶段 5: 用 permission_handler_ohos 申请 LOCATION/APPROXIMATELY_LOCATION
  }

  /// 跳转系统 wifi 设置页(列表项点击确认后调用)
  Future<void> openWifiSettings() async {
    await _repository.openWifiSettings();
  }

  /// 手动刷新(对齐安卓进入页面触发一次拉取)
  Future<void> refresh() async => _poll();

  /// 字节单位换算(对齐 mRunnable 的 bytes/KBs/MBs/GBs 1024 进制)
  FormattedSpeed _formatBytes(int bytes) {
    if (bytes <= 0) return const FormattedSpeed(0.0, 'bytes');
    double v = bytes.toDouble();
    String unit = 'bytes';
    if (v >= 1024) {
      v /= 1024;
      unit = 'KBs';
      if (v >= 1024) {
        v /= 1024;
        unit = 'MBs';
        if (v >= 1024) {
          v /= 1024;
          unit = 'GBs';
        }
      }
    }
    // 对齐 DecimalFormat ##.## 保留两位
    v = double.parse(v.toStringAsFixed(2));
    return FormattedSpeed(v, unit);
  }

  NetworkType _parseNetType(String s) {
    switch (s) {
      case 'wifi':
        return NetworkType.wifi;
      case 'mobile':
        return NetworkType.mobile;
      default:
        return NetworkType.none;
    }
  }
}

/// WiFi 主页 ViewModel Provider
final wifiViewModelProvider =
    NotifierProvider<WifiViewModel, WifiState>(WifiViewModel.new);
