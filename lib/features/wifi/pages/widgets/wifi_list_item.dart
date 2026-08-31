// WiFi 列表 item - 对齐 item_my_wifi_list.xml + MyWifiListAdapter.bind()
// 一列横向白卡: 白底 + radius 10dp + 阴影 5dp #C3C2C2, padding H16 V16, gravity center_vertical
// 左: mlwifiicon 16dp(已连接 lwifiylj / 未连接 lwifiwlj) + 12dp 间距
// 中: lmwifiname 14sp 单行省略(已连接 #3C3C3C / 未连接 #A8A8A8)
// 右: 已连接 → lmwifiylj "已连接" 12sp #8CE189; 未连接 → lmwifijt 箭头 8dp
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // 对齐 ShapeLinearLayout: solidColor white + radius 10 + shadowSize 5dp #C3C2C2
        // XML 无 layout_margin, RecyclerView 无 ItemDecoration → 一列无间距堆叠
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Color(0xFFC3C2C2),
          //     blurRadius: 5,
          //     spreadRadius: 1,
          //   ),
          // ],
        ),
        child: Row(
          children: [
            // mlwifiicon: isConnected → lwifiylj / 否则 lwifiwlj
            Image.asset(
              connected
                  ? AppAssets.wifiConnected
                  : AppAssets.wifiDisconnected,
              width: 16,
              height: 16,
            ),
            // 信息区 marginLeft 12dp
            const SizedBox(width: 12),
            // lmwifiname: 14sp singleLine ellipsize end
            Expanded(
              child: Text(
                wifi.ssid,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: connected
                      ? const Color(0xFF3C3C3C)
                      : const Color(0xFFA8A8A8),
                ),
              ),
            ),
            // lmwifiylj "已连接"(仅已连接) / lmwifijt 箭头(仅未连接), XML 中均无额外间距
            if (connected)
              const Text(
                '已连接',
                style: TextStyle(fontSize: 12, color: Color(0xFF8CE189)),
              )
            else
              Image.asset(AppAssets.wifiArrow, width: 8, height: 8),
          ],
        ),
      ),
    );
  }
}
