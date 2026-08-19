import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/app_config.dart';
import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';
import 'package:harmonyos_flutter_empty/features/privacy/presentation/providers/privacy_agreement_provider.dart';

/// 启动页
///
/// 对应原 Android `SplashActivity`：
/// - 已同意隐私协议 → 1 秒延时后跳转主页
/// - 未同意 → 显示隐私协议页面（含欢迎文本、权限说明、同意/不同意按钮）
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementState = ref.watch(privacyAgreementProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: agreementState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (agreed) {
          if (agreed) {
            // 已同意，1 秒后跳转主页
            Future<void>.delayed(const Duration(seconds: 1), () {
              if (context.mounted) {
                context.go('/scan_menu');
              }
            });
            return const _SplashLogo();
          }
          return _PrivacyAgreementScreen(
            onAgree: () async {
              await ref.read(privacyAgreementProvider.notifier).agree();
              if (context.mounted) {
                context.go('/scan_menu');
              }
            },
            onDisagree: SystemNavigator.pop,
            onUserAgreementClick: () =>
                context.push('/policy', extra: <String, dynamic>{
              'title': '用户协议',
              'url': AppConfig.userAgreementUrl,
            }),
            onPrivacyPolicyClick: () =>
                context.push('/policy', extra: <String, dynamic>{
              'title': '隐私政策',
              'url': AppConfig.privacyUrl,
            }),
          );
        },
        error: (_, __) => const Center(child: Text('初始化失败')),
      ),
    );
  }
}

/// 启动 Logo（已同意时显示）
class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/ic_logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '扫莱扫',
            style: TextStyle(
              fontSize: 22,
              color: AppColors.langSwitchText,
            ),
          ),
        ],
      ),
    );
  }
}

/// 隐私协议页面
///
/// 对应原 Android `PrivacyAgreementScreen` Compose 页面：
/// 欢迎文本（含可点击的《用户协议》《隐私政策》链接）+ 权限说明 + 同意/不同意按钮。
class _PrivacyAgreementScreen extends StatelessWidget {
  const _PrivacyAgreementScreen({
    required this.onAgree,
    required this.onDisagree,
    required this.onUserAgreementClick,
    required this.onPrivacyPolicyClick,
  });

  final VoidCallback onAgree;
  final VoidCallback onDisagree;
  final VoidCallback onUserAgreementClick;
  final VoidCallback onPrivacyPolicyClick;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 欢迎文本（含可点击链接）
          Center(
            child: ClipOval(
              child: Image.asset(
                'assets/images/ic_logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '扫莱扫',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.langSwitchText,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // 协议说明
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.langSwitchText,
                height: 1.6,
              ),
              children: [
                const TextSpan(text: '欢迎您使用扫莱扫。在使用本应用前，请您仔细阅读并了解'),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: onUserAgreementClick,
                    child: const Text(
                      '《用户协议》',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '和'),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: onPrivacyPolicyClick,
                    child: const Text(
                      '《隐私政策》',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '。我们将严格按照法律法规要求，保护您的个人信息。'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 权限说明
          const Text(
            '申请权限说明',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.langSwitchText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '为了保障应用的正常运行，我们可能会申请以下权限：\n'
            '• 相机权限：用于拍照翻译功能\n'
            '• 存储权限：用于文档翻译的文件选择和保存\n'
            '• 网络权限：用于调用翻译服务',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.hintText,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 40),
          // 按钮
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDisagree,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        '不同意',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.hintText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: onAgree,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.buttonGradientStart,
                          AppColors.buttonGradientEnd,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '同意并继续',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
