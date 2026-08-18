import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../application/services/external_app_service.dart';
import 'protocol_dialog.dart';

/// 启动页
///
/// 对应 Android: SplashActivity.java
/// 白色背景 + Logo + 应用名。
/// - 检查 isAgressment（SharedPreferences）
///   - 已同意 → 直接进入主页面
///   - 未同意 → 显示协议弹框
///     - 同意 → 保存同意状态 + 进入主页面
///     - 拒绝 → 清除同意状态 + 退出应用；下次启动继续显示弹框
/// 广告（AuditAdUtilsNew）为干扰项，不迁移。
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _service = ExternalAppService();
  static const _agreementKey = 'isAgressment';

  @override
  void initState() {
    super.initState();
    _checkAgreement();
  }

  Future<void> _checkAgreement() async {
    final agreed = await _service.getBool(_agreementKey, false);
    if (!mounted) return;
    if (agreed) {
      _goToMain();
    } else {
      _showProtocolDialog();
    }
  }

  void _showProtocolDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // 对应 setCanceledOnTouchOutside(false)
      builder: (ctx) => ProtocolDialogWidget(
        onAgree: () async {
          await _service.setBool(_agreementKey, true);
          if (!ctx.mounted) return;
          Navigator.pop(ctx);
          _goToMain();
        },
        onRefuse: () async {
          // 仅“同意”可保留授权状态。拒绝时显式覆盖旧值，
          // 防止曾同意过又拒绝后下次启动绕过协议弹框。
          await _service.setBool(_agreementKey, false);
          if (!ctx.mounted) return;
          Navigator.pop(ctx);
          await _service.exitApp();
        },
      ),
    );
  }

  void _goToMain() {
    if (!mounted) return;
    context.go('/scan-menu'); // 替换当前路由，进入主页面
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo（100x100 marginTop 150）
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset('assets/images/setting/ic_logo.png'),
          ),
          // 应用名（18sp bold black marginTop 50）
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: const Text(
              '悠游出行',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
