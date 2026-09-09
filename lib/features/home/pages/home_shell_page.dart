// 底部 4 Tab 容器：首位为 toolbox_c 迁入的天气页，保留既有首页/日历/空气质量。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agriculture/pages/agriculture_page.dart';
import '../../air_quality/pages/air_quality_new_page.dart';
import '../../weather/pages/toolbox_weather_page.dart';
import 'life_home_page.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/app_route_observer.dart';

/// 当前选中的 Tab 索引
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShellPage extends ConsumerStatefulWidget {
  const HomeShellPage({super.key});

  @override
  ConsumerState<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends ConsumerState<HomeShellPage>
    with WidgetsBindingObserver, RouteAware {
  bool _isAppResumed = true;
  bool _isRouteVisible = true;
  ModalRoute<dynamic>? _subscribedRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _subscribedRoute) {
      if (_subscribedRoute != null) {
        appRouteObserver.unsubscribe(this);
      }
      _subscribedRoute = route;
      appRouteObserver.subscribe(this, route);
      _isRouteVisible = route.isCurrent;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (resumed != _isAppResumed && mounted) {
      setState(() => _isAppResumed = resumed);
    }
  }

  @override
  void didPushNext() {
    if (mounted) setState(() => _isRouteVisible = false);
  }

  @override
  void didPopNext() {
    if (mounted) setState(() => _isRouteVisible = true);
  }

  @override
  void didPop() {
    _isRouteVisible = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_subscribedRoute != null) {
      appRouteObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    const pages = [
      ToolboxWeatherPage(),
      LifeHomePage(),
      AgriculturePage(),
      AirQualityNewPage(),
    ];

    final animationsEnabled = _isAppResumed && _isRouteVisible;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 四个一级页面均为深色底，状态栏文字固定使用白色。
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF0A0D0E),
      ),
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: [
            for (var index = 0; index < pages.length; index++)
              TickerMode(
                enabled: animationsEnabled && currentIndex == index,
                child: pages[index],
              ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(context, ref, currentIndex),
      ),
    );
  }

  /// 底部导航栏 - 对齐 Android MyBottomNavView
  Widget _buildBottomNav(
      BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0D0E),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            _buildNavItem(
              context,
              ref,
              index: 0,
              label: '天气',
              normalIcon: AppAssets.toolboxNavWeatherNormal,
              selectedIcon: AppAssets.toolboxNavWeatherSelected,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              ref,
              index: 1,
              label: '日历',
              normalIcon: AppAssets.toolboxNavCalendarNormal,
              selectedIcon: AppAssets.toolboxNavCalendarSelected,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              context,
              ref,
              index: 2,
              label: '农业',
              normalIcon: AppAssets.toolboxNavAgricultureNormal,
              selectedIcon: AppAssets.toolboxNavAgricultureSelected,
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              context,
              ref,
              index: 3,
              label: '生活指南',
              normalIcon: AppAssets.toolboxNavLifeGuideNormal,
              selectedIcon: AppAssets.toolboxNavLifeGuideSelected,
              isSelected: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  /// 单个底部导航项
  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref, {
    required int index,
    required String label,
    required String normalIcon,
    required String selectedIcon,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(homeTabIndexProvider.notifier).state = index,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isSelected ? selectedIcon : normalIcon,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
