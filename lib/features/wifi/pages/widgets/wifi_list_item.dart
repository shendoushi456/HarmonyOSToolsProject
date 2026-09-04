// WiFi 列表 item - 对齐 item_my_wifi_list.xml
// 水平布局, paddingVertical 16dp:
// 信号图标 16×16 + WiFi 名(weight 1, 14sp) + "已连接"标签(12sp #3674EB) + 右箭头(8×8)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/wifi_scan_result.dart';

class WifiListItem extends StatelessWidget {
  final WifiScanResult wifi;
  final VoidCallback? onTap;

  const WifiListItem({super.key, required this.wifi, this.onTap});

  /// 根据 signalLevel + isSecured 选 10 个图标之一
  /// signalLevel: 0=disabled 1=low 2=med 3=high 4=excellent
  static String _signalIcon(int level, bool isSecured) {
    const table = <String>[
      AppAssets.wifiSignalDisabled,
      AppAssets.wifiSignalLow,
      AppAssets.wifiSignalMed,
      AppAssets.wifiSignalHigh,
      AppAssets.wifiSignalExcellent,
    ];
    const tableLocked = <String>[
      AppAssets.wifiSignalDisabledLocked,
      AppAssets.wifiSignalLowLocked,
      AppAssets.wifiSignalMedLocked,
      AppAssets.wifiSignalHighLocked,
      AppAssets.wifiSignalExcellentLocked,
    ];
    final idx = level.clamp(0, 4);
    return isSecured ? tableLocked[idx] : table[idx];
  }

  @override
  Widget build(BuildContext context) {
    final bool connected = wifi.isConnected;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // 信号图标 16×16
            Image.asset(
              _signalIcon(wifi.signalLevel.level, wifi.isSecured),
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 12),
            // WiFi 名 + 已连接标签/右箭头
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      wifi.ssid,
                      style: TextStyle(
                        fontSize: 14,
                        color: connected
                            ? AppColors.wifiConnectedBlue
                            : AppColors.wifiDisconnectedText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (connected)
                    const Text(
                      '已连接',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.wifiConnectedBlue,
                      ),
                    )
                  else
                    Image.asset(
                      AppAssets.wifiArrow,
                      width: 8,
                      height: 8,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
