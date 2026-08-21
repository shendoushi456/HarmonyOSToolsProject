// 地图导航页 - 对齐 Android bus/MapNaviActivity.kt
// 驾车/骑行/步行导航页面
//
// 迁移说明：
// - Android ComponentActivity + Compose → Flutter ConsumerStatefulWidget
// - Android by viewModels() → ref.watch(mapNaviViewModelProvider)
// - Android Intent.getStringExtra/DoubleExtra → GoRoute extra[...]
// - Android WalkNavigateHelper / BikeNavigateHelper / BaiduNaviManagerFactory → 鸿蒙端 SDK 不可用，用占位 UI + TODO 兜底
// - Android 生命周期 onStart/onResume/onPause/onStop/onDestroy → WidgetsBindingObserver + initState/dispose
// - Android AndroidView(FrameLayout + naviView) → 鸿蒙端用占位 Container（SDK 不可用）
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/bus_theme_colors.dart';
import '../utils/navi_plan_manager.dart';
import '../viewmodels/map_navi_view_model.dart';
import '../widgets/map_compose.dart';

/// 地图导航页 - 对齐 Android MapNaviActivity
/// 驾车/骑行/步行导航页面
class MapNaviPage extends ConsumerStatefulWidget {
  const MapNaviPage({super.key});

  @override
  ConsumerState<MapNaviPage> createState() => _MapNaviPageState();
}

