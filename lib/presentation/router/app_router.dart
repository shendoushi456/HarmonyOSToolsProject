import 'package:go_router/go_router.dart';

import '../car_detail/image_display_page.dart';
import '../car_maintenance/car_maintenance_page.dart';
import '../driving_license/driving_license_deduction_page.dart';
import '../indicator_light/indicator_light_page.dart';
import '../markdown/markdown_page.dart';
import '../scan_menu/scan_menu_page.dart';
import '../settings/about_page.dart';
import '../settings/feedback_page.dart';
import '../settings/policy_page.dart';
import '../settings/settings_page.dart';
import '../splash/splash_page.dart';
import '../violation_code_search/violation_code_result_page.dart';
import '../violation_code_search/violation_code_search_page.dart';
import '../violation_processing/violation_processing_page.dart';
import 'app_routes.dart';

/// 全局路由配置
///
/// 对应 Android: ScanMenuActivity + 7 个子 Activity 的跳转关系。
/// ScanMenuPage 内部用 IndexedStack 管理 3 个 Tab，不走子路由。
final goRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // 启动页（协议弹框 + 入口判断）
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),

    // 主框架：底部导航 + 3 Tab
    GoRoute(
      path: AppRoutes.scanMenu,
      builder: (context, state) => const ScanMenuPage(),
    ),

    // 7 个子页面
    GoRoute(
      path: AppRoutes.violationCodeSearch,
      builder: (context, state) => const ViolationCodeSearchPage(),
    ),
    GoRoute(
      path: AppRoutes.violationCodeResult,
      builder: (context, state) => ViolationCodeResultPage(
        code: state.pathParameters['code']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.violationProcessing,
      builder: (context, state) => const ViolationProcessingPage(),
    ),
    GoRoute(
      path: AppRoutes.carMaintenance,
      builder: (context, state) => const CarMaintenancePage(),
    ),
    GoRoute(
      path: AppRoutes.carDetailPattern,
      builder: (context, state) => ImageDisplayPage(
        type: state.pathParameters['type']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.indicatorLight,
      builder: (context, state) => const IndicatorLightPage(),
    ),
    GoRoute(
      path: AppRoutes.drivingLicense,
      builder: (context, state) => const DrivingLicenseDeductionPage(),
    ),
    GoRoute(
      path: AppRoutes.markdown,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MarkdownPage(
          title: (extra?['title'] as String?) ?? '',
          content: (extra?['content'] as String?) ?? '',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.settingsPolicy,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PolicyPage(
          title: (extra?['title'] as String?) ?? '',
          url: (extra?['url'] as String?) ?? '',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settingsAbout,
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: AppRoutes.settingsFeedback,
      builder: (context, state) => const FeedbackPage(),
    ),
  ],
);
