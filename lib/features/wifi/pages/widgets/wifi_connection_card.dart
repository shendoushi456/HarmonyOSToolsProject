// WiFi 连接卡 - 对齐 activity_main_tool.xml 第 53-156 行 mBg LinearLayout
// 蓝色渐变圆角卡: 左侧 wifi_icon(72dp) + 右侧垂直(SSID 22sp 白 + "已连接" 10sp 白)
// 注: 源布局的内层白色"优化提速"行(网络可提升67% / 优化提速按钮)按 MIGRATION 边界排除,
// 此处仅保留连接信息展示部分。mBg 原有点击跳转 ClearSilverActivity(优化提速入口)亦排除。
// 卡片背景视觉对齐 jiasubg.png(蓝色渐变 + 圆角),用 BoxDecoration 渐变重建,
// 避免短卡拉伸 mipmap 导致的渐变/圆角失真。
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

class WifiConnectionCard extends StatelessWidget {
  /// 当前连接的 SSID(对齐 wife_name TextView, 已去掉首尾引号)
  final String ssid;

  const WifiConnectionCard({super.key, required this.ssid});

  @override
  Widget build(BuildContext context) {
    // 卡片外边距: mBg marginHorizontal 15 + 父 LL paddingLeft 10 = 屏幕左 25
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      // 卡片内边距: mBg paddingLeft 15 + paddingHorizontal 12(覆盖右为 12) + paddingVertical 12
      padding: const EdgeInsets.fromLTRB(15, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A7FE0), Color(0xFF6B9FEC)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 对齐 ImageView layout_marginLeft 8dp
          const SizedBox(width: 8),
          Image.asset(AppAssets.wifiIcon, width: 72, height: 72),
          // 对齐右侧垂直 LinearLayout 的 layout_marginLeft 10dp
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 对齐 wife_name: textColor #FFFFFF, textSize 22sp
                Text(
                  ssid,
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // 对齐 wife_name 与 "已连接" 之间的 marginTop 6dp
                const SizedBox(height: 6),
                // 对齐 "已连接" TextView: textColor #FFFFFF, textSize 10sp(原 XML 静态文案)
                const Text(
                  '已连接',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
