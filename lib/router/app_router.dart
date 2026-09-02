// 路由配置 - 集中定义所有路由
import 'package:go_router/go_router.dart';
import '../features/bus/pages/bus_location_detail_page.dart';
import '../features/bus/pages/bus_map_search_page.dart';
import '../features/bus/pages/bus_route_line_detail_page.dart';
import '../features/bus/pages/bus_route_page.dart';
import '../features/bus/pages/bus_search_page.dart';
import '../features/bus/pages/map_navi_page.dart';
import '../features/bus/pages/map_route_page.dart';
import '../features/bus/pages/walk_navi_page.dart';
import '../features/bus/pages/vr_web_view_page.dart';
import '../features/travel/pages/disney_scenic_detail_page.dart';
import '../features/travel/pages/editor_pic_tips_page.dart';
import '../features/travel/pages/leshan_scenic_detail_page.dart';
import '../features/travel/pages/hong_kong_disney_detail_page.dart';
import '../features/home/pages/home_shell_page.dart';
import '../features/setting/pages/about_page.dart';
import '../features/setting/pages/feedback_page.dart';
import '../features/setting/pages/policy_page.dart';
import '../features/setting/pages/setting_page.dart';
import '../features/splash/pages/splash_page.dart';
import '../features/weather/pages/city_select_page.dart';
import '../features/weather/pages/weather_page.dart';
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
    // 独立详情入口 - 供“我的”页天气区跳转，避免回到带底部导航的 HomeShell。
    GoRoute(
      path: RoutePaths.weatherDetail,
      name: RouteNames.weatherDetail,
      builder: (context, state) => const WeatherPage(),
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
    // ====== 畅行（bus）模块路由 - 对齐 Android bus 包 Activity ======
    // 搜索选址页 - 对齐 Android BusSearchActivity(extra: is_from_location + current_city)
    GoRoute(
      path: RoutePaths.busSearch,
      name: RouteNames.busSearch,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return BusSearchPage(extra: extra);
      },
    ),
    // 地图搜索页 - 对齐 Android BusMapSearchActivity(extra: search_keyword)
    GoRoute(
      path: RoutePaths.busMapSearch,
      name: RouteNames.busMapSearch,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return BusMapSearchPage(extra: extra);
      },
    ),
    // 路线规划页 - 对齐 Android MapRouteActivity(extra: transport_mode + start_*/end_*)
    GoRoute(
      path: RoutePaths.mapRoute,
      name: RouteNames.mapRoute,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return MapRoutePage(extra: extra);
      },
    ),
    // 路线导航页 - 对齐 Android BusRouteActivity(extra: destination_* + use_my_location + transport_mode)
    GoRoute(
      path: RoutePaths.busRoute,
      name: RouteNames.busRoute,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return BusRoutePage(extra: extra);
      },
    ),
    // 地点详情页 - 对齐 Android BusLocationDetailActivity(extra: search_result)
    GoRoute(
      path: RoutePaths.busLocationDetail,
      name: RouteNames.busLocationDetail,
      builder: (context, state) {
        final extra = state.extra;
        return BusLocationDetailPage(
          extra: extra is Map<String, dynamic> ? extra : null,
        );
      },
    ),
    // 公交换乘详情页 - 对齐 Android BusRouteLineDetailActivity
    GoRoute(
      path: RoutePaths.busRouteLineDetail,
      name: RouteNames.busRouteLineDetail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return BusRouteLineDetailPage(extra: extra);
      },
    ),
    // 导航页 - 对齐 Android MapNaviActivity(extra: route_type + start_*/end_*)
    GoRoute(
      path: RoutePaths.mapNavi,
      name: RouteNames.mapNavi,
      builder: (context, state) {
        final extra = state.extra;
        return MapNaviPage(
          extra: extra is Map<String, dynamic> ? extra : null,
        );
      },
    ),
    // 步行导航页 - 对齐 Android WalkNaviActivity
    GoRoute(
      path: RoutePaths.walkNavi,
      name: RouteNames.walkNavi,
      builder: (context, state) => const WalkNaviPage(),
    ),
    // VR 全景页 - 对齐 Android WeatherWebViewActivity(extra: title + url)
    GoRoute(
      path: RoutePaths.vrWebView,
      name: RouteNames.vrWebView,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return VrWebViewPage(
          title: extra['title'] ?? '',
          url: extra['url'] ?? '',
        );
      },
    ),
    // ====== 旅行规划（travel）模块路由 - 对齐 Android hotSceniclib Activity ======
    // 迪士尼攻略页 - 对齐 Android DisneyShangHaiScenicDetailActivity
    GoRoute(
      path: RoutePaths.disneyScenic,
      name: RouteNames.disneyScenic,
      builder: (context, state) => const DisneyScenicDetailPage(),
    ),
    // 图片攻略页 - 对齐 Android EditorPicTipsActivity(extra: type String)
    GoRoute(
      path: RoutePaths.editorPicTips,
      name: RouteNames.editorPicTips,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return EditorPicTipsPage(extra: extra);
      },
    ),
    // 乐山峨眉攻略页 - 对齐 Android LeShanScenicDetailActivity
    GoRoute(
      path: RoutePaths.leShanScenic,
      name: RouteNames.leShanScenic,
      builder: (context, state) => const LeShanScenicDetailPage(),
    ),
    GoRoute(
      path: RoutePaths.hongKongDisneyScenic,
      name: RouteNames.hongKongDisneyScenic,
      builder: (context, state) => const HongKongDisneyDetailPage(),
    ),
  ],
);
