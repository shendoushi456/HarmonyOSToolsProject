// 设置主页 - 对齐 Android SettingToolActivity + fragment_setting_tool.xml。
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
          // 从 MenuFragment 进入时所用的原 Android 设置页样式。
          _buildTopBar(context),
          const SizedBox(height: 5),
          // 设置项
          _buildItem(
            context,
            '用户协议',
            AppAssets.menuFragmentSettingUserAgreement,
            () => context.push(
              RoutePaths.policy,
              extra: {'title': '用户协议', 'url': SettingUrls.user},
            ),
          ),
          _buildItem(
            context,
            '隐私协议',
            AppAssets.menuFragmentSettingPrivacy,
            () => context.push(
              RoutePaths.policy,
              extra: {'title': '隐私协议', 'url': SettingUrls.policy},
            ),
          ),
          _buildItem(
            context,
            '关于我们',
            AppAssets.menuFragmentSettingAbout,
            () => context.push(RoutePaths.about),
          ),
          _buildItem(
            context,
            '意见反馈',
            AppAssets.menuFragmentSettingFeedback,
            () => context.push(RoutePaths.feedback),
          ),
        ],
      ),
    );
  }

  /// 顶部栏 - 对齐 fragment_setting_tool.xml: 紫色标题区 + 黑色标题。
  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 78,
      color: const Color(0xFFBB9BFF),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 10,
              bottom: 0,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(AppAssets.menuFragmentSettingBack),
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
                    '设置',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
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

  /// 设置项 - 对齐原 TextView 50dp + 左右 drawable + 白色圆角点击背景。
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Image.asset(iconPath, width: 30, height: 30),
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
              Image.asset(
                AppAssets.menuFragmentSettingArrowRight,
                width: 16,
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
