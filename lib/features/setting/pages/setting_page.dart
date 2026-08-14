// 设置主页 - 对齐 Android Setting4Activity + Setting4ToolFragment + fragment_setting_tool_4_layout.xml
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../router/route_names.dart';
import '../utils/app_info_util.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部栏 88dp(含状态栏,settingTheme 背景)
          _buildTopBar(context),
          // logo 86x86
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Image.asset(AppAssets.appLogo, width: 86, height: 86),
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
          // 设置项
          _buildItem(
            context,
            '用户协议',
            AppAssets.settingUserIcon,
            () => context.push(
              RoutePaths.policy,
              extra: {'title': '用户协议', 'url': SettingUrls.user},
            ),
          ),
          _buildItem(
            context,
            '隐私协议',
            AppAssets.settingPrivateIcon,
            () => context.push(
              RoutePaths.policy,
              extra: {'title': '隐私协议', 'url': SettingUrls.policy},
            ),
          ),
          _buildItem(
            context,
            '关于我们',
            AppAssets.settingAboutIcon,
            () => context.push(RoutePaths.about),
          ),
          _buildItem(
            context,
            '意见反馈',
            AppAssets.settingFeedbackIcon,
            () => context.push(RoutePaths.feedback),
          ),
        ],
      ),
    );
  }

  /// 顶部栏 - 对齐 fragment_setting_tool_4_layout FrameLayout 88dp
  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 88,
      color: AppColors.settingTheme,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 返回按钮 - 48x48,padding 14,start 8,bottom
            Positioned(
              left: 8,
              bottom: 0,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(AppAssets.iconWhiteBack),
                  ),
                ),
              ),
            ),
            // "设置"标题 - 22sp bold white,center bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 48,
                child: const Center(
                  child: Text(
                    '设置',
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

  /// 设置项 - 对齐 TextView 50dp + drawableLeft + drawableRight + 圆角背景
  Widget _buildItem(
    BuildContext context,
    String title,
    String iconPath,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            // 对齐 dialog_ccc_bord_bg:浅灰圆角边框
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Image.asset(iconPath, width: 24, height: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.settingItemText,
                    fontSize: 16,
                  ),
                ),
              ),
              Image.asset(AppAssets.arrowRight, width: 16, height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
