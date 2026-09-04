// WiFi 页顶部背景 - 对齐 activity_main_tool.xml FrameLayout 顶部
// wifi_top_bg 背景图(fitXY) + 居中 "WIFI" 标题(粗 15sp 黑, marginTop 30dp)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

class WifiTopBackground extends StatelessWidget {
  /// 组件高度(需明确指定,否则内部 Stack 全 Positioned 子元素会高度为 0)
  final double height;

  const WifiTopBackground({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    // 状态栏高度,用于让标题下沉到状态栏下方
    final double statusBar = MediaQuery.of(context).padding.top;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          // 背景图覆盖整个区域
          Image.asset(
            AppAssets.wifiTopBg,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
          ),
          // 居中 WIFI 标题,marginTop 30dp(在状态栏下方)
          Positioned(
            left: 0,
            right: 0,
            top: statusBar + 30,
            child: const Center(
              child: Text(
                'WIFI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
