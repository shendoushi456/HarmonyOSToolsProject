import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 协议页（用户协议/隐私协议）
///
/// 对应 Android: PolicyToolsSetActivity / PolicyActivity
/// 蓝色顶栏 0xFF6FBFFF + 标题 + 返回 + 内嵌 WebView 加载 URL。
class PolicyPage extends StatefulWidget {
  final String title;
  final String url;

  const PolicyPage({super.key, required this.title, required this.url});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 蓝色顶栏（bg=#6FBFFF height=50 白色返回+标题 20sp）
          SafeArea(
            bottom: false,
            child: Container(
              height: 50,
              color: const Color(0xFF6FBFFF),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            'assets/images/setting/icon_white_back.webp',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            // 通过项目内注册的 ArkWeb PlatformView 加载，页面不会跳出 App。
            child: OhosView(
              viewType: 'hm.lxhy.youyouxing/policy_webview',
              creationParams: <String, Object>{'url': widget.url},
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
        ],
      ),
    );
  }
}
