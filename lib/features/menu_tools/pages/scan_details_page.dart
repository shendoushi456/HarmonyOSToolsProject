// 扫描详情页 - 对齐 Android ScanDeailsActivity.kt:
// 黑色背景 + scan_detils_iv 长图(1125x3264)按宽缩放垂直滚动,无返回按钮。
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';

class ScanDetailsPage extends StatelessWidget {
  const ScanDetailsPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const ScanDetailsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Image.asset(
          AppAssets.menuToolsScanDetails,
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
