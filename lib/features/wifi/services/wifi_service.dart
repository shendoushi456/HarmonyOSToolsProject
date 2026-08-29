// WiFi Service - 直接调 WifiNativeChannel(不经 Dio,wifi 数据非 HTTP)
// 对齐 Android WifiManager/TrafficStats/ConnectivityManager/TelephonyManager
import '../../../core/network/wifi_native_channel.dart';
import '../models/wifi_dto.dart';

class WifiService {
  final WifiNativeChannel _channel = WifiNativeChannel.instance;

  /// 当前 wifi 连接信息(对齐 WifiManager.getConnectionInfo)
  Future<WifiLinkedInfoDTO?> getLinkedInfo() => _channel.getLinkedInfo();

  /// 附近 wifi 扫描缓存(对齐 WifiManager.getScanResults)
  Future<List<WifiScanInfoDTO>> getScanInfoList() => _channel.getScanInfoList();

  /// wifi 开关状态(对齐 WifiManager.isWifiEnabled)
  Future<bool> isWifiActive() => _channel.isWifiActive();

  /// 申请读取附近 Wi-Fi 所需的位置权限。
  Future<bool> requestWifiPermissions() => _channel.requestWifiPermissions();

  /// 总接收字节数(对齐 TrafficStats.getTotalRxBytes)
  Future<int> getAllRxBytes() => _channel.getAllRxBytes();

  /// 总发送字节数(对齐 TrafficStats.getTotalTxBytes)
  Future<int> getAllTxBytes() => _channel.getAllTxBytes();

  /// 网络类型 'wifi'/'mobile'/'none'(对齐 ConnectivityManager)
  Future<String> getNetworkType() => _channel.getNetworkType();

  /// 运营商名(对齐 TelephonyManager.getNetworkOperatorName)
  Future<String> getOperatorName() => _channel.getOperatorName();

  /// 尝试跳转系统 Wi-Fi 设置页，返回是否已发起跳转。
  Future<bool> openWifiSettings() => _channel.openWifiSettings();

  /// wifi 扫描完成事件流(对齐 WIFI_SCAN_RESULTS_AVAILABLE_ACTION 广播)
  Stream<dynamic> get onScanFinishedStream => _channel.onScanFinishedStream;
}
