// WiFi DTO - 对齐 ohos WifiLinkedInfo / WifiScanInfo 原生返回字段
// 由 WifiPlugin.ets 通过 MethodChannel 返回的 Map 反序列化
// 鸿蒙 WifiSecurityType 枚举: INVALID=0 OPEN=1 WEP=2 PSK=3 SAE=4 EAP=5 WAPI_PSK=6

/// 当前 wifi 连接信息 DTO(对齐 ohos wifiManager.WifiLinkedInfo)
class WifiLinkedInfoDTO {
  final String ssid;
  final String bssid;
  final int rssi;
  final int securityType;
  final int band;
  final int frequency;
  final int linkSpeed;
  final bool isHidden;
  final int connState;

  const WifiLinkedInfoDTO({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.securityType,
    required this.band,
    required this.frequency,
    required this.linkSpeed,
    required this.isHidden,
    required this.connState,
  });

  factory WifiLinkedInfoDTO.fromMap(Map<dynamic, dynamic> m) {
    return WifiLinkedInfoDTO(
      ssid: (m['ssid'] ?? '') as String,
      bssid: (m['bssid'] ?? '') as String,
      rssi: (m['rssi'] ?? 0) as int,
      securityType: (m['securityType'] ?? 0) as int,
      band: (m['band'] ?? 0) as int,
      frequency: (m['frequency'] ?? 0) as int,
      linkSpeed: (m['linkSpeed'] ?? 0) as int,
      isHidden: (m['isHidden'] ?? false) as bool,
      connState: (m['connState'] ?? 0) as int,
    );
  }
}

/// 附近 wifi 扫描结果 DTO(对齐 ohos wifiManager.WifiScanInfo)
class WifiScanInfoDTO {
  final String ssid;
  final String bssid;
  final String capabilities;
  final int securityType;
  final int rssi;
  final int band;
  final int frequency;
  final int channelWidth;
  final int timestamp;

  const WifiScanInfoDTO({
    required this.ssid,
    required this.bssid,
    required this.capabilities,
    required this.securityType,
    required this.rssi,
    required this.band,
    required this.frequency,
    required this.channelWidth,
    required this.timestamp,
  });

  factory WifiScanInfoDTO.fromMap(Map<dynamic, dynamic> m) {
    return WifiScanInfoDTO(
      ssid: (m['ssid'] ?? '') as String,
      bssid: (m['bssid'] ?? '') as String,
      capabilities: (m['capabilities'] ?? '') as String,
      securityType: (m['securityType'] ?? 0) as int,
      rssi: (m['rssi'] ?? 0) as int,
      band: (m['band'] ?? 0) as int,
      frequency: (m['frequency'] ?? 0) as int,
      channelWidth: (m['channelWidth'] ?? 0) as int,
      timestamp: (m['timestamp'] ?? 0) as int,
    );
  }
}

/// WiFi 连接详细信息 DTO - 对齐 Android WiFiStrengthActivity 的 DhcpInfo+LinkProperties
/// 由 WifiPlugin.ets getConnectionDetail() 返回的 Map 反序列化
class WifiConnectionDetailDTO {
  final String ssid;
  final String bssid;
  final int rssi;
  final int frequency;
  final int linkSpeed;
  final bool isHidden;
  final String ip;
  final int ipPrefixLength;
  final String gateway;
  final String dns1;
  final String dns2;

  /// 本机 WLAN MAC(对齐 Android getConnectionInfo().getMacAddress;
  /// 无 GET_WIFI_LOCAL_MAC 授权时为空串)
  final String mac;

  const WifiConnectionDetailDTO({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.frequency,
    required this.linkSpeed,
    required this.isHidden,
    required this.ip,
    required this.ipPrefixLength,
    required this.gateway,
    required this.dns1,
    required this.dns2,
    this.mac = '',
  });

  factory WifiConnectionDetailDTO.fromMap(Map<dynamic, dynamic> m) {
    return WifiConnectionDetailDTO(
      ssid: (m['ssid'] ?? '') as String,
      bssid: (m['bssid'] ?? '') as String,
      rssi: (m['rssi'] ?? 0) as int,
      frequency: (m['frequency'] ?? 0) as int,
      linkSpeed: (m['linkSpeed'] ?? 0) as int,
      isHidden: (m['isHidden'] ?? false) as bool,
      ip: (m['ip'] ?? '') as String,
      ipPrefixLength: (m['ipPrefixLength'] ?? 0) as int,
      gateway: (m['gateway'] ?? '') as String,
      dns1: (m['dns1'] ?? '') as String,
      dns2: (m['dns2'] ?? '') as String,
      mac: (m['mac'] ?? '') as String,
    );
  }
}
