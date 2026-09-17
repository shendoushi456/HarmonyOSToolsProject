// 应用内悬浮网速浮层 - 对齐 Android wifimeter/FloatingWindow.java(简化版)
// 差异说明: 鸿蒙三方应用无法申请 SYSTEM_FLOAT_WINDOW 跨应用悬浮(且本 SDK 的
// window 子窗口 API 对 Stage 模型封闭),故以 Flutter 浮层实现:
// 挂载于 MaterialApp.builder(全局路由之上,整个 APP 页面均可见),
// 可拖动,右上角带关闭按钮,实时网速每秒刷新(TrafficStats 差值)
// 显示内容由浮窗设置三开关控制(floatWindowConfigProvider,对齐 total_vis/
// down_vis/up_vis): 显示总速度 / 每日WiFi数据 / 每日移动数据
// 每日用量对齐安卓 GetAllRxBytesWiFi/Mobile 语义: wlan0/cellular 接口
// 当日 0 点快照差值,快照存 SP 跨天自动重置(重启计数器归零属近似)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/wifi_native_channel.dart';
import '../../../../core/storage/prefs_storage.dart';
import '../../wifi/repositories/wifi_repository.dart';
import '../viewmodels/float_speed_provider.dart';

/// 悬浮网速浮层(半透明深底圆角,默认右上角,可拖动,右上角×关闭,每秒刷新)
class WifiSpeedOverlay extends ConsumerStatefulWidget {
  const WifiSpeedOverlay({super.key});

  @override
  ConsumerState<WifiSpeedOverlay> createState() => _WifiSpeedOverlayState();
}

class _WifiSpeedOverlayState extends ConsumerState<WifiSpeedOverlay> {
  final WifiRepository _repository = WifiRepository();
  final WifiNativeChannel _channel = WifiNativeChannel.instance;
  Timer? _timer;
  int _lastRx = 0;
  int _lastTx = 0;
  bool _baselineReady = false;
  String _downText = '0 B/s';
  String _upText = '0 B/s';
  String _totalText = '0 B/s';
  String _ssid = '';
  String _dailyWifiText = '';
  String _dailyMobileText = '';

  // 当日快照(SP 持久化,跨天重置;重启计数器归零属近似)
  static const String _kDay = 'overlay_usage_day';
  static const String _kBaseWifi = 'overlay_base_wifi_rx';
  static const String _kBaseCell = 'overlay_base_cell_rx';

  static const double _w = 210;

  Offset? _position; // 拖动后的位置(null=默认右上角)

