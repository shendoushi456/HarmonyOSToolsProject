// 二十四节气 H5 页 - 对齐 Android WeatherWebViewActivity
// 加载本地 H5: file:///android_asset/ershisijieqi/index.html → loadFlutterAsset('assets/ershisijieqi/index.html')
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter_ohos/webview_flutter_ohos.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class SolarTermsPage extends StatefulWidget {
  final String title;

  const SolarTermsPage({super.key, this.title = '24节气'});

  @override
  State<SolarTermsPage> createState() => _SolarTermsPageState();
}

class _SolarTermsPageState extends State<SolarTermsPage> {
  late final PlatformWebViewController _controller;

  @override
  void initState() {
    super.initState();
    // 初始化 WebView 并加载本地 H5 资源 - 对齐 Android webView.loadUrl("file:///android_asset/ershisijieqi/index.html")
    // 鸿蒙端用 loadFlutterAsset 自动解析 Flutter 资源路径到 rawfile/flutter_assets/ 下
    _controller = PlatformWebViewController(
      OhosWebViewControllerCreationParams(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/ershisijieqi/index.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部栏 - 对齐 Android WeatherWebViewActivity 标题栏
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 55,
                child: Stack(
                  children: [
                    // 返回按钮
                    Positioned(
                      left: 15,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: const Center(
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                    // 标题
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.black,
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
          // WebView H5 内容区
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
