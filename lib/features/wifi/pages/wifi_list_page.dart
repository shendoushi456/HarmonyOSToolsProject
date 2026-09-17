// 附近 WiFi 列表全页 - 对齐 Android WiFiListActivity(标题栏 gone,与首页内嵌同构)
// 说明: 安卓原版该页由首页隐藏按钮进入,title_bar visibility=gone,仅"可用网络"+列表;
// 系统手势返回可退出页(原版有隐藏的 img_back)
import 'package:flutter/material.dart';
import 'widgets/wifi_box_list_section.dart';

class WifiListPage extends StatelessWidget {
  const WifiListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 对齐 title_bar 45sdp(visibility=gone): 不渲染标题栏
          // "可用网络"+列表(与首页内嵌共用 WifiBoxListSection)
          Expanded(child: WifiBoxListSection()),
        ],
      ),
    );
  }
}
