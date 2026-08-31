// 路由配置 - 集中定义所有路由
import 'package:go_router/go_router.dart';
import '../features/home/pages/home_shell_page.dart';
import '../features/history/pages/history_page.dart';
import '../features/setting/pages/about_page.dart';
import '../features/setting/pages/feedback_page.dart';
import '../features/setting/pages/policy_page.dart';
import '../features/setting/pages/setting_page.dart';
import '../features/splash/pages/splash_page.dart';
import '../features/weather/pages/city_select_page.dart';
import '../features/weather/pages/solar_terms_page.dart';
import '../features/calendar/pages/health_info_page.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
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
    // 二十四节气 H5 页 - 对齐 Android WeatherWebViewActivity 加载本地 H5
    GoRoute(
      path: RoutePaths.solarTerms,
      name: RouteNames.solarTerms,
      builder: (context, state) => const SolarTermsPage(),
    ),
    // 历史上的今天页 - 对齐 Android HistoryActivity
    GoRoute(
      path: RoutePaths.historyToday,
      name: RouteNames.historyToday,
      builder: (context, state) => const HistoryPage(),
    ),
    // 健康生活方式长文本页 - 对齐 Android ExtendedinformationActivity(extra: flag 0=营养/1=缓解压力)
    GoRoute(
      path: RoutePaths.healthInfo,
      name: RouteNames.healthInfo,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final flag = extra?['flag'] as int? ?? 0;
        return HealthInfoPage(flag: flag);
      },
    ),
  ],
);