  @override
  void initState() {
    super.initState();
    // 对齐安卓 FloatingWindow: 每 1000ms 刷新一次网速
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _poll());
    Future.microtask(_poll);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      final traffic = await _repository.getTrafficBytes();
      if (_baselineReady) {
        final rxDiff = traffic.rxBytes - _lastRx;
        final txDiff = traffic.txBytes - _lastTx;
        setState(() {
          _downText = _formatSpeed(rxDiff > 0 ? rxDiff : 0);
          _upText = _formatSpeed(txDiff > 0 ? txDiff : 0);
          // 总速度 = 下载+上传(对齐安卓浮窗"显示总速度")
          _totalText =
              _formatSpeed((rxDiff > 0 ? rxDiff : 0) + (txDiff > 0 ? txDiff : 0));
        });
      }
      _lastRx = traffic.rxBytes;
      _lastTx = traffic.txBytes;
      _baselineReady = true;
      final conn = await _repository.getCurrentConnection();
      await _pollDailyUsage();
      if (mounted) {
        setState(() => _ssid = conn?.ssid ?? '');
      }
    } catch (_) {
      // 静默(对齐安卓 try-catch)
    }
  }

  /// 每日 WiFi/移动用量 - 对齐安卓 querySummaryForDevice 当日 0 点起 Rx:
  /// wlan0/cellular 接口累计值的当日快照差值,快照存 SP 跨天重置
  Future<void> _pollDailyUsage() async {
    try {
      final now = DateTime.now();
      final today = '${now.year}-${now.month}-${now.day}';
      final stored = PrefsStorage.getString(_kDay);
      final baseWifi = PrefsStorage.getInt(_kBaseWifi);
      final baseCell = PrefsStorage.getInt(_kBaseCell);
      if (stored != today || baseWifi == null || baseCell == null) {
        // 新的一天(或首次): 记录当日基准(接口累计值≈当日已用流量)
        final wifiNow = await _channel.getWifiRxBytes();
        final cellNow = await _channel.getCellularRxBytes();
        await PrefsStorage.setString(_kDay, today);
        await PrefsStorage.setInt(_kBaseWifi, wifiNow);
        await PrefsStorage.setInt(_kBaseCell, cellNow);
        if (!mounted) return;
        setState(() {
          _dailyWifiText = _formatUsage(0);
          _dailyMobileText = _formatUsage(0);
        });
        return;
      }
      final wifiNow = await _channel.getWifiRxBytes();
      final cellNow = await _channel.getCellularRxBytes();
      if (!mounted) return;
      setState(() {
        _dailyWifiText = _formatUsage(wifiNow - baseWifi);
        _dailyMobileText = _formatUsage(cellNow - baseCell);
      });
    } catch (_) {
      // 静默
    }
  }

  /// 速度格式化 - 单位阶梯 B/KB/MB/GB(对齐安卓浮窗格式化)
  String _formatSpeed(int bytes) {
    double v = bytes.toDouble();
    if (v < 1024) return '${v.toStringAsFixed(0)} B/s';
    v /= 1024;
    if (v < 1024) return '${v.toStringAsFixed(2)} KB/s';
    v /= 1024;
    if (v < 1024) return '${v.toStringAsFixed(2)} MB/s';
    v /= 1024;
    return '${v.toStringAsFixed(2)} GB/s';
  }

  /// 用量格式化 - 对齐安卓 GetUsageInString(不足 1B 显示 -----)
  String _formatUsage(int bytes) {
    if (bytes < 1) return '-----';
    double v = bytes.toDouble();
    if (v < 1024) return '${v.toStringAsFixed(0)} B';
    v /= 1024;
    if (v < 1024) return '${v.toStringAsFixed(1)} KB';
    v /= 1024;
    if (v < 1024) return '${v.toStringAsFixed(1)} MB';
    v /= 1024;
    if (v < 1024) return '${v.toStringAsFixed(1)} GB';
    v /= 1024;
    return '${v.toStringAsFixed(1)} TB';
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(floatWindowConfigProvider);
    final size = MediaQuery.of(context).size;
    final pos = _position ??
        Offset(size.width - _w - 8, MediaQuery.of(context).padding.top + 4);
    final maxDy = (size.height - 220).clamp(0.0, double.infinity);

    return Positioned(
      left: pos.dx.clamp(0, size.width - _w),
      top: pos.dy.clamp(0, maxDy),
      child: GestureDetector(
        // 拖动(对齐安卓 FloatingWindow 可拖动浮窗)
        onPanUpdate: (d) {
          setState(() {
            _position = Offset(
              (pos.dx + d.delta.dx).clamp(0, size.width - _w),
              (pos.dy + d.delta.dy).clamp(0, maxDy),
            );
          });
        },
        child: Container(
          width: _w,
          padding:
              const EdgeInsets.only(left: 8, right: 4, top: 3, bottom: 5),
          decoration: BoxDecoration(
            color: const Color(0xB3263443), // 半透明深蓝,对齐安卓浮窗底色风格
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SSID + 关闭按钮
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _ssid.isEmpty ? '网速' : _ssid,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                  // 右上角关闭按钮
                  GestureDetector(
                    onTap: () => ref
                        .read(floatSpeedProvider.notifier)
                        .setShowing(false),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child:
                          Icon(Icons.close, size: 12, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              // 下载/上传
              Row(
                children: [
                  Text('↓$_downText',
                      style: const TextStyle(
                          color: Color(0xFFFF812E), fontSize: 10)),
                  const Spacer(),
                  Text('↑$_upText',
                      style: const TextStyle(
                          color: Color(0xFF32CDFF), fontSize: 10)),
                ],
              ),
              // 总速度(显示总速度开关,对齐 total_vis)
              if (config.showTotal)
                Text('总 $_totalText',
                    style:
                        const TextStyle(color: Colors.white, fontSize: 10)),
              // 每日 WiFi/移动用量(对齐 down_vis/up_vis)
              if (config.showDailyWifi || config.showDailyMobile)
                Row(
                  children: [
                    if (config.showDailyWifi)
                      Text('WiFi $_dailyWifiText',
                          style: const TextStyle(
                              color: Color(0xFF8BC34A), fontSize: 9)),
                    if (config.showDailyWifi && config.showDailyMobile)
                      const SizedBox(width: 8),
                    if (config.showDailyMobile)
                      Text('流量 $_dailyMobileText',
                          style: const TextStyle(
                              color: Color(0xFF4FC3F7), fontSize: 9)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
