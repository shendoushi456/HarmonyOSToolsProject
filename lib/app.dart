// 应用根 Widget - MaterialApp.router + 主题配置
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/wifi_tools/viewmodels/float_speed_provider.dart';
import 'features/wifi_tools/widgets/wifi_speed_overlay.dart';
import 'router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floatSpeedShowing = ref.watch(floatSpeedProvider);
    return MaterialApp.router(
      title: '达速上网通',
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
      routerConfig: appRouter,
      // 悬浮网速浮层挂全局路由之上: 整个 APP 页面均可见(对齐安卓 FloatingWindow)
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (floatSpeedShowing) const WifiSpeedOverlay(),
          ],
        );
      },
    );
  }
}
