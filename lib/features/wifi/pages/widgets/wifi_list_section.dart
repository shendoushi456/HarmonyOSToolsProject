// WiFi 列表区 - 对齐 activity_main_tool.xml nearby_wifi_layout(marginHorizontal 15 + 父 LL padding 10 = 屏幕 25)
// 安卓列表直接嵌在页面中，无额外白色大卡片和可见标题。
import 'package:flutter/material.dart';
import '../../models/wifi_scan_result.dart';
import 'wifi_list_view.dart';

class WifiListSection extends StatelessWidget {
  /// 是否 wifi 已开启
  final bool isWifiEnabled;

  /// wifi 列表数据(已排序去重)
  final List<WifiScanResult> wifiList;

  /// 点击列表项回调
  final void Function(WifiScanResult wifi)? onItemClick;

  const WifiListSection({
    super.key,
    this.isWifiEnabled = true,
    this.wifiList = const [],
    this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: WifiListView(
        isWifiEnabled: isWifiEnabled,
        wifiList: wifiList,
        onItemClick: onItemClick,
      ),
    );
  }
}
