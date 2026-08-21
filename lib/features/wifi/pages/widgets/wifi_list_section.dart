// WiFi 列表区 - 对齐 activity_main_tool.xml 第 178-331 行 ShapeLinearLayout
// 中间白色大卡片: 圆角 20 阴影 3 marginHorizontal 20 padding 20 高 360
// 含"wifi列表"标题(18sp #1E1E1E) + WifiListView; 右上角"刷新缓存"按钮
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.wifiCardShadow,
            blurRadius: 3,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行: "wifi列表" + 右侧"刷新缓存"按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'wifi列表',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.wifiCardText,
                ),
              ),
              GestureDetector(
                onTap: onRefreshCache,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 14,
                        color: AppColors.wifiConnectedBlue,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '刷新缓存',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.wifiConnectedBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // 列表视图
          Expanded(
            child: WifiListView(
              isScanning: isScanning,
              isWifiEnabled: isWifiEnabled,
              wifiList: wifiList,
              emptyText: emptyText,
              onItemClick: onItemClick,
            ),
          ),
        ],
      ),
    );
  }
}
