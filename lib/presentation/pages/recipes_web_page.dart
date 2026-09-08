import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_ohos/webview_flutter_ohos.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../features/health_tips/health_tips_view_model.dart';

/// 食谱 WebView 页 —— 同时对应 Android 两个页面：
/// - SPuActivity：[spuExtra]（"1"~"8"）加载远程食物列表，标题 GONE；
/// - ShiPuActivity：[shipuTitle]（菜名）加载本地减脂食谱 HTML，标题居中显示。
/// 标题栏样式对应 activity_spu.xml / activity_shipu.xml：
/// 50dp 白底 + back_black_iv 24dp + 标题 16sp bold #353535，WebView 顶部留 60dp。
///
/// 远程地址（forwinsoft.com:8080）已因 ICP 备案问题被阿里云拦截（403），
/// 加载后只会渲染空白拦截页，故远程模式先预检：服务不可用时展示
/// 错误提示与重试按钮（样式与 WebPolicyPage 一致），避免白屏。
class RecipesWebPage extends StatefulWidget {
  const RecipesWebPage({super.key, this.spuExtra, this.shipuTitle});

  final String? spuExtra;
  final String? shipuTitle;

  @override
  State<RecipesWebPage> createState() => _RecipesWebPageState();
}

class _RecipesWebPageState extends State<RecipesWebPage> {
  PlatformWebViewController? _controller;
  final Dio _dio = Dio();

  bool _checking = false; // 远程 URL 预检中
  bool _loadError = false; // 远程服务不可用（403/超时/网络错误）
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
        _checking = false;
        _loadError = false;
        _controller = null;
        _progress = 0;
      });
    }

    String? remoteUrl;
    if (widget.spuExtra != null) {
      // SPuActivity 逻辑：分类 id → 远程 URL。
      remoteUrl = HealthTipsViewModel.spuUrls[widget.spuExtra!];
    }

    if (remoteUrl != null) {
      // 远程模式：先预检服务状态（fragment 不会发送到服务端）。
      if (mounted) setState(() => _checking = true);
      final reachable = await _checkRemote(remoteUrl);
      if (!mounted) return;
      setState(() => _checking = false);
      if (!reachable) {
        setState(() => _loadError = true);
        return;
      }
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
                // 网络层失败（DNS 不通、连接重置等）时给出提示。
                if (mounted) setState(() => _loadError = true);
              }),
          );

    if (widget.spuExtra != null) {
      if (remoteUrl != null) {
        await controller
            .loadRequest(LoadRequestParams(uri: Uri.parse(remoteUrl)));
      } else if (widget.spuExtra == '空气炸锅椒盐花菜') {
        // SPuActivity 里保留的本地分支，保真迁移。
        await controller.loadFlutterAsset(
            'assets/recipes/jianzhi/kongqi_jiaoyan_huacai.html');
      }
    } else if (widget.shipuTitle != null) {
      // ShiPuActivity 逻辑：菜名 → 本地 HTML。
      // "糖尿病食谱"/"减脂食谱" 对应的 html 文件在原工程 assets 中并不存在，
      // 安卓 WebView 会显示加载失败页，此处保真：仍按原路径加载让其失败。
      final asset = HealthTipsViewModel.shipuAssetHtml[widget.shipuTitle!];
      if (asset != null) {
        await controller.loadFlutterAsset(asset);
      }
      // 无匹配（如 "食物热量"）时安卓不加载任何地址，WebView 空白，保真保留。
    }

    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  /// 预检远程地址：HTTP 200 视为可用（拦截页为 403）。
  Future<bool> _checkRemote(String url) async {
    try {
      final response = await _dio.get<void>(
        url,
        options: Options(
          // 拦截页内容很小，直接接收；只需状态码。
          followRedirects: true,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top:true,
        child: Column(
        children: [
          // 50dp 标题栏（activity_spu / activity_shipu）
          SizedBox(
            height: 50,
            child: Stack(
              children: [
                // SPuActivity 中标题 GONE，仅 ShiPuActivity 显示
                if (widget.shipuTitle != null)
                  Center(
                    child: Text(
                      widget.shipuTitle!,
                      style: const TextStyle(
                        color: Color(0xFF353535),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Image.asset(
                        'assets/images/recipes_tools/back_black_iv.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // WebView 区域：marginTop 60dp（50dp 标题栏 + 10dp 间隙）
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _buildBody(context),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_checking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
          ),
        ),
      );
    }
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        PlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams(controller: controller),
        ).build(context),
        if (_progress < 100)
          LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100),
      ],
    );
  }
}
