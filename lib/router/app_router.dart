// 路由配置 - 集中定义所有路由
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/countdown/pages/add_countdown_page.dart';
import '../features/expense/pages/add_expense_page.dart';
import '../features/home/pages/home_shell_page.dart';
import '../features/more/pages/calculator_page.dart';
import '../features/more/pages/compass_page.dart';
import '../features/more/pages/time_screen_page.dart';
import '../features/notebook/pages/notebook_page.dart';
import '../features/notebook/pages/notebook_record_page.dart';
import '../features/notebook/models/notebook_entry.dart';
import '../features/recognition/models/recognition_type.dart';
import '../features/recognition/pages/recognition_page.dart';
import '../features/setting/pages/about_page.dart';
import '../features/setting/pages/feedback_page.dart';
import '../features/setting/pages/policy_page.dart';
import '../features/setting/pages/setting_page.dart';
import '../features/splash/pages/splash_page.dart';
import '../features/weather/pages/city_select_page.dart';
import 'route_names.dart';

/// 前台提醒弹框需要从应用根导航器展示，不能绑定到某个具体 Tab 的 context。
final appNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: appNavigatorKey,
  initialLocation: RoutePaths.splash,
  routes: [
    // 启动页 - 对齐 Android SplashActivity(检查隐私协议)
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RoutePaths.weather,
      name: RouteNames.home,
      builder: (context, state) => const HomeShellPage(),
    ),
    // 城市选择页(单选模式) - 对齐 Android AddCityActivity
    GoRoute(
      path: RoutePaths.citySelect,
      name: RouteNames.citySelect,
      builder: (context, state) => const CitySelectPage(),
    ),
    // 设置页 - 对齐 Android Setting4Activity
    GoRoute(
      path: RoutePaths.setting,
      name: RouteNames.setting,
      builder: (context, state) => const SettingPage(),
    ),
    // 协议页 - 对齐 Android PolicyToolsSetActivity(extra: title+url)
    GoRoute(
      path: RoutePaths.policy,
      name: RouteNames.policy,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return PolicyPage(
          title: extra['title'] ?? '',
          url: extra['url'] ?? '',
        );
      },
    ),
    // 关于页 - 对齐 Android AboutToolSetActivity
    GoRoute(
      path: RoutePaths.about,
      name: RouteNames.about,
      builder: (context, state) => const AboutPage(),
    ),
    // 反馈页 - 对齐 Android FeedBackSettingActivity
    GoRoute(
      path: RoutePaths.feedback,
      name: RouteNames.feedback,
      builder: (context, state) => const FeedbackPage(),
    ),
    GoRoute(
      path: RoutePaths.timeScreen,
      name: RouteNames.timeScreen,
      builder: (context, state) => const TimeScreenPage(),
    ),
    GoRoute(
      path: RoutePaths.compass,
      name: RouteNames.compass,
      builder: (context, state) => const CompassPage(),
    ),
    GoRoute(
      path: RoutePaths.calculator,
      name: RouteNames.calculator,
      builder: (context, state) => const CalculatorPage(),
    ),
    // 新增倒数日页 - 对齐 Android AddCountdownActivity
    GoRoute(
      path: RoutePaths.countdownAdd,
      name: RouteNames.countdownAdd,
      builder: (context, state) => const AddCountdownPage(),
    ),
    // 添加账单页 - 对齐 Android AddExpenseActivity
    GoRoute(
      path: RoutePaths.expenseAdd,
      name: RouteNames.expenseAdd,
      builder: (context, state) => const AddExpensePage(),
    ),
    GoRoute(
        path: RoutePaths.notebook,
        name: RouteNames.notebook,
        builder: (context, state) => const NotebookPage()),
    GoRoute(
        path: RoutePaths.notebookRecord,
        name: RouteNames.notebookRecord,
        builder: (context, state) => NotebookRecordPage(
            entry: state.extra is NotebookEntry
                ? state.extra as NotebookEntry
                : null)),
    GoRoute(
      path: RoutePaths.recognition,
      name: RouteNames.recognition,
      builder: (context, state) =>
          RecognitionPage(type: state.extra as RecognitionType),
    ),
  ],
);
