// 路由配置 - 集中定义所有路由
import 'package:go_router/go_router.dart';
import '../features/home/pages/home_shell_page.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.weather,
  routes: [
    GoRoute(
      path: RoutePaths.weather,
      name: RouteNames.home,
      builder: (context, state) => const HomeShellPage(),
    ),
  ],
);
