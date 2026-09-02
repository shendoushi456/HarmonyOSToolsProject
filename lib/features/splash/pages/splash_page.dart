// 启动页流程对齐 master_saolaisao：
// 已同意协议 → Logo 首屏停留 1 秒后进入主页；未同意 → 首屏直接展示隐私协议引导。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/storage/prefs_storage.dart';
import '../../../router/route_names.dart';
import '../../setting/utils/app_info_util.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool? _agreed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final agreed = PrefsStorage.loadIsAgressment();
      setState(() => _agreed = agreed);
      if (agreed) _enterHomeAfterSplash();
    });
  }

  Future<void> _enterHomeAfterSplash() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) context.go(RoutePaths.weather);
  }

  Future<void> _agreeAndContinue() async {
    await PrefsStorage.saveIsAgressment(true);
    if (mounted) context.go(RoutePaths.weather);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _agreed == null
            ? const Center(child: CircularProgressIndicator())
            : _agreed!
                ? const _SplashLogo()
                : _PrivacyAgreementScreen(
                    onAgree: _agreeAndContinue,
                    onDisagree: SystemNavigator.pop,
                    onUserAgreementClick: () => context.push(
                      RoutePaths.policy,
                      extra: {
                        'title': '用户协议',
                        'url': SettingUrls.user,
                      },
                    ),
                    onPrivacyPolicyClick: () => context.push(
                      RoutePaths.policy,
                      extra: {
                        'title': '隐私政策',
                        'url': SettingUrls.policy,
                      },
                    ),
                  ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                AppAssets.appLogo,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppInfoUtil.appName,
              style: const TextStyle(
                fontSize: 22,
                color: Color(0xFF1D2838),
              ),
            ),
          ],
        ),
      );
}

class _PrivacyAgreementScreen extends StatelessWidget {
  final Future<void> Function() onAgree;
  final VoidCallback onDisagree;
  final VoidCallback onUserAgreementClick;
  final VoidCallback onPrivacyPolicyClick;

  const _PrivacyAgreementScreen({
    required this.onAgree,
    required this.onDisagree,
    required this.onUserAgreementClick,
    required this.onPrivacyPolicyClick,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipOval(
                child: Image.asset(
                  AppAssets.appLogo,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                AppInfoUtil.appName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D2838),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _AgreementText(
              onUserAgreementClick: onUserAgreementClick,
              onPrivacyPolicyClick: onPrivacyPolicyClick,
            ),
            const SizedBox(height: 20),
            const Text(
              '申请权限说明',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D2838),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '为了保障应用的正常运行，我们可能会申请以下权限：\n'
              '• 网络权限：用于获取天气、空气质量与预警数据\n'
              '• 存储权限：用于保存城市、农作物记录和出行规划\n'
              '• 定位权限：用于为您提供所在城市的天气信息',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7A8491),
                height: 1.8,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: _AgreementButton(
                    label: '不同意',
                    onTap: onDisagree,
                    background: const Color(0xFFE8EBEF),
                    foreground: const Color(0xFF7A8491),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AgreementButton(
                    label: '同意并继续',
                    onTap: onAgree,
                    foreground: Colors.white,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF63C8FF), Color(0xFF3F5BDF)],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _AgreementText extends StatelessWidget {
  final VoidCallback onUserAgreementClick;
  final VoidCallback onPrivacyPolicyClick;

  const _AgreementText({
    required this.onUserAgreementClick,
    required this.onPrivacyPolicyClick,
  });

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1D2838),
            height: 1.6,
          ),
          children: [
            TextSpan(text: '欢迎您使用${AppInfoUtil.appName}。在使用本应用前，请您仔细阅读并了解'),
            WidgetSpan(
              child: _AgreementLink(
                text: '《用户协议》',
                onTap: onUserAgreementClick,
              ),
            ),
            const TextSpan(text: '和'),
            WidgetSpan(
              child: _AgreementLink(
                text: '《隐私政策》',
                onTap: onPrivacyPolicyClick,
              ),
            ),
            const TextSpan(text: '。我们将严格按照法律法规要求，保护您的个人信息。'),
          ],
        ),
      );
}

class _AgreementLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AgreementLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF3F5BDF), fontSize: 14),
        ),
      );
}

class _AgreementButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color foreground;
  final Color? background;
  final Gradient? gradient;

  const _AgreementButton({
    required this.label,
    required this.onTap,
    required this.foreground,
    this.background,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            gradient: gradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: gradient == null
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
        ),
      );
}
