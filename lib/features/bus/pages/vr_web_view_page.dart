// VR 全景 WebView 页 - 对齐 Android WeatherWebViewActivity。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter_ohos/webview_flutter_ohos.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class VrWebViewPage extends StatefulWidget {
  const VrWebViewPage({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<VrWebViewPage> createState() => _VrWebViewPageState();
}

class _VrWebViewPageState extends State<VrWebViewPage> {
  late final PlatformWebViewController _controller;

  @override
  void initState() {
    super.initState();
    // 插件默认开启 DOM Storage；此处显式启用 JS，对齐 Android WebSettings。
    _controller = PlatformWebViewController(
      OhosWebViewControllerCreationParams(isAllowFullScreenRotate: true),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(LoadRequestParams(uri: Uri.parse(widget.url)));
  }

  Future<void> _onBackPressed() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 50,
              color: const Color(0xFF3F5BDF),
              child: Stack(
                children: [
                  Positioned(
                    left: 5,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _onBackPressed,
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PlatformWebViewWidget(
                PlatformWebViewWidgetCreationParams(controller: _controller),
              ).build(context),
            ),
          ],
        ),
      ),
    );
  }
}
