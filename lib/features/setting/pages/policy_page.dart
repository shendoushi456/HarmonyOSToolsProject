// 协议页 - 对齐 Android XieYiActivity + activity_xieyi.xml
// 用 webview_flutter_ohos 应用内显示协议内容
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter_ohos/webview_flutter_ohos.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

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
    // 初始化 WebView 并加载协议 URL - 对齐 XieYiActivity webView.loadUrl(content)
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
          // 顶部栏 55dp #4461FF - 对齐 activity_xieyi include_title
          Container(
            color: const Color(0xFF4461FF),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 55,
                child: Stack(
                  children: [
                    // 返回按钮 - 对齐 backIv marginLeft 15
                    Positioned(
                      left: 15,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: const Center(
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ),
                    // 标题 - 对齐 title_tv 18sp white center
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // WebView - 对齐 activity_xieyi webview
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
