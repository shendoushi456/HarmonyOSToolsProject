import 'package:flutter/material.dart';
import 'package:webview_flutter_ohos/webview_flutter_ohos.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// 对应 Android XieYiActivity：在应用内 WebView 加载协议 URL，而不是展示本地占位文本。
class WebPolicyPage extends StatefulWidget {
  const WebPolicyPage({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<WebPolicyPage> createState() => _WebPolicyPageState();
}

class _WebPolicyPageState extends State<WebPolicyPage> {
  late final PlatformWebViewController _controller;
  int _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller =
        PlatformWebViewController(OhosWebViewControllerCreationParams())
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setPlatformNavigationDelegate(
            PlatformNavigationDelegate(
              const PlatformNavigationDelegateCreationParams(),
            )
              ..setOnProgress((progress) {
                if (mounted) setState(() => _progress = progress);
              })
              ..setOnWebResourceError((error) {
                if (mounted) {
                  setState(() => _error = error.description);
                }
              }),
          )
          ..loadRequest(LoadRequestParams(uri: Uri.parse(widget.url)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          PlatformWebViewWidget(
            PlatformWebViewWidgetCreationParams(controller: _controller),
          ).build(context),
          if (_progress < 100)
            LinearProgressIndicator(
                value: _progress == 0 ? null : _progress / 100),
          if (_error != null)
            Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 42),
                      const SizedBox(height: 12),
                      const Text('协议页面加载失败，请检查网络后重试。'),
                      const SizedBox(height: 8),
                      TextButton(
                          onPressed: () => _controller.reload(),
                          child: const Text('重新加载')),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
