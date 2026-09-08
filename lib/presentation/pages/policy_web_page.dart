import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_ohos/webview_flutter_ohos.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// 协议页 —— 对应 Android setting 模块 PolicyToolsSetActivity /
/// PolicySettActivity + activity_policy_tools_set.xml（两页仅来源类不同，
/// 布局一致）：渐变背景（#A7C6FA→#E6EBEE）+ 55dp 标题栏（标题 GONE）+
/// 小人图与协议名（shezhi_xiaoren + 30sp 白字）+ 白色上圆角 WebView 容器。
/// 协议地址（api.hnrsyc.top）当前已失效，预检失败时显示错误提示与重试。
class PolicyWebPage extends StatefulWidget {
  const PolicyWebPage({super.key, required this.title, required this.url});

  /// 协议名（nameTv 显示，如 "用户协议"）。
  final String title;

  /// 协议 URL（原版 Intent extra CONTENT）。
  final String url;

  @override
  State<PolicyWebPage> createState() => _PolicyWebPageState();
}

class _PolicyWebPageState extends State<PolicyWebPage> {
  PlatformWebViewController? _controller;
  final Dio _dio = Dio();

  bool _checking = true;
  bool _loadError = false;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  Future<void> _initController() async {
    if (mounted) {
      setState(() {
        _checking = true;
        _loadError = false;
        _controller = null;
        _progress = 0;
      });
    }

    // 预检协议地址可达性，避免 WebView 长时间空白。
    final reachable = await _checkUrl(widget.url);
    if (!mounted) return;
    setState(() => _checking = false);
    if (!reachable) {
      setState(() => _loadError = true);
      return;
    }

    final controller =
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
                if (mounted) setState(() => _loadError = true);
              }),
          )
          ..loadRequest(LoadRequestParams(uri: Uri.parse(widget.url)));

    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  Future<bool> _checkUrl(String url) async {
    try {
      final response = await _dio.get<void>(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final code = response.statusCode;
      return code != null && code >= 200 && code < 400;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // shape_jianbian_shezhi：上 #A7C6FA → 下 #E6EBEE 渐变
      body: SafeArea(
        top:true,
        child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA7C6FA), Color(0xFFE6EBEE)],
          ),
        ),
        child: Column(
          children: [
            // 55dp 标题栏：iv_back 返回（title_tv 为 GONE）
            SizedBox(
              height: 55,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Image.asset(
                      'assets/images/recipes_tools/iv_back.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
            ),
            // 小人图 + 协议名（各占一半，行高 120dp）
            SizedBox(
              height: 120,
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/recipes_tools/shezhi_xiaoren.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 155), // 原布局 marginTop 155dp
            // 白色上圆角容器（shape_30_white）：marginH 20、paddingH 15
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _buildBody(context),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_checking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 42),
            const SizedBox(height: 12),
            const Text('页面加载失败，请检查网络后重试。'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _initController,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20), // WebView marginTop 20dp
          child: PlatformWebViewWidget(
            PlatformWebViewWidgetCreationParams(controller: controller),
          ).build(context),
        ),
        if (_progress < 100)
          LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100),
      ],
    );
  }
}
