// WiFi 列表视图 - 对齐 my_wifi_list_view.xml
// 三态切换: 扫描中(进度) / wifi 未开启(空态"请先开启WiFi") / 有数据(ListView.builder)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/wifi_scan_result.dart';
import 'wifi_list_item.dart';

class WifiListView extends StatelessWidget {
  final bool isScanning;
  final bool isWifiEnabled;
  final List<WifiScanResult> wifiList;
  final String emptyText;
  final void Function(WifiScanResult wifi)? onItemClick;

  const WifiListView({
    super.key,
    this.isScanning = false,
    this.isWifiEnabled = true,
    this.wifiList = const [],
    this.emptyText = '正在等待系统扫描附近 Wi-Fi...',
    this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    // 1. wifi 未开启 → 空态"请先开启WiFi"
    if (!isWifiEnabled) {
      return _emptyView('请先开启WiFi');
    }
    // 2. 正在扫描且无数据 → 进度
    if (isScanning && wifiList.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    // 3. 无数据 → 空态"正在等待系统扫描附近 Wi-Fi..."
    if (wifiList.isEmpty) {
      return _emptyView(emptyText);
    }
    // 4. 有数据 → ListView.builder
    return ListView.builder(
      itemCount: wifiList.length,
      padding: EdgeInsets.zero,
      itemBuilder: (ctx, i) {
        final item = wifiList[i];
        return WifiListItem(
          wifi: item,
          onTap: () => onItemClick?.call(item),
        );
      },
    );
  }

  Widget _emptyView(String text) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                AppAssets.wifiEmpty,
                width: 64,
                height: 64,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.wifiDisconnectedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