class _MapNaviPageState extends ConsumerState<MapNaviPage>
    with WidgetsBindingObserver {
  /// 路线类型 - 对齐 Android EXTRA_ROUTE_TYPE
  late final NaviStartType _routeType;

  /// 起点坐标 - 对齐 Android EXTRA_START_LAT/LNG
  BMFCoordinate? _startPoint;

  /// 终点坐标 - 对齐 Android EXTRA_END_LAT/LNG
  BMFCoordinate? _endPoint;

  /// 起点名称 - 对齐 Android EXTRA_START_NAME
  late final String _startName;

  /// 终点名称 - 对齐 Android EXTRA_END_NAME
  late final String _endName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 对齐 Android onCreate: 解析 Intent 参数
    _parseRouteParams();

    // 对齐 Android onCreate: viewModel.initNaviParams(naviStartType, startPoint, endPoint, startName, endName)
    ref.read(mapNaviViewModelProvider.notifier).initNaviParams(
          naviStartType: _routeType,
          startPoint: _startPoint,
          endPoint: _endPoint,
          startName: _startName,
          endName: _endName,
        );

    // 对齐 Android onCreate: viewModel.prepareNaviAfterPlan(this, naviStartType)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(mapNaviViewModelProvider.notifier)
          .prepareNaviAfterPlan(_routeType);
    });

    // 对齐 Android onStart: viewModel.startNavigation()
    ref.read(mapNaviViewModelProvider.notifier).startNavigation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 对齐 Android 生命周期：onResume/onPause/onStop
    switch (state) {
      case AppLifecycleState.resumed:
        // 对齐 Android onResume: window.addFlags(FLAG_KEEP_SCREEN_ON) + viewModel.resumeNavigation()
        // 鸿蒙端: 屏幕常亮通过 SystemChrome 或 wakelock_plus 处理（这里仅调用 ViewModel）
        ref.read(mapNaviViewModelProvider.notifier).resumeNavigation();
        break;
      case AppLifecycleState.paused:
        // 对齐 Android onPause: window.clearFlags(FLAG_KEEP_SCREEN_ON) + viewModel.pauseNavigation()
        ref.read(mapNaviViewModelProvider.notifier).pauseNavigation();
        break;
      case AppLifecycleState.inactive:
        // 对齐 Android onStop: viewModel.stopNavigation()
        ref.read(mapNaviViewModelProvider.notifier).stopNavigation();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    // 对齐 Android onDestroy: viewModel.destroyNavigation()
    ref.read(mapNaviViewModelProvider.notifier).destroyNavigation();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 解析路由参数 - 对齐 Android onCreate 中的参数提取
  void _parseRouteParams() {
    final extra = GoRouterState.of(context).extra;
    String routeTypeString = 'drive';
    if (extra is Map<String, dynamic>) {
      routeTypeString = (extra['route_type'] as String?) ?? 'drive';

      final hasCoordinates = extra.containsKey('start_lat');
      if (hasCoordinates) {
        final startLat = _toDouble(extra['start_lat']) ?? 0.0;
        final startLng = _toDouble(extra['start_lng']) ?? 0.0;
        final endLat = _toDouble(extra['end_lat']) ?? 0.0;
        final endLng = _toDouble(extra['end_lng']) ?? 0.0;
        _startName = (extra['start_name'] as String?) ?? '';
        _endName = (extra['end_name'] as String?) ?? '';

        // 对齐 Android: 跳过 (0, 0) 的坐标
        if (startLat != 0.0 &&
            startLng != 0.0 &&
            endLat != 0.0 &&
            endLng != 0.0) {
          _startPoint = BMFCoordinate(startLat, startLng);
          _endPoint = BMFCoordinate(endLat, endLng);
        }
      } else {
        _startName = '';
        _endName = '';
      }
    } else {
      _startName = '';
      _endName = '';
    }

    // 对齐 Android: when (routeTypeString) { "bike" -> Bike; "walk" -> Walk; "drive" -> Drive }
    // 注：项目 SDK 约束下界为 2.19，避免 switch expression 兼容性问题，使用 if-else
    if (routeTypeString == 'bike') {
      _routeType = NaviStartType.bike;
    } else if (routeTypeString == 'walk') {
      _routeType = NaviStartType.walk;
    } else {
      _routeType = NaviStartType.drive;
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// 退出导航 - 对齐 Android exitNavigation()
  void _exitNavigation() {
    ref.read(mapNaviViewModelProvider.notifier).exitNavigation();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android setContent: 根据 naviStartType 显示不同内容
    return Scaffold(
      body: Column(
        children: [
          // 顶部状态栏 - 对齐 Android NavigationStatusBar(title)
          _NavigationStatusBar(
            title: _naviTitle(_routeType),
            onBack: _exitNavigation,
          ),
          // 内容区域 - 对齐 Android BikeNaviContent / WalkNaviContent / DriveNaviContent
          Expanded(
            child: _buildNaviContent(),
          ),
        ],
      ),
    );
  }

  /// 根据 route_type 渲染对应导航内容 - 对齐 Android onCreate when (naviStartType)
  Widget _buildNaviContent() {
    final uiState = ref.watch(mapNaviViewModelProvider);
    switch (_routeType) {
      case NaviStartType.bike:
        return _BikeNaviContent(
          uiState: uiState,
          startName: _startName,
          endName: _endName,
        );
      case NaviStartType.walk:
        return _WalkNaviContent(
          uiState: uiState,
          startName: _startName,
          endName: _endName,
        );
      case NaviStartType.drive:
        return _DriveNaviContent(
          uiState: uiState,
          startName: _startName,
          endName: _endName,
        );
    }
  }

  /// 获取导航标题 - 对齐 Android NavigationStatusBar("驾车/骑行/步行导航")
  String _naviTitle(NaviStartType type) {
    switch (type) {
      case NaviStartType.drive:
        return '驾车导航';
      case NaviStartType.bike:
        return '骑行导航';
      case NaviStartType.walk:
        return '步行导航';
    }
  }
}

/// 顶部导航状态栏 - 对齐 Android NavigationStatusBar
class _NavigationStatusBar extends StatelessWidget {
  const _NavigationStatusBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(背景 PRIMARY_COLOR, statusBarsPadding, height 50)
    return Container(
      color: BusThemeColors.primaryColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 返回按钮 - 对齐 Android Box(start 18dp, clickable, padding 12)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: IconButton(
                    onPressed: onBack,
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: BusThemeColors.onPrimaryColor,
                    ),
                  ),
                ),
              ),
              // 标题 - 对齐 Android Text(title, center, color ON_PRIMARY, 22sp, SemiBold)
              Text(
                title,
                style: const TextStyle(
                  color: BusThemeColors.onPrimaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 驾车导航内容 - 对齐 Android DriveNaviContent
class _DriveNaviContent extends StatelessWidget {
  const _DriveNaviContent({
    required this.uiState,
    required this.startName,
    required this.endName,
  });

  final MapNaviState uiState;
  final String startName;
  final String endName;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: if (uiState.isRoutePlanSuccess) AndroidView else LoadingContent("正在规划驾车路线...")
    if (uiState.isRoutePlanSuccess) {
      // TODO(HarmonyOS): 鸿蒙端百度导航 SDK 不可用，无法显示真实驾车导航视图
      // 替代 Android AndroidView(viewModel.getDriveNaviView(activity)) 的占位 UI
      return _NaviPlaceholderContent(
        message: '鸿蒙端驾车导航 SDK 不可用\n起点: $startName\n终点: $endName',
      );
    }
    return _LoadingContent(message: '正在规划驾车路线...');
  }
}

/// 骑行导航内容 - 对齐 Android BikeNaviContent
class _BikeNaviContent extends StatelessWidget {
  const _BikeNaviContent({
    required this.uiState,
    required this.startName,
    required this.endName,
  });

  final MapNaviState uiState;
  final String startName;
  final String endName;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: if (uiState.isRoutePlanSuccess) AndroidView else LoadingContent("正在规划骑行路线...")
    if (uiState.isRoutePlanSuccess) {
      // TODO(HarmonyOS): 鸿蒙端 BikeNavigateHelper 不可用，无法显示真实骑行导航视图
      return _NaviPlaceholderContent(
        message: '鸿蒙端骑行导航 SDK 不可用\n起点: $startName\n终点: $endName',
      );
    }
    return _LoadingContent(message: '正在规划骑行路线...');
  }
}

/// 步行导航内容 - 对齐 Android WalkNaviContent
class _WalkNaviContent extends StatelessWidget {
  const _WalkNaviContent({
    required this.uiState,
    required this.startName,
    required this.endName,
  });

  final MapNaviState uiState;
  final String startName;
  final String endName;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: if (uiState.isRoutePlanSuccess) AndroidView else LoadingContent("正在规划步行路线...")
    if (uiState.isRoutePlanSuccess) {
      // TODO(HarmonyOS): 鸿蒙端 WalkNavigateHelper 不可用，无法显示真实步行导航视图
      return _NaviPlaceholderContent(
        message: '鸿蒙端步行导航 SDK 不可用\n起点: $startName\n终点: $endName',
      );
    }
    return _LoadingContent(message: '正在规划步行路线...');
  }
}

/// 加载中内容 - 对齐 Android LoadingContent
class _LoadingContent extends StatelessWidget {
  const _LoadingContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(fillMaxSize, 背景 0xFFF5F5F5, center)
    return Container(
      color: const Color(0xFFF5F5F5),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 对齐 Android CircularProgressIndicator(size 48, color PRIMARY_COLOR, strokeWidth 4)
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: BusThemeColors.primaryColor,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 16),
          // 对齐 Android Text(message, 16sp, color 0xFF666666, maxLines 1, Ellipsis)
          Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// 导航占位内容 - 鸿蒙端 SDK 不可用时的兜底 UI
/// 对齐 Android MapInfoContent（审图号等信息）
class _NaviPlaceholderContent extends StatelessWidget {
  const _NaviPlaceholderContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 占位提示 - 对齐 Android AndroidView 替代
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
            ),
          ),
        ),
        // 审图号信息 - 对齐 Android BoxScope.MapInfoContent
        const Positioned(
          left: 20,
          top: 16,
          child: MapInfoContent(),
        ),
      ],
    );
  }
}
