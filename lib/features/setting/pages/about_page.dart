// 关于页 - 对齐 Android AboutToolSetActivity
// 显示 logo/应用名/版本号;点击 logo 10 次复制版本号(简化:原版复制 Android ID)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../utils/app_info_util.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _clickCount = 0;

  Future<void> _onLogoTap() async {
    _clickCount++;
    if (_clickCount >= 10) {
      _clickCount = 0;
      // 简化:复制版本号(原版复制 Android ID,device_info_plus ohos 支持不确定)
      await Clipboard.setData(
        ClipboardData(text: 'V${AppInfoUtil.version}'),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已复制到粘贴板')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部栏
          _buildTopBar(context),
          // logo(点击 10 次复制版本号)
          GestureDetector(
            onTap: _onLogoTap,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Image.asset(AppAssets.appLogo, width: 86, height: 86),
            ),
          ),
          // 应用名
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              AppInfoUtil.appName,
              style: const TextStyle(
                color: AppColors.settingAppName,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 版本号
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'V${AppInfoUtil.version}',
              style: const TextStyle(
                color: AppColors.settingSubText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 88,
      color: AppColors.settingTheme,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 8,
              bottom: 0,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    '关于我们',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
