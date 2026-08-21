// WiFi Repository - 持有 Service + Mapper,做 DTO→Model 转换
// 对齐 Android 业务编排层:ToolsMainActivity.getNetworkType/getCurrentSsid + CarrierName
import '../models/wifi_info.dart';
import '../models/wifi_scan_result.dart';
import '../models/wifi_mapper.dart';
import '../services/wifi_service.dart';

/// 流量统计结果(对齐 Android TrafficStats 总接收/发送字节数)
class TrafficBytes {
  final int rxBytes;
  final int txBytes;
  const TrafficBytes(this.rxBytes, this.txBytes);
}

class WifiRepository {
  final WifiService _service;
  WifiRepository({WifiService? service}) : _service = service ?? WifiService();

  /// 当前 wifi 连接信息(对齐 getCurrentSsid + getConnectionInfo)
  Future<WifiInfo?> getCurrentConnection() async {
    final dto = await _service.getLinkedInfo();
    return WifiMapper.toWifiInfo(dto);
  }

  /// 附近 wifi 扫描结果(已去重 + 按 signal level 排序)
  /// [connectedBssid] 当前已连接 bssid,用于标记列表项 isConnected
  Future<List<WifiScanResult>> getScanResults({
    String connectedBssid = '',
  }) async {
    final dtoList = await _service.getScanInfoList();
    return WifiMapper.toScanResultList(dtoList, connectedBssid);
  }

  /// 流量统计(总接收/发送字节数,对齐 TrafficStats)
  Future<TrafficBytes> getTrafficBytes() async {
    final rx = await _service.getAllRxBytes();
    final tx = await _service.getAllTxBytes();
    return TrafficBytes(rx, tx);
  }

  /// 网络类型 'wifi'/'mobile'/'none'
  Future<String> getNetworkType() => _service.getNetworkType();

  /// 移动网络运营商名
  Future<String> getCarrierName() => _service.getOperatorName();

  /// wifi 是否已开启
  Future<bool> isWifiEnabled() => _service.isWifiActive();

  /// 跳转系统 wifi 设置页
  Future<void> openWifiSettings() => _service.openWifiSettings();

  /// wifi 扫描完成事件流
  Stream<dynamic> get onScanFinishedStream => _service.onScanFinishedStream;
}
