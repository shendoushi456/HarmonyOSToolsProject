// 路线规划页 - 对齐 Android bus/MapRouteActivity.kt
// 首页跳转来的路线规划页：接收 transport_mode + start_*/end_* 坐标
//
// 鸿蒙端差异：
// - Android ComponentActivity + Compose → Flutter ConsumerStatefulWidget + Riverpod
// - Android registerForActivityResult + onActivityResult → Flutter await GoRouter.of(context).push
// - Android ImmersionBar → Flutter SafeArea
// - Android R.mipmap.ic_bus_route_commutation → Flutter AppAssets.icBusRouteCommutation
// - Android 直接调用 viewModel.navigateToSearch → Flutter 监听 pendingSearchRequest 状态
// - Android 直接调用 MapNaviActivity.start / BusRouteLineDetailActivity.start → Flutter 监听 pendingNaviAction
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../router/route_names.dart';
import '../utils/bus_theme_colors.dart';
import '../utils/route_data_manager.dart';
import '../viewmodels/bus_route_view_model.dart';
import '../widgets/flow_row.dart';

/// 路线规划页 - 对齐 Android MapRouteActivity
class MapRoutePage extends ConsumerStatefulWidget {
  const MapRoutePage({super.key, this.extra});

  /// 路由参数（对齐 Android Intent extra）
  /// 接收: transport_mode/int、start_name/String、start_latitude/double、start_longitude/double、
  ///      end_name/String、end_latitude/double、end_longitude/double
  final Map<String, dynamic>? extra;

  @override
  ConsumerState<MapRoutePage> createState() => _MapRoutePageState();
}

