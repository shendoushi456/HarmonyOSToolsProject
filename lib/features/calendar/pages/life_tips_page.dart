// 生活小贴士 H5 页 - 对齐 Android WeatherWebViewActivity + layout_app_bar_title.xml
// 标题栏 #3F5BDF 深蓝 + ic_back 返回箭头(白色) + tv_title 白色居中
// 加载本地 H5: file:///android_asset/xiaoqiaomen.html → loadFlutterAsset('assets/xiaoqiaomen.html')
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter_ohos/webview_flutter_ohos.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../../../core/constants/app_assets.dart';

class LifeTipsPage extends StatefulWidget {
  final String title;

  const LifeTipsPage({super.key, this.title = '生活小贴士'});

  @override
  State<LifeTipsPage> createState() => _LifeTipsPageState();
}

class _LifeTipsPageState extends State<LifeTipsPage> {
  late final PlatformWebViewController _controller;

  @override
  void initState() {
    super.initState();
    // 初始化 WebView 并加载本地 H5 资源
    // 对齐 Android webView.loadUrl("file:///android_asset/xiaoqiaomen.html")
    // 鸿蒙端用 loadFlutterAsset 自动解析 Flutter 资源路径
    _controller = PlatformWebViewController(
      OhosWebViewControllerCreationParams(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/xiaoqiaomen.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 标题栏 - 对齐 Android layout_app_bar_title.xml
          // 背景 #3F5BDF + 返回箭头 ic_back(白色) + tv_title(白色居中)
          Container(
            color: const Color(0xFF3F5BDF),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 55,
                child: Stack(
                  children: [
                    // 返回按钮 - 对齐 Android backIv ic_back marginLeft 15
                    Positioned(
                      left: 15,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Center(
                          child: Image.asset(
                            AppAssets.webviewBack,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ),
                    // 标题 - 对齐 Android tv_title 18sp white center
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
          // WebView H5 内容区 - 对齐 Android webView
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
