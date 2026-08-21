// 定位权限请求组件 - 对齐 Android bus/ui/LocationPermissionContent.kt
// 用于在 Fragment 中显示完整的权限请求界面
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';

/// 通用的定位权限请求组件 - 对齐 Android LocationPermissionContent
/// 用于在 Fragment 中显示完整的权限请求界面
class LocationPermissionContent extends StatelessWidget {
  const LocationPermissionContent({
    super.key,
    this.title = '未开启定位权限',
    this.subtitle = '用于查看附近站点、路线信息及使用\n路线规划等功能',
    this.buttonText = '去开启',
    required this.onRequestPermission,
  });

  /// 权限提示标题，默认为"未开启定位权限"
  final String title;

  /// 权限说明文字
  final String subtitle;

  /// 按钮文字，默认为"去开启"
  final String buttonText;

  /// 权限请求回调
  final VoidCallback onRequestPermission;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10),
      child: Stack(
        children: [
          // 中间定位权限内容 - 对齐 Android Box(modifier = Modifier.align(Alignment.Center))
          Center(
            child: Stack(
              children: [
                // 背景图 - 对齐 Android Image(painterResource(R.mipmap.ic_main_bg), height = 450.dp)
                Image.asset(
                  AppAssets.icMainBg,
                  width: double.infinity,
                  height: 450,
                  fit: BoxFit.fill,
                ),
                // 内容层 - 对齐 Android Box(modifier = Modifier.padding(top = 12.dp))
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      // 顶部留白 - 对齐 Android Spacer(modifier = Modifier.height(90.dp))
                      const SizedBox(height: 90),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // 标题 - 对齐 Android Text(text = title, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.jbcxText,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // 副标题 - 对齐 Android Text(text = subtitle, fontSize = 14.sp)
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.jbcxText,
                              ),
                            ),
                            const SizedBox(height: 35),
                            // 按钮 - 对齐 Android Button(onClick = onRequestPermission)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: onRequestPermission,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.jbcxText,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    buttonText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
