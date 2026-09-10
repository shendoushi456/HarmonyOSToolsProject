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
import '../features/calendar/pages/life_tips_page.dart';
import '../features/calendar/pages/health_knowledge_page.dart';
import '../features/calendar/pages/qx_todo_page.dart';
import '../features/calendar/pages/qx_history_today_page.dart';
import '../features/long_trip/pages/long_trip_page.dart';
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
    // 生活小贴士 H5 页 - 对齐 Android WeatherWebViewActivity 加载 xiaoqiaomen.html
    GoRoute(
      path: RoutePaths.lifeTips,
      name: RouteNames.lifeTips,
      builder: (context, state) => const LifeTipsPage(),
    ),
    GoRoute(
      path: RoutePaths.nutrition,
      name: RouteNames.nutrition,
      builder: (context, state) => const HealthKnowledgePage(
        topic: HealthKnowledgeTopic.nutrition,
      ),
    ),
    GoRoute(
      path: RoutePaths.stress,
      name: RouteNames.stress,
      builder: (context, state) => const HealthKnowledgePage(
        topic: HealthKnowledgeTopic.stress,
      ),
    ),
    GoRoute(
      path: RoutePaths.longTrip,
      name: RouteNames.longTrip,
      builder: (context, state) => const LongTripPage(),
    ),
    // 我的待办事项页 - 对齐 Android QxTodoActivity
    GoRoute(
      path: RoutePaths.qxTodo,
      name: RouteNames.qxTodo,
      builder: (context, state) => const QxTodoPage(),
    ),
    // 历史上的今天页 - 对齐 Android QxHistoryTodayActivity(extra: yyyy-MM-dd)
    GoRoute(
      path: RoutePaths.qxHistoryToday,
      name: RouteNames.qxHistoryToday,
      builder: (context, state) =>
          QxHistoryTodayPage(date: state.extra as String?),
    ),
  ],
);
