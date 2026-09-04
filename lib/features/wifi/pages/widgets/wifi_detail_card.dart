// WiFi 详情卡 - 对齐 activity_main_tool.xml 第 44-118 行 wifi_details_btn
// 圆角 20dp 白底阴影; 左 114×114 top_wifi_icon; 右垂直: connectiontype + net_status + "已连接"按钮
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';

class WifiDetailCard extends StatelessWidget {
  /// 当前显示的连接名(WIFI 时为 ssid, MOBILE 时为运营商名, 无网络时为"无网络")
  final String connectionTypeText;

  /// 网络状态副文案(默认"当前网络状态良好")
  final String netStatusText;

  /// 是否已连接(影响"已连接"按钮是否显示,默认 true)
  final bool isConnected;

  /// 点击详情卡回调(触发权限二次校验)
  final VoidCallback? onTap;

  const WifiDetailCard({
    super.key,
    required this.connectionTypeText,
    this.netStatusText = '当前网络状态良好',
    this.isConnected = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(10),
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
        child: Row(
          children: [
            // 左侧 114×114 wifi 图标
            Image.asset(
              AppAssets.wifiTopIcon,
              width: 114,
              height: 114,
            ),
            const SizedBox(width: 12),
            // 右侧垂直信息
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // connectiontype - 18sp 黑 粗
                  Text(
                    connectionTypeText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  // net_status - 10sp 绿
                  Text(
                    netStatusText,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.wifiConnectGreen,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // "已连接"蓝底白字按钮
                  if (isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.wifiBlueBtn,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '已连接',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
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
