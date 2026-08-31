// 应用入口 - 先启动 Flutter，存储初始化由启动页在首帧后完成。
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants/app_assets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 原生启动窗口和 Flutter 启动页使用同一张 Logo。先完成图片解码，再交出
  // Flutter 首帧，使系统启动窗口能够无缝过渡到完整的“Logo + 名称”。
  await _warmUpSplashLogo();
  runApp(const ProviderScope(child: App()));
}

Future<void> _warmUpSplashLogo() async {
  final stream =
      const AssetImage(AppAssets.appLogo).resolve(ImageConfiguration.empty);
  final ready = Completer<void>();
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (_, __) {
      if (!ready.isCompleted) ready.complete();
      stream.removeListener(listener);
    },
    onError: (_, __) {
      // 启动 Logo 加载失败不应阻塞启动；启动页仍会按正常资源加载流程渲染。
      if (!ready.isCompleted) ready.complete();
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);
  await ready.future.timeout(
    const Duration(seconds: 2),
    onTimeout: () {
      stream.removeListener(listener);
    },
  );
}
