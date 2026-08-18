import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../application/services/external_app_service.dart';
import '../../data/repositories/setting_repository.dart';

/// 设置页（替换原 SettingsPlaceholderPage）
///
/// 对应 Android: SettSet2Activity + SettingToolFragment2
/// 背景图 bg2 + 返回按钮 + Logo + 应用名 + 3 行功能网格（6 项）。
/// 原布局中广告位、隐私中心、个性化推荐+Switch 均 gone，此处不显示。
class SettingsPage extends StatelessWidget {
  static const _agreementKey = 'isAgressment';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/setting/bg2.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 返回按钮（对应 imgeIv，iv_back.png 35x35 marginTop 15）
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 15),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: Image.asset('assets/images/setting/iv_back.png'),
                    ),
                  ),
                ),
              ),
              // Logo（ic_logo 90x90 marginTop 30）
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Image.asset('assets/images/setting/ic_logo.png'),
                ),
              ),
              // 应用名（16sp 0xFF333333 marginTop 16）
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  '悠游出行',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              // 第一行：隐私协议 + 用户协议（marginTop 44）
              Padding(
                padding: const EdgeInsets.only(top: 44),
                child: Row(
                  children: [
                    _GridItem(
                      icon: 'assets/images/setting/ic_privacy.webp',
                      title: '隐私协议',
                      onTap: () => context.push(
                        '/settings/policy',
                        extra: {
                          'title': '隐私协议',
                          'url': SettingUrlConstants.policyUrl,
                        },
                      ),
                    ),
                    _GridItem(
                      icon: 'assets/images/setting/ic_user_agreement.png',
                      title: '用户协议',
                      onTap: () => context.push(
                        '/settings/policy',
                        extra: {
                          'title': '用户协议',
                          'url': SettingUrlConstants.userUrl,
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // 第二行：关于我们 + 意见反馈（marginTop 38）
              Padding(
                padding: const EdgeInsets.only(top: 38),
                child: Row(
                  children: [
                    _GridItem(
                      icon: 'assets/images/setting/ic_about_us.webp',
                      title: '关于我们',
                      onTap: () => context.push('/settings/about'),
                    ),
                    _GridItem(
                      icon: 'assets/images/setting/ic_feedback.webp',
                      title: '意见反馈',
                      onTap: () => context.push('/settings/feedback'),
                    ),
                  ],
                ),
              ),
              // 第三行：撤销同意用户协议 + 账号注销（marginTop 38）
              Padding(
                padding: const EdgeInsets.only(top: 38),
                child: Row(
                  children: [
                    _GridItem(
                      icon: 'assets/images/setting/setting_4_revoke_icon.png',
                      title: '撤销同意用户协议',
                      onTap: () => _showRevokeDialog(context),
                    ),
                    _GridItem(
                      icon: 'assets/images/setting/setting_4_cancel_icon.png',
                      title: '账号注销',
                      onTap: () => _showCancelDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 撤销同意用户协议对话框
  /// 对应 Android: SettingToolFragment2.kt:116-141 showRevokeAgreementDialog
  void _showRevokeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('温馨提示'),
        content: const Text(
          '撤销同意隐私政策及用户协议后，将清空当前所有信息并退出应用。'
          '如果您撤回对"悠游出行"隐私政策的同意，我们将会停止收集您的个人信息，'
          '并按照法律规定删除应用所收集的个人信息，但其他法律法规对于个人信息保存期限有明确规定的除外。'
          '因为"悠游出行"服务的提供依赖于必要的个人信息收集，如您撤销同意，'
          '则视为您不同意我们继续向您提供"悠游出行"的服务。确定撤销?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ExternalAppService().setBool(_agreementKey, false);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _performAppExit(context);
            },
            child: const Text('确认撤销'),
          ),
        ],
      ),
    );
  }

  /// 账号注销对话框（两级）
  /// 对应 Android: SettingToolFragment2.kt:146-176
  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('注销提示'),
        content: const Text('注销账号是不可恢复的操作，操作之前请确认与账号相关的服务均可进行妥善处理'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showCancelConfirmDialog(context);
            },
            child: const Text('继续注销'),
          ),
        ],
      ),
    );
  }

  /// 确认注销对话框
  void _showCancelConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认注销账号'),
        content: const Text('我们将彻底删除你的相关信息，一旦删除将不可恢复，请确认是否注销'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performAppExit(context);
            },
            child: const Text('确认注销'),
          ),
        ],
      ),
    );
  }

  /// 执行应用退出（Toast + 3秒后退出）
  /// 对应 Android: Toast + delay(3000) + clearApplicationUserData + finishAffinity
  void _performAppExit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('操作成功，3秒后应用将自动退出'),
        duration: Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      SystemNavigator.pop();
    });
  }
}

/// 设置页网格项（图标 + 标题，对应 TextView + drawableTop）
/// 图标原始 120px (xxhdpi 3x) = 40dp
class _GridItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _GridItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(icon),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
