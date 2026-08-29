// WiFi 列表区 - 对齐 activity_main_tool.xml 第 178-331 行 ShapeLinearLayout
// 安卓原版列表直接嵌在页面中，无额外白色大卡片和可见标题。
import 'package:flutter/material.dart';
import '../../models/wifi_scan_result.dart';
import 'wifi_list_view.dart';

class WifiListSection extends StatelessWidget {
  /// 是否正在扫描
  final bool isScanning;

  /// 是否 wifi 已开启
  final bool isWifiEnabled;

  /// wifi 列表数据(已排序去重)
  final List<WifiScanResult> wifiList;

  /// 空状态文案
  final String emptyText;

  /// 点击刷新缓存回调(鸿蒙无法主动扫描,提供手动刷新入口)
  final VoidCallback? onRefreshCache;

  /// 点击列表项回调
  final void Function(WifiScanResult wifi)? onItemClick;

  const WifiListSection({
    super.key,
    this.isScanning = false,
    this.isWifiEnabled = true,
    this.wifiList = const [],
    this.emptyText = '正在等待系统扫描附近 Wi-Fi...',
    this.onRefreshCache,
    this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 6, 17, 16),
      child: WifiListView(
        isScanning: isScanning,
        isWifiEnabled: isWifiEnabled,
        wifiList: wifiList,
        emptyText: emptyText,
        onItemClick: onItemClick,
      ),
    );
  }
}
