// 启动页 - 结构参考 master_saolaisao，同时复用当前项目的品牌、存储和协议路由。
import 'dart:async';

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
  bool? _hasAgreed;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAgreement());
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _loadAgreement() {
    if (!mounted) return;
    final hasAgreed = PrefsStorage.loadIsAgressment();
    setState(() => _hasAgreed = hasAgreed);
    if (hasAgreed) _scheduleMainNavigation();
  }

  void _scheduleMainNavigation() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) context.go(RoutePaths.weather);
    });
  }

  Future<void> _agree() async {
    await PrefsStorage.saveIsAgressment(true);
    if (mounted) context.go(RoutePaths.weather);
  }

  void _openPolicy(String title, String url) {
    context.push(RoutePaths.policy, extra: {'title': title, 'url': url});
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (_hasAgreed == null) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_hasAgreed!) {
      content = const _SplashLogo();
    } else {
      content = _PrivacyAgreementScreen(
        onAgree: _agree,
        onDisagree: SystemNavigator.pop,
        onUserAgreementClick: () => _openPolicy('用户协议', SettingUrls.user),
        onPrivacyPolicyClick: () => _openPolicy('隐私协议', SettingUrls.policy),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: content,
    );
  }
}

/// 已同意时展示的启动 Logo，整体结构与 master_saolaisao 保持一致。
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
              AppAssets.appLogo,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            AppInfoUtil.appName,
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }
}

/// 未同意时展示的整页协议说明，避免 Dialog 被原生启动窗口或安全区遮挡。
class _PrivacyAgreementScreen extends StatelessWidget {
  const _PrivacyAgreementScreen({
    required this.onAgree,
    required this.onDisagree,
    required this.onUserAgreementClick,
    required this.onPrivacyPolicyClick,
  });

  final Future<void> Function() onAgree;
  final VoidCallback onDisagree;
  final VoidCallback onUserAgreementClick;
  final VoidCallback onPrivacyPolicyClick;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
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
            const Center(
              child: Text(
                AppInfoUtil.appName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _AgreementIntro(
              onUserAgreementClick: onUserAgreementClick,
              onPrivacyPolicyClick: onPrivacyPolicyClick,
            ),
            const SizedBox(height: 20),
            const Text(
              '申请权限说明',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '为了保障出行服务的正常运行，我们可能会申请以下权限：\n'
              '• 位置权限：用于定位当前城市和出行导航\n'
              '• 存储权限：用于保存必要的服务数据\n'
              '• 网络权限：用于获取天气、地图和出行服务',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF616161),
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
                    backgroundColor: const Color(0xFFE0E0E0),
                    textColor: const Color(0xFF616161),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AgreementButton(
                    label: '同意并继续',
                    onTap: onAgree,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF728CF1), Color(0xFF3F5BDF)],
                    ),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgreementIntro extends StatelessWidget {
  const _AgreementIntro({
    required this.onUserAgreementClick,
    required this.onPrivacyPolicyClick,
  });

  final VoidCallback onUserAgreementClick;
  final VoidCallback onPrivacyPolicyClick;

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF1E1E1E),
      height: 1.6,
    );
    const linkStyle = TextStyle(color: Color(0xFF3F5BDF), fontSize: 14);

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: '欢迎您使用${AppInfoUtil.appName}。在使用本应用前，请您仔细阅读并了解'),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onUserAgreementClick,
              child: const Text('《用户协议》', style: linkStyle),
            ),
          ),
          const TextSpan(text: '和'),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onPrivacyPolicyClick,
              child: const Text('《隐私协议》', style: linkStyle),
            ),
          ),
          const TextSpan(text: '。我们将严格按照法律法规要求，保护您的个人信息。'),
        ],
      ),
    );
  }
}

class _AgreementButton extends StatelessWidget {
  const _AgreementButton({
    required this.label,
    required this.onTap,
    required this.textColor,
    this.backgroundColor,
    this.gradient,
  });

  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color? backgroundColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
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
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
