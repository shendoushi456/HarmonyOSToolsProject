// WiFi 列表视图 - 对齐 my_wifi_list_view.xml + MyWifiListView.kt
// MyWifiListView.kt:37 LinearLayoutManager(context) → 一列垂直列表(非 Grid 两列)
// 结构: 状态行(status_text 14sp + scanning_progress, marginBottom 12) + [空态 empty_view 200dp | 一列 RecyclerView]
// 状态文案对齐 setStatus(): WIFI_OPEN "WiFi已开启" / WIFI_CLOSE "WiFi已关闭"
// 注: scanning_progress 仅 WifiStatus.SCANNING 时显示, MyWifiListFragment 从不调用 → 不渲染
// 空态文案对齐 setWiFiOpen(): !wifiOpen "请先开启WiFi" / wifiOpen 且无数据 "未发现可用WiFi，正在扫描..."
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../models/wifi_scan_result.dart';
import 'wifi_list_item.dart';

class WifiListView extends StatelessWidget {
  /// wifi 是否开启(对齐 setWiFiOpen 的 wifiOpen 参数)
  final bool isWifiEnabled;

  /// wifi 列表数据(已排序去重)
  final List<WifiScanResult> wifiList;

  /// 点击列表项回调(对齐 myonClick → dialog_wifi → 系统 WiFi 设置)
  final void Function(WifiScanResult wifi)? onItemClick;

  const WifiListView({
    super.key,
    this.isWifiEnabled = true,
    this.wifiList = const [],
    this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    // setWiFiOpen() 的空态文案(内部逻辑决定, 非外部传入)
    final String emptyText = !isWifiEnabled ? '请先开启WiFi' : '未发现可用WiFi，正在扫描...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 状态行: status_text(weight 1, 14sp text_primary) + progress(恒 GONE), marginBottom 12dp
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 12),
        //   child: Text(
        //     statusText,
        //     style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        //   ),
        // ),
        // 空态(empty_view) / 一列列表(wifi_recycler_view)
        if (wifiList.isEmpty)
          _emptyView(emptyText)
        else
          Expanded(
            child: ListView.separated(
              // 为白色列表卡片保留呼吸感，避免相邻圆角卡片视觉粘连。
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              itemCount: wifiList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final item = wifiList[i];
                return WifiListItem(
                  wifi: item,
                  onTap: () => onItemClick?.call(item),
                );
              },
            ),
          ),
      ],
    );
  }

  /// 空态视图 - 对齐 empty_view: 200dp 高居中, ic_wifi_empty 64dp alpha 0.5,
  /// empty_text marginTop 16dp, 14sp text_secondary
  Widget _emptyView(String text) {
    return SizedBox(
      height: 200,
      width: double.infinity,
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
              style: const TextStyle(fontSize: 14, color: Color(0x66333333)),
            ),
          ],
        ),
      ),
    );
  }
}
