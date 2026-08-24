// 应用入口 - 初始化存储并启动 App
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  // 确保 Flutter 绑定初始化(用于 SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存储
  // await PrefsStorage.init();
  //
  // runApp(const ProviderScope(child: App()));
}
