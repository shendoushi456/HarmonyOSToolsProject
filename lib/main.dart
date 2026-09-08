import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// 应用入口
void main() {
  runApp(
    const ProviderScope(
      child: HarmonyOSFlutterApp(),
    ),
  );
}

/// 应用根 Widget
class HarmonyOSFlutterApp extends StatelessWidget {
  const HarmonyOSFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '扫莱扫',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF28C7FF),
        ),
      ),
      routerConfig: router,
    );
  }
}
