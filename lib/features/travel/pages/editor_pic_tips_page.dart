// 图片攻略页 - 对齐 Android EditorPicTipsActivity.kt
// 简单页面：ScrollView + ImageView + 浮动返回按钮
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

/// 图片攻略页 - 对齐 Android EditorPicTipsActivity
/// 根据传入的 type 显示对应景点的长图片
class EditorPicTipsPage extends StatelessWidget {
  const EditorPicTipsPage({super.key, this.extra});

  /// 路由参数（对齐 Android Intent extra "type"）
  final Map<String, dynamic>? extra;

  /// 根据 type 获取图片路径 - 对齐 Android when(type) 分支
  String _getImagePath(String? type) {
    switch (type) {
      case '故宫博物院':
        return AppAssets.scenicGugong;
      case '环球度假区':
        return AppAssets.scenicHuanqiiu;
      case '八达岭长城':
        return AppAssets.scenicBadaling;
      case '兵马俑':
        return AppAssets.scenicBingmayong;
      case '外滩':
        return AppAssets.scenicWaitan;
      case '九寨沟':
        return AppAssets.scenicJiuzhaigou;
      case '西湖':
        return AppAssets.scenicXihu;
      default:
        return AppAssets.scenicGugong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = extra?['type'] as String?;
    final imagePath = _getImagePath(type);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ScrollView + ImageView - 对齐 Android ScrollView + ImageView(adjustViewBounds, fitStart)
          SingleChildScrollView(
            child: Image.asset(
              imagePath,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          // 浮动返回按钮 - 对齐 Android ImageView(tips_back, marginTop=50dp, padding=15dp)
          Positioned(
            top: MediaQuery.of(context).padding.top + 50 - 15,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset(
                  AppAssets.icBackGrayWhite,
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
