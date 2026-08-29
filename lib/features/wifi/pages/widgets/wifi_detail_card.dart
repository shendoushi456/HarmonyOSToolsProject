// WiFi 详情卡 - 对齐 activity_main_tool.xml 第 44-118 行 wifi_details_btn
// 圆角 10dp 白底阴影; 左 75×81 top_wifi_icon; 右垂直: connectiontype + net_status
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';

class WifiDetailCard extends StatelessWidget {
  /// 当前显示的连接名(WIFI 时为 ssid, MOBILE 时为运营商名, 无网络时为"无网络")
  final String connectionTypeText;

  /// 网络状态副文案(对应 activity_main_tool.xml 默认"已连接")
  final String netStatusText;

  /// 点击详情卡回调(触发权限二次校验)
  final VoidCallback? onTap;

  const WifiDetailCard({
    super.key,
    required this.connectionTypeText,
    this.netStatusText = '已连接',
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
          borderRadius: BorderRadius.circular(10),
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
            // 左侧垂直信息(对应 Android XML 中的第一个 LinearLayout)
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
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 右侧 75×81 wifi 图标
            Image.asset(
              AppAssets.wifiTopIcon,
              width: 75,
              height: 81,
            ),
          ],
        ),
      ),
    );
  }
}
