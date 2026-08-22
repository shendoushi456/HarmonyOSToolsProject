// “更多”Tab：复用原空气质量页设置入口的设置内容，作为底部导航中的 Fragment 展示。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../router/route_names.dart';
import '../utils/app_info_util.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 48,
              color: AppColors.settingTheme,
              alignment: Alignment.center,
              child: const Text(
                '更多',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Image.asset(AppAssets.appLogo, width: 86, height: 86),
            ),
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
            _MoreItem(
              title: '用户协议',
              iconPath: AppAssets.settingUserIcon,
              onTap: () => context.push(
                RoutePaths.policy,
                extra: {'title': '用户协议', 'url': SettingUrls.user},
              ),
            ),
            _MoreItem(
              title: '隐私协议',
              iconPath: AppAssets.settingPrivateIcon,
              onTap: () => context.push(
                RoutePaths.policy,
                extra: {'title': '隐私协议', 'url': SettingUrls.policy},
              ),
            ),
            _MoreItem(
              title: '关于我们',
              iconPath: AppAssets.settingAboutIcon,
              onTap: () => context.push(RoutePaths.about),
            ),
            _MoreItem(
              title: '意见反馈',
              iconPath: AppAssets.settingFeedbackIcon,
              onTap: () => context.push(RoutePaths.feedback),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  final String title;
  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
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
