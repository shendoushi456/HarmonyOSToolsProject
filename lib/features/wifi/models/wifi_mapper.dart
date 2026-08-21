// WiFi Mapper - DTO → 领域 Model 转换 + 去重 + 排序
// 对齐 Android ClearLib WifiUtils.convertToWifiListBeans
import 'wifi_dto.dart';
import 'wifi_info.dart';
import 'wifi_scan_result.dart';
import 'wifi_signal_strength.dart';

class WifiMapper {
  WifiMapper._();

  /// WifiLinkedInfoDTO → WifiInfo
  /// 对齐 Android WifiInfo + getCurrentSsid
  static WifiInfo? toWifiInfo(WifiLinkedInfoDTO? dto) {
    if (dto == null) return null;
    // connState: 0=UNKNOWN 1=HAVING_PASSWORD 2=OBTAINING_IPADDR 3=OBTAINING_IPADDR_FAILING
    //            4=CONNECTED 5=DISCONNECTED 6=DISCONNECTING ...
    // 转换为 isConnected: 仅 CONNECTED 或 OBTAINING_IPADDR 视为已连接
    final connected = dto.connState == 4 || dto.connState == 2;
    return WifiInfo(
      ssid: dto.ssid,
      bssid: dto.bssid,
      rssi: dto.rssi,
      securityType: dto.securityType,
      frequency: dto.frequency,
      linkSpeed: dto.linkSpeed,
      isConnected: connected,
    );
  }

  /// List<WifiScanInfoDTO> → List<WifiScanResult>
  /// 对齐 WifiUtils.convertToWifiListBeans: 去重 + 按 signal level 排序
  /// [connectedBssid] 当前已连接 wifi 的 bssid,用于标记 isConnected
  static List<WifiScanResult> toScanResultList(
    List<WifiScanInfoDTO> dtoList,
    String connectedBssid,
  ) {
    var list = dtoList
        .where((d) => d.ssid.isNotEmpty)
        .map((d) => WifiScanResult(
              ssid: d.ssid,
              bssid: d.bssid,
              rssi: d.rssi,
              signalLevel: WifiSignalStrength.fromRssi(d.rssi),
              // securityType: 0=INVALID 1=OPEN 其它视为加密
              isSecured: d.securityType != 0 && d.securityType != 1,
              isConnected:
                  connectedBssid.isNotEmpty && d.bssid == connectedBssid,
            ))
        .toList();
    list = _dedupBySsid(list);
    // 按 RSSI 降序(信号强的在前)
    list.sort((a, b) => b.rssi.compareTo(a.rssi));
    return list;
  }

  /// 按 SSID 去重(保留第一个,通常信号最强的已经排在前面)
  static List<WifiScanResult> _dedupBySsid(List<WifiScanResult> list) {
    final seen = <String>{};
    return list.where((w) {
      if (w.ssid.isEmpty) return false;
      if (seen.contains(w.ssid)) return false;
      seen.add(w.ssid);
      return true;
    }).toList();
  }
}
