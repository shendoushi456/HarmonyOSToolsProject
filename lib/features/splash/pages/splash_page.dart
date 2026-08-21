// 启动页 - 对齐 Android SplashActivity.java
// 检查隐私协议同意状态,未同意显示弹框,已同意跳转主页
import 'dart:io';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    // 延迟到首帧后检查,确保 context 可用
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAgreement());
  }

  /// 检查隐私协议同意状态 - 对齐 SplashActivity.onCreate 行 23-28
  void _checkAgreement() {
    if (!mounted) return;
    final agreed = PrefsStorage.loadIsAgressment();
    if (!agreed) {
      _showProtocolDialog();
    } else {
      _toMain();
    }
  }

  /// 跳转主页 - 对齐 SplashActivity.toMain
  void _toMain() {
    context.go(RoutePaths.weather);
  }

  /// 显示隐私协议弹框 - 对齐 SplashActivity.showProtocolDialog
  void _showProtocolDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 对齐 setCanceledOnTouchOutside(false)
      builder: (dialogContext) => _ProtocolDialog(
        onAgree: () async {
          await PrefsStorage.saveIsAgressment(true);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          _toMain();
        },
        onRefuse: () {
          Navigator.of(dialogContext).pop();
          // 退出应用进程 - 对齐 Android SplashActivity refuse→finish()
          // ohos 上 SystemNavigator.pop 可能不生效,用 exit(0) 确保真正退出
          // isAgressment 不保存(仍为 false),下次打开会重新显示弹框
          exit(0);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo 100x100 - 对齐 activity_splash.xml marginTop 150
            Image.asset(AppAssets.appLogo, width: 100, height: 100),
            // 应用名 18sp bold black marginTop 50
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Text(
                AppInfoUtil.appName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 隐私协议弹框 - 对齐 Android ProtocolDialog + dialog_protocol_layout.xml
class _ProtocolDialog extends StatelessWidget {
  final Future<void> Function() onAgree;
  final VoidCallback onRefuse;

  const _ProtocolDialog({required this.onAgree, required this.onRefuse});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 应用名 22sp #121212 - 对齐行 10-18
            Text(
              AppInfoUtil.appName,
              style: const TextStyle(
                color: Color(0xFF121212),
                fontSize: 22,
              ),
            ),
            // "欢迎使用" 14sp #333 - 对齐行 20-27
            _buildParagraph('欢迎使用', const Color(0xFF333333),
                top: 20),
            // 说明文字 1 - 对齐行 29-37
            _buildParagraph(
              '为了向您提供最佳的服务，我们会根据您在使用时的具体服务功能，收集必要的设备信息以及您设备的存储权限、网络权限、日历和读写等权限。',
              const Color(0xFF333333),
              top: 10),
            // 说明文字 2 - 对齐行 39-47
            _buildParagraph(
              '当您在使用具体功能时、我们需要获取您与该功能相对应的权限。未经您的同意，我们不会向第三方披露、共享或者提供您的个人信息。',
              const Color(0xFF333333),
              top: 10),
            // "您可阅读完整的" - 对齐行 49-56
            _buildParagraph('您可阅读完整的', Colors.black, top: 10),
            // 协议链接 Row - 对齐行 58-81
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _openPolicy(
                        context, '隐私政策', SettingUrls.policy),
                    child: const Text(
                      '《隐私协议》',
                      style: TextStyle(
                        color: Color(0xFF3F5BDF),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: GestureDetector(
                      onTap: () => _openPolicy(
                          context, '用户协议', SettingUrls.user),
                      child: const Text(
                        '《用户协议》',
                        style: TextStyle(
                          color: Color(0xFF3F5BDF),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // "各条款信息..." - 对齐行 83-88
            _buildParagraph('各条款信息，来了解详细内容。如您同意，请点击“同意”开始接受我们的服务。',
                Colors.black, top: 10),
            // 同意按钮 - 对齐 Android agreen(match_parent, marginHorizontal=50dp, height=40dp, #3F5BDF 圆角, 18sp white)
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
              child: GestureDetector(
                onTap: onAgree,
                child: Container(
                  width: double.infinity,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F5BDF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '同意',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            // 拒绝 - 对齐行 103-113 (14sp #aaaaaa)
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: GestureDetector(
                onTap: onRefuse,
                child: const Text(
                  '拒绝',
                  style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 段落文字(宽 300) - 对齐 dialog_protocol_layout 的 300dp 宽 TextView
  Widget _buildParagraph(String text, Color color, {double top = 0}) {
    return Container(
      width: 300,
      padding: EdgeInsets.only(top: top, left: 15, right: 15),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 14),
      ),
    );
  }

  /// 打开协议页 - 对齐 ProtocolDialog 的 XieYiActivity 跳转
  void _openPolicy(BuildContext context, String title, String url) {
    context.push(
      RoutePaths.policy,
      extra: {'title': title, 'url': url},
    );
  }
}