class _MapRoutePageState extends ConsumerState<MapRoutePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromExtra());
  }

  /// 从路由参数初始化 - 对齐 Android onCreate
  Future<void> _initFromExtra() async {
    final extra = widget.extra ?? const {};
    // 对齐 Android: val transportMode = intent.getIntExtra(EXTRA_TRANSPORT_MODE, 0)
    final transportMode = extra['transport_mode'] as int? ?? 0;
    // 对齐 Android: val searchMode = true; viewModel.setSearchMode(searchMode)
    final notifier = ref.read(busRouteViewModelProvider.notifier);
    // 每次进入路线规划页都从空状态开始，避免复用上一次的起终点或路线结果。
    notifier.resetState();
    notifier.setSearchMode(true);

    // 对齐 Android: val startName = intent.getStringExtra(EXTRA_START_NAME); val endName = ...
    final startName = extra['start_name'] as String?;
    final endName = extra['end_name'] as String?;
    // 对齐 Android: hasSelectedStart / hasSelectedEnd
    final hasSelectedStart = startName != null &&
        startName.isNotEmpty &&
        extra['start_latitude'] != null &&
        extra['start_longitude'] != null;
    final hasSelectedEnd = endName != null &&
        endName.isNotEmpty &&
        extra['end_latitude'] != null &&
        extra['end_longitude'] != null;

    // 设置交通方式不发起查询，用户点击“搜索路线”后才开始规划。
    await notifier.selectTransportMode(transportMode);

    if (hasSelectedStart && hasSelectedEnd) {
      // 对齐 Android: 首页已经选择了起终点，直接使用真实坐标算路
      // 注：hasSelectedStart/hasSelectedEnd 已校验非空，直接解包
      // ignore: unnecessary_non_null_assertion
      final startNameLocal = startName!;
      // ignore: unnecessary_non_null_assertion
      final endNameLocal = endName!;
      await notifier.handleSearchResult(
        isFromLocation: true,
        locationName: startNameLocal,
        latitude: extra['start_latitude'] as double,
        longitude: extra['start_longitude'] as double,
      );
      await notifier.handleSearchResult(
        isFromLocation: false,
        locationName: endNameLocal,
        latitude: extra['end_latitude'] as double,
        longitude: extra['end_longitude'] as double,
      );
    } else {
      // 对齐 Android: viewModel.startLocationForRoute()
      await notifier.startLocationForRoute();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: val uiState by remember { derivedStateOf { viewModel.uiState } }
    final uiState = ref.watch(busRouteViewModelProvider);

    // 对齐 Android: LaunchedEffect(uiState.errorMessage) { Toast...; clearError() }
    ref.listen<BusRouteUiState>(busRouteViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        final message = next.errorMessage!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
          ref.read(busRouteViewModelProvider.notifier).clearError();
        });
      }
    });

    // 监听待处理搜索页跳转
    ref.listen<BusRouteUiState>(busRouteViewModelProvider, (previous, next) {
      if (next.pendingSearchRequest != null &&
          next.pendingSearchRequest != previous?.pendingSearchRequest) {
        final request = next.pendingSearchRequest!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _handlePendingSearch(request);
        });
      }
    });

    // 监听待处理导航跳转
    ref.listen<BusRouteUiState>(busRouteViewModelProvider, (previous, next) {
      if (next.pendingNaviAction != null &&
          next.pendingNaviAction != previous?.pendingNaviAction) {
        final action = next.pendingNaviAction!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _handlePendingNavi(action);
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _TopAppBar(onBack: () => GoRouter.of(context).pop()),
            Expanded(
              child: Stack(
                children: [
                  _MapRouteContent(uiState: uiState, ref: ref),
                  // 加载指示器 - 对齐 Android: if (uiState.isLoading) Box(background=Black.alpha=0.3f)
                  if (uiState.isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: BusThemeColors.primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理搜索页跳转 - 对齐 Android navigateToSearch 触发的 BusSearchActivity 启动
  Future<void> _handlePendingSearch(PendingSearchRequest request) async {
    final result = await GoRouter.of(context).push(
      RoutePaths.busSearch,
      extra: {
        'is_from_location': request.isFromLocation,
        'current_city': request.currentCity,
      },
    );
    // 处理搜索页返回结果 - 对齐 Android onActivityResult
    if (result is Map<String, dynamic>) {
      final locationName = result['location_name'] as String?;
      if (locationName == null || locationName.isEmpty) {
        ref
            .read(busRouteViewModelProvider.notifier)
            .clearPendingSearchRequest();
        return;
      }
      final latitude = result['latitude'] as double? ?? 0.0;
      final longitude = result['longitude'] as double? ?? 0.0;
      // 对齐 Android: viewModel.handleSearchResult(isFromLocation, locationName, latitude, longitude)
      await ref.read(busRouteViewModelProvider.notifier).handleSearchResult(
            isFromLocation: request.isFromLocation,
            locationName: locationName,
            latitude: latitude,
            longitude: longitude,
          );
    }
    ref.read(busRouteViewModelProvider.notifier).clearPendingSearchRequest();
  }

  /// 处理导航跳转 - 对齐 Android MapNaviActivity.start / BusRouteLineDetailActivity.start
  Future<void> _handlePendingNavi(PendingNaviAction action) async {
    if (action.type == NaviActionType.routeLineDetail) {
      // 对齐 Android: BusRouteLineDetailActivity.start(context, transitRouteLines, transitRouteResult)
      // 百度路线对象不可安全序列化到 GoRouter extra，先写入单例供详情页读取。
      // 与 BusRoutePage 保持相同的数据交接，防止从地图路线入口复现空列表。
      RouteDataManager.instance.setTransitRouteLines(action.transitRouteLines);
      RouteDataManager.instance
          .setTransitRouteResult(action.transitRouteResult);
      await GoRouter.of(context).push(
        RoutePaths.busRouteLineDetail,
        extra: {
          'start_latitude': action.startPoint.latitude,
          'start_longitude': action.startPoint.longitude,
          'end_latitude': action.endPoint.latitude,
          'end_longitude': action.endPoint.longitude,
          'start_name': action.startName,
          'end_name': action.endName,
          'route_points': action.routePoints,
        },
      );
    } else {
      // 对齐 Android: MapNaviActivity.start(context, startPoint, endPoint, fromLocation, toLocation, naviStartType)
      await GoRouter.of(context).push(
        RoutePaths.mapNavi,
        extra: {
          'navi_start_type': action.naviStartType.name,
          'start_latitude': action.startPoint.latitude,
          'start_longitude': action.startPoint.longitude,
          'end_latitude': action.endPoint.latitude,
          'end_longitude': action.endPoint.longitude,
          'start_name': action.startName,
          'end_name': action.endName,
          // 将当前选中的规划轨迹一并交给地图页，避免仅显示起终点连线。
          'route_points': action.routePoints,
        },
      );
    }
    ref.read(busRouteViewModelProvider.notifier).clearPendingNaviAction();
  }
}

/// 顶部应用栏 - 对齐 Android MapRouteActivity.AppBar
class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: BusThemeColors.primaryColor,
      child: Stack(
        children: [
          Positioned(
            left: 15,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                color: BusThemeColors.onPrimaryColor,
                padding: const EdgeInsets.all(10),
                onPressed: onBack,
              ),
            ),
          ),
          // 对齐 Android Text("到这去", fontSize=22sp, fontWeight=SemiBold)
          Center(
            child: Text(
              '到这去',
              style: TextStyle(
                color: BusThemeColors.onPrimaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 路线内容 - 对齐 Android BusRouteContent
class _MapRouteContent extends StatelessWidget {
  const _MapRouteContent({required this.uiState, required this.ref});

  final BusRouteUiState uiState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // 输入框区域 - 对齐 Android InputSection
          _InputSection(uiState: uiState, ref: ref),
          const SizedBox(height: 30),
          // 交通方式选择器已注释（对齐 Android TransportModeSelector 注释）
          // 路线列表 - 对齐 Android BusRouteList
          _BusRouteList(uiState: uiState, ref: ref),
        ],
      ),
    );
  }
}

/// 输入框区域 - 对齐 Android InputSection
class _InputSection extends StatelessWidget {
  const _InputSection({required this.uiState, required this.ref});

  final BusRouteUiState uiState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  // 出发地输入框 - 对齐 Android: clickable -> viewModel.navigateToSearch(this, true)
                  _LocationInput(
                    text: uiState.fromLocation,
                    onTap: () => ref
                        .read(busRouteViewModelProvider.notifier)
                        .navigateToSearch(isFromLocation: true),
                  ),
                  const SizedBox(height: 12),
                  // 目的地输入框 - 对齐 Android: clickable -> viewModel.navigateToSearch(this, false)
                  _LocationInput(
                    text: uiState.toLocation,
                    onTap: () => ref
                        .read(busRouteViewModelProvider.notifier)
                        .navigateToSearch(isFromLocation: false),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 交换图标 - 对齐 Android AsyncImage(R.mipmap.ic_bus_route_commutation)
            GestureDetector(
              onTap: () {
                ref.read(busRouteViewModelProvider.notifier).swapLocations();
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  AppAssets.icBusRouteCommutation,
                  width: 20,
                  height: 19,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        // 搜索按钮 - 对齐 Android Box(height=40dp, background=PRIMARY_COLOR, clickable=searchBusRoute)
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            ref.read(busRouteViewModelProvider.notifier).searchBusRoute();
          },
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: BusThemeColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '搜索路线',
              style: TextStyle(
                color: BusThemeColors.onPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 位置输入框 - 对齐 Android InputSection 中的 Box
class _LocationInput extends StatelessWidget {
  const _LocationInput({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF6F6F6F), fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// 路线列表 - 对齐 Android BusRouteList
class _BusRouteList extends StatelessWidget {
  const _BusRouteList({required this.uiState, required this.ref});

  final BusRouteUiState uiState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: val currentRoutes = remember { viewModel.getCurrentRouteList() }
    final currentRoutes =
        ref.read(busRouteViewModelProvider.notifier).getCurrentRouteList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: currentRoutes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final route = currentRoutes[index];
        // 对齐 Android: when (route) { is BusRouteItem -> BusRouteItemView; is DriveRouteItem -> ... }
        if (route is BusRouteItem) {
          return _BusRouteItemView(
            route: route,
            onTap: () => ref
                .read(busRouteViewModelProvider.notifier)
                .onRouteItemClick(route),
          );
        }
        if (route is DriveRouteItem) {
          return _DriveRouteItemView(
            route: route,
            onTap: () => ref
                .read(busRouteViewModelProvider.notifier)
                .onRouteItemClick(route),
          );
        }
        if (route is RideRouteItem) {
          return _RideRouteItemView(
            route: route,
            onTap: () => ref
                .read(busRouteViewModelProvider.notifier)
                .onRouteItemClick(route),
          );
        }
        if (route is WalkRouteItem) {
          return _WalkRouteItemView(
            route: route,
            onTap: () => ref
                .read(busRouteViewModelProvider.notifier)
                .onRouteItemClick(route),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// 公交路线项 - 对齐 Android BusRouteItemView
class _BusRouteItemView extends StatelessWidget {
  const _BusRouteItemView({required this.route, required this.onTap});

  final BusRouteItem route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final routeNumbers =
        route.routeNumber.split('→').where((s) => s.trim().isNotEmpty).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.duration,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF454545),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 路线标签 - 对齐 Android FlowRow
                  FlowRow(
                    horizontalSpacing: 8,
                    verticalSpacing: 4,
                    children: [
                      for (final routeNum in routeNumbers)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: BusThemeColors.primaryColor),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            routeNum.trim(),
                            style: TextStyle(
                              color: BusThemeColors.primaryColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Positioned(
              right: 0,
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Color(0xFF444444),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 驾车路线项 - 对齐 Android DriveRouteItemView
class _DriveRouteItemView extends StatelessWidget {
  const _DriveRouteItemView({required this.route, required this.onTap});

  final DriveRouteItem route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.duration,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF454545),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route.distance,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 4),
                  // 红绿灯 + 过路费 - 对齐 Android FlowRow
                  FlowRow(
                    horizontalSpacing: 8,
                    verticalSpacing: 4,
                    children: [
                      _RouteTag(text: route.trafficLights),
                      _RouteTag(text: route.tollCost),
                    ],
                  ),
                ],
              ),
            ),
            const Positioned(
              right: 0,
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Color(0xFF444444),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 骑行路线项 - 对齐 Android RideRouteItemView
class _RideRouteItemView extends StatelessWidget {
  const _RideRouteItemView({required this.route, required this.onTap});

  final RideRouteItem route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.duration,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF454545),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route.distance,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 4),
                  _RouteTag(text: '骑行路线'),
                ],
              ),
            ),
            const Positioned(
              right: 0,
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Color(0xFF444444),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 步行路线项 - 对齐 Android WalkRouteItemView
class _WalkRouteItemView extends StatelessWidget {
  const _WalkRouteItemView({required this.route, required this.onTap});

  final WalkRouteItem route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.duration,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF454545),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route.distance,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 4),
                  _RouteTag(text: '步行路线'),
                ],
              ),
            ),
            const Positioned(
              right: 0,
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Color(0xFF444444),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 路线标签 - 对齐 Android FlowRow 中的 Box(border, padding, text)
class _RouteTag extends StatelessWidget {
  const _RouteTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: BusThemeColors.primaryColor),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: TextStyle(color: BusThemeColors.primaryColor, fontSize: 10),
      ),
    );
  }
}
