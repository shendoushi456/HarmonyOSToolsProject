// 应用入口 - 初始化存储并启动 App
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/prefs_storage.dart';
import 'features/bus/utils/baidu_sdk_initializer.dart';

Future<void> main() async {
  // 确保 Flutter 绑定初始化(用于 SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存储
  await PrefsStorage.init();

  // 初始化百度地图 SDK（对齐 Android MainWeatherActivity.onCreate 的 SDKInitializer.initialize）
  // 鸿蒙端 AK 通过代码设置，非 manifest meta-data
  // 首页可直接跳转到路线或附近地图页，不能依赖主页面已提前初始化 SDK
  await BaiduSdkInitializer.ensureInitialized();

  runApp(const ProviderScope(child: App()));
}
