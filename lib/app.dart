// 应用根 Widget - MaterialApp.router + 主题配置
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/todo_clockin/pages/reminder_launch_host.dart';
import 'router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // ReminderLaunchHost：接收系统通知点击进入(协议未同意时保留事件)
    return ReminderLaunchHost(
      child: MaterialApp.router(
        title: '乐彩绘画屋',
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
      ),
    );
  }
}
