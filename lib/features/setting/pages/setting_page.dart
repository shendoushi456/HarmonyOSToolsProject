// 设置主页 - 对齐 Android Setting4Activity + Setting4ToolFragment + fragment_setting_tool_4_layout.xml
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/prefs_storage.dart';
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
          // _buildRevokeAgreementItem(context),
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

  /// 对齐 Android SettingToolFragment2：二次确认后清空本地数据并退出应用。
  Widget _buildRevokeAgreementItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: GestureDetector(
        onTap: () => _confirmRevokeAgreement(context),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFECACA)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '撤销同意用户协议',
                  style: TextStyle(color: Color(0xFFB91C1C), fontSize: 16),
                ),
              ),
              Image.asset(AppAssets.arrowRight, width: 16, height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRevokeAgreement(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('温馨提示'),
        content: Text(
          '撤销同意隐私政策及用户协议后，将清空当前所有信息并退出应用。'
          '如果您撤回对“${AppInfoUtil.appName}”隐私政策的同意，我们将停止收集您的个人信息，'
          '并按照法律规定删除应用所收集的个人信息，但法律法规另有保存期限规定的除外。'
          '因为“${AppInfoUtil.appName}”服务依赖必要的个人信息收集，如您撤销同意，'
          '则视为您不同意我们继续提供服务。确定撤销？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认撤销'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final cleared = await PrefsStorage.clearAll();
      if (!cleared) {
        messenger.showSnackBar(const SnackBar(content: Text('撤销失败，请重试')));
        return;
      }
      messenger.showSnackBar(const SnackBar(content: Text('操作成功，3 秒后应用将自动退出')));
      await Future<void>.delayed(const Duration(seconds: 3));
      // SystemNavigator.pop() 仅关闭当前 Flutter 容器，OpenHarmony 会回到桌面。
      // 撤销协议需要终止整个应用进程，确保下次启动重新展示协议引导。
      exit(0);
    } catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('撤销失败，请重试')));
      }
    }
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
