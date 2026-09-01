// 对齐 Android item_my_wifi_list.xml。
// ShapeLinearLayout(白底 圆角10 阴影5dp#C3C2C2 padding V16 H16) + 横向:
// mlwifiicon 16x16(lwifiylj/lwifiwlj) + marginLeft12 + [lmwifiname 14sp #3C3C3C weight1
//   + 已连接项 lmwifiylj "已连接" 12sp #8CE189 + lmwifijt 箭头 8x8(所有项)]
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/wifi_scan_result.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          // 对齐 shape_shadowSize 5dp #C3C2C2: 降低透明度 + 轻微下移,
          // 避免全透明度 Offset(0,0) 形成灰色光环瑕疵。
          boxShadow: const [
            BoxShadow(
              color: Color(0x66C3C2C2),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // mlwifiicon 16x16: 已连接 lwifiylj / 未连接 lwifiwlj(安卓原版, 非 toolbox_)
            Image.asset(
              connected
                  ? AppAssets.wifiConnected
                  : AppAssets.wifiDisconnected,
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 12),
            // WiFi 信息区(weight 1)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // lmwifiname 14sp text_primary #3C3C3C
                  Expanded(
                    child: Text(
                      wifi.ssid,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.wifiDisconnectedText,
                      ),
                    ),
                  ),
                  // 已连接项 lmwifiylj "已连接" 12sp #8CE189
                  if (connected)
                    const Text(
                      '已连接',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8CE189)),
                    ),
                  // lmwifijt 箭头 8x8(所有项都显示)
                  Image.asset(AppAssets.wifiArrow, width: 8, height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
