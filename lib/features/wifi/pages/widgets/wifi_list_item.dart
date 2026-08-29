// WiFi 列表 item - 对齐 MyWifiListAdapter + item_my_wifi_list.xml。
// 已连接项为 #99CEF3 蓝底白字，未连接项为白底灰字。
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../models/wifi_scan_result.dart';

class WifiListItem extends StatelessWidget {
  final WifiScanResult wifi;
  final VoidCallback? onTap;

  const WifiListItem({super.key, required this.wifi, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool connected = wifi.isConnected;
    final textColor = connected ? Colors.white : const Color(0xFFBFBFBF);
    return Card(
      margin: const EdgeInsets.all(5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: connected ? const Color(0xFF99CEF3) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                connected
                    ? AppAssets.wifiConnected
                    : AppAssets.wifiDisconnected,
                width: 26,
                height: 26,
              ),
              const SizedBox(height: 6),
              Text(
                wifi.ssid,
                style: TextStyle(fontSize: 14, color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                connected ? '已连接' : '未连接',
                style: TextStyle(fontSize: 12, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
