// WiFi 页顶部背景 - 对齐 activity_main_tool.xml FrameLayout 顶部
// wifi_top_bg 背景图(fitXY) + 居中 "WIFI" 标题(粗 22sp 黑, marginTop 50dp)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

class WifiTopBackground extends StatelessWidget {
  /// 组件高度(需明确指定,否则内部 Stack 全 Positioned 子元素会高度为 0)
  final double height;

  const WifiTopBackground({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
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
            fit: BoxFit.fill,
          ),
          // 居中 WIFI 标题,marginTop 50dp(在状态栏下方)
          const Positioned(
            left: 0,
            right: 0,
            top: 50,
            child: Center(
              child: Text(
                'WIFI',
                style: TextStyle(
                  fontSize: 22,
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
