// toolbox_c 首页迁移共享工具 - 对齐 Android wifimeter/wifilist/WifiSupport.java + WifiListAdapter
import 'package:flutter/widgets.dart';
import '../../../../core/constants/app_assets.dart';

/// WiFi 扫描结果条目(对齐 Android WifiBean + ScanResult 混合数据源)
class WifiBoxEntry {
  final String ssid;
  final String bssid;
  final int rssi;
  final int frequency;
  final String capabilities;

  const WifiBoxEntry({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.frequency,
    required this.capabilities,
  });
}

class WifiBoxSupport {
  WifiBoxSupport._();

  /// 安卓原版主色 #FF373063(colors.xml)
  static const Color primary = Color(0xFF373063);

  /// 绿色 #FF5AC158(green_color)
  static const Color greenColor = Color(0xFF5AC158);

  /// 去掉同名 SSID(对齐 WifiSupport.noSameName,保持首个出现的顺序)
  static List<WifiBoxEntry> noSameName(List<WifiBoxEntry> list) {
    final result = <WifiBoxEntry>[];
    for (final item in list) {
      if (item.ssid.isEmpty) continue; // 对齐 TextUtils.isEmpty 过滤
      if (!result.any((e) => e.ssid == item.ssid)) {
        result.add(item);
      }
    }
    return result;
  }

  /// 信号档位(对齐 WifiSupport.getLevel: |rssi|<50→1 <75→2 <90→3 否则 4)
  /// 注意安卓原版永不返回 0(保真)
  static int getLevel(int rssi) {
    final abs = rssi.abs();
    if (abs < 50) return 1;
    if (abs < 75) return 2;
    return abs < 90 ? 3 : 4;
  }

  /// 标准信号等级(对齐 WifiManager.calculateSignalLevel(rssi, max))
  static int calculateSignalLevel(int rssi, int maxLevels) {
    if (rssi <= -100) return 0;
    if (rssi >= -50) return maxLevels - 1;
    return ((rssi + 100) * (maxLevels - 1) / 50).toInt();
  }

  /// 加密类型(对齐 WifiSupport.getWifiCipher: WEP/WPA/WPA2/WPS 有密码,否则开放)
  static bool isSecured(String capabilities) {
    final cap = capabilities.toUpperCase();
    return cap.contains('WEP') ||
        cap.contains('WPA') ||
        cap.contains('WPS');
  }

  /// 列表排序(对齐 Collections.sort(WifiBean): 按档位升序,同档按名称)
  static int compare(WifiBoxEntry a, WifiBoxEntry b) {
    final la = getLevel(a.rssi);
    final lb = getLevel(b.rssi);
    if (la != lb) return la.compareTo(lb);
    return a.ssid.compareTo(b.ssid);
  }

  /// 列表项信号图标(对齐 WifiListAdapter 反编译逻辑,含原版 Bug 保真):
  /// 档位>=4 恒显 locked 图;档位 0 恒显 locker 图;1-3 档按 WEP/WPA 决定锁图
  static String signalIcon(int rssi, String capabilities) {
    final level = calculateSignalLevel(rssi, 5);
    final secured = isSecured(capabilities);
    switch (level) {
      case 4:
        return secured
            ? AppAssets.wifiSignalExcellentLocked
            : AppAssets.wifiSignalExcellentLocked; // 原版 ≥4 恒为 locked
      case 3:
        return secured ? AppAssets.wifiSignalHighLocked : AppAssets.wifiSignalHigh;
      case 2:
        return secured ? AppAssets.wifiSignalMedLocked : AppAssets.wifiSignalMed;
      case 1:
        return secured ? AppAssets.wifiSignalLowLocked : AppAssets.wifiSignalLow;
      default:
        return AppAssets.wifiSignalDisabledLocked; // 原版 0 档恒为 locker
    }
  }

  /// item 进度条值(对齐 barra_gradiente progress=abs((level+40)*100/60))
  static int progressValue(int rssi) => ((rssi + 40) * 100 ~/ 60).abs().clamp(0, 100);

  /// 详情页强度文案(对齐 obtenerIntensidadSignal)
  static String intensityText(int level) {
    switch (level) {
      case 0:
        return '无信号';
      case 1:
        return '低覆盖率';
      case 2:
        return '好';
      case 3:
        return '非常好';
      case 4:
        return '优秀';
      default:
        return '未知';
    }
  }

  /// 信道计算(对齐 getCanal)
  static int channelOf(int frequency) {
    if (frequency == 2484) return 14;
    if (frequency < 2484) return (frequency - 2407) ~/ 5;
    return frequency ~/ 5; // 安卓反编译为 (i/5)+0,与 5GHz 常规算法一致
  }

  /// 子网掩码(对齐 calcularMaskByPrefixLength)
  static String subnetMask(int prefixLength) {
    if (prefixLength <= 0 || prefixLength > 32) return '未知';
    final mask = prefixLength == 32 ? 0xFFFFFFFF : (0xFFFFFFFF << (32 - prefixLength)) & 0xFFFFFFFF;
    return [
      (mask >> 24) & 0xFF,
      (mask >> 16) & 0xFF,
      (mask >> 8) & 0xFF,
      mask & 0xFF,
    ].join('.');
  }
}
