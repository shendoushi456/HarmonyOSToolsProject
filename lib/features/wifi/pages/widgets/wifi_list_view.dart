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
    // 空态(empty_view 200dp) / 一列列表(wifi_recycler_view, 内部滚动对齐安卓 RecyclerView)
    if (wifiList.isEmpty) {
      return _emptyView(emptyText);
    }
    return ListView.separated(
      // shrinkWrap:false + ClampingScrollPhysics: 在父级有界高度内滚动,
      // 对齐安卓 MyWifiListView(RecyclerView) 仅列表自身滚动、页面固定。
      shrinkWrap: false,
      physics: const ClampingScrollPhysics(),
      // 顶部内 padding 20 + 横向 padding 10(横向留出卡片阴影渲染空间,
      // 避免阴影被 ListView 视口裁剪)。
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),
      itemCount: wifiList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final item = wifiList[i];
        return WifiListItem(
          wifi: item,
          onTap: () => onItemClick?.call(item),
        );
      },
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
