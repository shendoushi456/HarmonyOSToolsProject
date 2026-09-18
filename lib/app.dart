// 应用根 Widget - MaterialApp.router + 主题配置
// 应用内字体缩放:MaterialApp.builder 包 TextScaler,档位由首页
// 字体大小设置页(fontScaleProvider)控制并持久化。
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/font_scale_provider.dart';
import 'router/app_router.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // 首帧后加载已保存的字体缩放档位(存储由启动页首帧后 init,此处幂等兜底)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fontScaleProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ref.watch(fontScaleProvider);
    return MaterialApp.router(
      title: '免费扫扫王',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'HarmonyText',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
      ],
      locale: const Locale('zh', 'CN'),
      // 应用内字体缩放 - 覆盖系统 textScaler,以 1.0 档为基准
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(fontScale)),
          child: child!,
        );
      },
      routerConfig: appRouter,
    );
  }
}
