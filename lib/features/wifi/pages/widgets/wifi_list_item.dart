// toolbox_c item_my_wifi_list.xml 的 Flutter 实现。
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../models/wifi_scan_result.dart';
import '../../models/wifi_signal_strength.dart';

class WifiListItem extends StatelessWidget {
  final WifiScanResult wifi;
  final VoidCallback? onTap;

  const WifiListItem({super.key, required this.wifi, this.onTap});

  @override
  Widget build(BuildContext context) {
    final connected = wifi.isConnected;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Image.asset(
                connected
                    ? AppAssets.toolboxWifiConnected
                    : AppAssets.toolboxWifiDisconnected,
                width: 26,
                height: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wifi.ssid,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          color: connected
                              ? const Color(0xFF3674EB)
                              : const Color(0xFF3C3C3C))),
                  const SizedBox(height: 2),
                  Text(_signalText(wifi.signalLevel),
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF2A9DF8))),
                ],
              ),
            ),
            if (!connected)
              Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Image.asset(AppAssets.toolboxWifiArrow,
                      width: 10, height: 10)),
          ],
        ),
      ),
    );
  }

  String _signalText(WifiSignalStrength level) {
    switch (level) {
      case WifiSignalStrength.disabled:
        return '信号强度：无';
      case WifiSignalStrength.low:
        return '信号强度：弱';
      case WifiSignalStrength.medium:
        return '信号强度：中';
      case WifiSignalStrength.high:
        return '信号强度：强';
      case WifiSignalStrength.excellent:
        return '信号强度：极强';
    }
  }
}
