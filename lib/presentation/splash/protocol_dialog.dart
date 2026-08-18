import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/setting_repository.dart';

/// 首次启动协议同意弹框
///
/// 对应 Android: ProtocolDialog.java + dialog_protocol_layout.xml
/// 白色圆角弹框 + 标题 + 说明文字 + 协议链接 + 同意/拒绝按钮。
class ProtocolDialogWidget extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback onRefuse;

  const ProtocolDialogWidget({
    super.key,
    required this.onAgree,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题（app_name 22sp 0xFF121212 居中 marginTop 10）
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '悠游出行',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF121212),
                ),
              ),
            ),
            // "欢迎使用"（14sp 0xFF333333 marginTop 20）
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '欢迎使用',
                  style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
                ),
              ),
            ),
            // 说明文字 1（14sp 0xFF333333 marginTop 10）
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '为了向您提供最佳的服务，我们会根据您在使用时的具体服务功能，收集必要的设备信息以及您设备的存储权限、网络权限、日历和读写等权限。',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
            ),
            // 说明文字 2（14sp 0xFF333333 marginTop 10）
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '当您在使用具体功能时、我们需要获取您与该功能相对应的权限。未经您的同意，我们不会向第三方披露、共享或者提供您的个人信息。',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
            ),
            // "您可阅读完整的"（黑色 marginTop 10）
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '您可阅读完整的',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
            // 协议链接行（marginTop 10）
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => context.push(
                      '/settings/policy',
                      extra: {
                        'title': '隐私政策',
                        'url': SettingUrlConstants.policyUrl,
                      },
                    ),
                    child: const Text(
                      '《隐私协议》',
                      style: TextStyle(fontSize: 14, color: Color(0xFF3F5BDF)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => context.push(
                      '/settings/policy',
                      extra: {
                        'title': '用户协议',
                        'url': SettingUrlConstants.userUrl,
                      },
                    ),
                    child: const Text(
                      '《用户协议》',
                      style: TextStyle(fontSize: 14, color: Color(0xFF3F5BDF)),
                    ),
                  ),
                ],
              ),
            ),
            // "各条款信息..."（黑色 marginTop 10）
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '各条款信息，来了解详细内容。如您同意，请点击"同意"开始接受我们的服务。',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            // "同意" 按钮（260x40 白字 18sp 红色圆角 marginTop 20）
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: 260,
                height: 40,
                child: ElevatedButton(
                  onPressed: onAgree,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('同意', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
            // "拒绝"（14sp 0xFFAAAAAA 灰色 marginTop 20 marginBottom 20）
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: GestureDetector(
                onTap: onRefuse,
                child: const Text(
                  '拒绝',
                  style: TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
