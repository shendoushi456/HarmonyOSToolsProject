import 'package:flutter/material.dart';

import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

/// 应用根 Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '悠游出行',
      theme: appTheme(),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
