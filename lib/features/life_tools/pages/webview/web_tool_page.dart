// 通用 WebView 容器页 - 对齐 Android EatActivity.kt
// 接收 URL 参数(本地 asset 或远程 https), 顶栏 + 返回 + 标题 + WebView
// 支持今天吃什么(本地 asset) / json编辑器(远程 URL)
// 本地 asset 处理:拷贝到临时目录后 loadFile(规避 loadFlutterAsset 在 ohos 适配版可能未实现)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter_ohos/webview_flutter_ohos.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../widgets/tool_top_bar.dart';

class WebToolPage extends StatefulWidget {
  const WebToolPage({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  static Future<void> push(
    BuildContext context, {
    required String title,
    required String url,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WebToolPage(title: title, url: url)),
    );
  }

  @override
  State<WebToolPage> createState() => _WebToolPageState();
}

class _WebToolPageState extends State<WebToolPage> {
  late final PlatformWebViewController _controller;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = PlatformWebViewController(
      OhosWebViewControllerCreationParams(),
    )..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadContent();
  }

  /// 加载内容 - 对齐 EatActivity.kt:35-81 initWebView
  Future<void> _loadContent() async {
    try {
      if (widget.url.startsWith('http')) {
        // 远程 URL - loadRequest
        _controller.loadRequest(LoadRequestParams(uri: Uri.parse(widget.url)));
      } else {
        // 本地 asset - 拷贝到临时目录后 loadFile
        await _loadLocalAsset(widget.url);
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  /// 拷贝 asset 目录到临时目录,用 loadFile 加载
  /// 规避 loadFlutterAsset 在 ohos 适配版可能未实现的问题
  Future<void> _loadLocalAsset(String assetPath) async {
    // assetPath 如 'assets/game/jintianchishenme/index.html'
    // 提取目录名
    final parts = assetPath.split('/');
    final dirName = parts.length > 2 ? parts[parts.length - 2] : 'web';
    final htmlName = parts.last;

    final files =
        assetPath.contains('/ershisijieqi/') ? _solarTermsFiles : _eatGameFiles;
    final tempDir = await getTemporaryDirectory();
    final targetDir = Directory('${tempDir.path}/$dirName');
    final indexPath = '${targetDir.path}/$htmlName';
    final assetBase =
        assetPath.substring(0, assetPath.length - htmlName.length);

    // 所有引用资源落到同一临时目录，保证本地 HTML 的相对路径可解析。
    await targetDir.create(recursive: true);
    for (final f in files) {
      final data = await rootBundle.load('$assetBase$f');
      final file = File('${targetDir.path}/$f');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data.buffer.asUint8List());
    }
    _controller.loadFile(indexPath);
  }

  static const _eatGameFiles = [
    'index.html',
    'style/css/eat-min.css',
    'style/css/img/bg.jpg',
    'style/img/logo.png',
    'style/js/jquery-1.11.1.min.js',
  ];

  static const _solarTermsFiles = [
    'index.html',
    'css/jquery-weui.min.css',
    'css/solar.css',
    'css/weui.min.css',
    'js/calendar.js',
    'js/dayjs.min.js',
    'js/jquery.min.js',
    'js/underscore-min.js',
    'images/0.png',
    'images/1.png',
    'images/2.png',
    'images/3.png',
    'images/4.png',
    'images/5.png',
    'images/6.png',
    'images/7.png',
    'images/8.png',
    'images/9.png',
    'images/10.png',
    'images/11.png',
    'images/12.png',
    'images/13.png',
    'images/14.png',
    'images/15.png',
    'images/16.png',
    'images/17.png',
    'images/18.png',
    'images/19.png',
    'images/20.png',
    'images/21.png',
    'images/22.png',
    'images/23.png',
    'images/autumn_bg.png',
    'images/date_bg.png',
    'images/solar_bg.png',
    'images/spring_bg.png',
    'images/summer_bg.png',
    'images/winter_bg.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ToolTopBar(title: widget.title),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(child: Text('加载失败: $_loadError'))
              : PlatformWebViewWidget(
                  PlatformWebViewWidgetCreationParams(controller: _controller),
                ).build(context),
    );
  }
}
