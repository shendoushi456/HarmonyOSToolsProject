// 协议页 - 对齐 Android third-module/setting PolicyToolsSetActivity + activity_policy_tools_set.xml
// 白底;顶栏 50dp #6FBFFF(purple_200) + 白色返回键(icon_white_back) + 白 20sp 动态标题;
// WebView 占满剩余;参数机制复用现有路由(title/url)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter_ohos/webview_flutter_ohos.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../../../core/constants/app_assets.dart';

/// setting 模块主题色(对齐 colors.xml purple_200)
const Color kSettingBoxTheme = Color(0xFF6FBFFF);

class PolicyPage extends StatefulWidget {
  final String title;
  final String url;

  const PolicyPage({super.key, required this.title, required this.url});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  late final PlatformWebViewController _controller;

  @override
  void initState() {
    super.initState();
    // 对齐 PolicyToolsSetActivity: webView.loadUrl(content)
    _controller = PlatformWebViewController(
      OhosWebViewControllerCreationParams(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(LoadRequestParams(uri: Uri.parse(widget.url)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶栏 50dp #6FBFFF + 白返回键(icon_white_back 48dp padding14) + 白 20sp 标题
          Container(
            color: kSettingBoxTheme,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500)),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(AppAssets.settingBoxIconWhiteBack,
                              width: 20, height: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // WebView 占满(对齐 activity_policy_tools_set 布局)
          Expanded(
            child: PlatformWebViewWidget(
              PlatformWebViewWidgetCreationParams(controller: _controller),
            ).build(context),
          ),
        ],
      ),
    );
  }
}
